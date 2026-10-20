[CmdletBinding()]
param(
    [string]$ContainerName = 'model-cloud-gitea',
    [string]$GiteaUrl = 'http://localhost:3000',
    [ValidatePattern('^[A-Za-z0-9][A-Za-z0-9_.-]*$')][string]$Username = 'modelcloud',
    [string]$Email = 'modelcloud@localhost.local',
    [string]$ConnectionFile = (Join-Path $PSScriptRoot 'gitea.local'),
    [string]$CoverImage
)

$ErrorActionPreference = 'Stop'
$GiteaUrl = $GiteaUrl.TrimEnd('/')
$ConnectionFile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ConnectionFile)

function Invoke-GiteaCli([string[]]$CliArguments) {
    $result = @(& docker exec --user git $ContainerName gitea --config /data/gitea/conf/app.ini @CliArguments)
    if ($LASTEXITCODE -ne 0) {
        throw 'Gitea CLI failed. Complete Gitea initial installation and check the container first.'
    }
    return $result
}

function Get-GiteaResource([string]$ResourcePath) {
    try {
        return Invoke-RestMethod -Uri "$GiteaUrl/api/v1$ResourcePath" -Headers $apiHeaders -TimeoutSec 30
    } catch {
        if ($_.Exception.Response -and [int]$_.Exception.Response.StatusCode -eq 404) { return $null }
        throw
    }
}

# Validate an optional asset before making service changes.
$coverBytes = $null
if ($CoverImage) {
    $coverBytes = [IO.File]::ReadAllBytes((Resolve-Path -LiteralPath $CoverImage).Path)
    if ($coverBytes.Length -lt 8 -or [BitConverter]::ToString($coverBytes[0..7]) -ne '89-50-4E-47-0D-0A-1A-0A') {
        throw 'CoverImage must be a PNG file.'
    }
}

if (Test-Path -LiteralPath $ConnectionFile) {
    $connection = Get-Content -LiteralPath $ConnectionFile -Raw | ConvertFrom-Json
    if ($connection.url -ne $GiteaUrl -or $connection.username -ne $Username -or -not $connection.token) {
        throw 'Connection file does not match the requested instance/user. Check it before proceeding.'
    }
    $token = $connection.token
} else {
    $users = @(Invoke-GiteaCli @('admin', 'user', 'list'))
    if (-not ($users -match ('^\d+\s+' + [regex]::Escape($Username) + '\s'))) {
        $securePassword = Read-Host "Password for the new Gitea user '$Username'" -AsSecureString
        $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
        try {
            $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
            if (-not $plainPassword) { throw 'A non-empty password is required.' }
            Invoke-GiteaCli @('admin', 'user', 'create', '--username', $Username, '--password', $plainPassword,
                '--email', $Email, '--must-change-password=false') | Out-Null
        } finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
            $plainPassword = $null
            $securePassword.Dispose()
        }
        Write-Output "Created Gitea user: $Username"
    }

    $tokenOutput = @(Invoke-GiteaCli @('admin', 'user', 'generate-access-token', '--username', $Username,
        '--token-name', ('model-cloud-init-' + [guid]::NewGuid().ToString('N')),
        '--scopes', 'write:repository,read:user', '--raw'))
    $tokens = @($tokenOutput | Where-Object { $_ -match '^[0-9a-fA-F]{40}$' })
    if ($tokens.Count -ne 1) { throw 'Could not obtain a Gitea token.' }
    $token = $tokens[0]
    $connection = [ordered]@{url=$GiteaUrl;username=$Username;token=$token}
    [IO.File]::WriteAllText([IO.Path]::GetFullPath($ConnectionFile), ($connection | ConvertTo-Json), [Text.UTF8Encoding]::new($false))
}

$apiHeaders = @{Authorization="token $token"}
$currentUser = Get-GiteaResource '/user'
if ($currentUser.login -ne $Username) { throw 'Token does not belong to the configured Gitea user.' }

# Model repositories (models-<platform-user>) are created by the backend on demand.
# GiteaService.getDefaultCoverImageUrl uses the shared imgs repository on main.
$repositoryPath = "/repos/$Username/imgs"
$repository = Get-GiteaResource $repositoryPath
if (-not $repository) {
    $body = @{name='imgs';description='Model Cloud shared images';private=$false;auto_init=$true;default_branch='main'} | ConvertTo-Json
    $repository = Invoke-RestMethod -Method Post -Uri "$GiteaUrl/api/v1/user/repos" -Headers $apiHeaders -ContentType 'application/json' -Body $body -TimeoutSec 30
}
if ($repository.default_branch -ne 'main') {
    throw 'The existing imgs repository must use main. Check its branches manually; no branches were changed.'
}

$coverPath = "$repositoryPath/contents/default-cover-img.png"
$cover = Get-GiteaResource ($coverPath + '?ref=main')
if (-not $cover -and $coverBytes) {
    $body = @{branch='main';message='Initialize default model cover';content=[Convert]::ToBase64String($coverBytes)} | ConvertTo-Json
    Invoke-RestMethod -Method Post -Uri "$GiteaUrl/api/v1$coverPath" -Headers $apiHeaders -ContentType 'application/json' -Body $body -TimeoutSec 30 | Out-Null
} elseif (-not $cover) {
    Write-Warning 'Default cover is absent. Run again with -CoverImage <PNG path> to initialize it.'
}

Write-Output "Gitea initialization complete: $Username/imgs. Existing user credentials and files were preserved."
Write-Output "Connection details saved to $ConnectionFile (default *.local file is ignored by Git)."
Write-Output 'Set GITEA_USERNAME, GITEA_TOKEN and GITEA_PASSWORD for the backend process; set model-cloud.gitea.url to the saved URL.'
