[CmdletBinding()]
param(
    [string]$ContainerName = 'model-cloud-redis',
    [ValidateRange(0, 15)][int]$Database = 0
)

$ErrorActionPreference = 'Stop'

function Invoke-Redis([string[]]$RedisArguments) {
    # -e makes Redis protocol errors produce a failing exit code.
    $dockerArguments = @('exec')
    if ($env:REDISCLI_AUTH) { $dockerArguments += @('--env', 'REDISCLI_AUTH') }
    $dockerArguments += @($ContainerName, 'redis-cli', '--raw', '-e', '-n', "$Database")
    $result = @(& docker @dockerArguments @RedisArguments)
    if ($LASTEXITCODE -ne 0) { throw 'Redis command failed. Check the container and authentication.' }
    return ($result -join "`n").Trim()
}

if ((Invoke-Redis @('PING')) -ne 'PONG') { throw 'Redis PING failed.' }

# The current application only needs expiring captcha keys, not seed records.
# Use a unique, expiring probe and remove only that probe.
$probeKey = 'model-cloud:init:' + [guid]::NewGuid().ToString('N')
try {
    if ((Invoke-Redis @('SET', $probeKey, 'ready', 'NX', 'EX', '30')) -ne 'OK') {
        throw 'Redis write check failed.'
    }
    if ((Invoke-Redis @('GET', $probeKey)) -ne 'ready') { throw 'Redis read check failed.' }
    if ([int](Invoke-Redis @('TTL', $probeKey)) -le 0) { throw 'Redis expiry check failed.' }
} finally {
    Invoke-Redis @('DEL', $probeKey) | Out-Null
}

Write-Output "Redis database $Database is ready. Existing keys were preserved; no seed data is required."
