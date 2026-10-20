function INPUT=mc_pmsm_program_input(INPUT)
% Callable scenes receive this bus from their PMSM caller. In an ordinary
% component graph the node is an explicit bus pass-through.
if nargin==0
    error('PMSM:MissingProgramContext','Program input requires the caller INPUT bus.');
end
end
