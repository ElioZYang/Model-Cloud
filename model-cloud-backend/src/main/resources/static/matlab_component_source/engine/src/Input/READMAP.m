function [MAP]=READMAP(DP)
    READ_COMPONENT % 根据部件配置选择压气机、涡轮特性图，并对流量、转速、压比、效率进行归一化
    READ_MOTOR     % 按显式电机部件数量读取电机图，并读取涡轮发电机配置
end