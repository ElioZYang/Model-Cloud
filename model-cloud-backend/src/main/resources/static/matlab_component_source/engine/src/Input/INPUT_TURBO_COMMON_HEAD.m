function DP = INPUT_TURBO_COMMON_HEAD(DP)
%INPUT_TURBO_COMMON_HEAD Apply the fields shared by every turbo configuration.
% Keep this helper deliberately small: the values and their order mirror the
% first lines of the legacy INPUT_TURBO function.
DP.PRC_outerfan=1;% 外部风扇压比
DP.flow="mixed";% 混排/分排（对于涡扇发动机）
DP.BYPASS_RATIO=0;% 涵道比（对于涡扇发动机）
DP.reheat=0;% 是否打开加力燃烧室
DP.SHAFT_CONTROL=1;
end
