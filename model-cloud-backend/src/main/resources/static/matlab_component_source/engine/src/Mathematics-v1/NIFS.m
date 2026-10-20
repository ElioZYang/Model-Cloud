function [X,k,I,E] = NIFS(F,x0,el,MAX,DX)
%牛顿迭代法方程求解器
%Newton Iteration Functions Solver
%输入参数
% F    非线性方程组
% n    自变量个数
% x0   自变量初值
% el   迭代误差限
% MAX  最大迭代次数
%输出参数
% n    迭代次数
% I    计算结果
% X    求解自变量向量
%中间变量
% Y   函数解向量
% D   差分求解偏导数自变量小偏差值
% dX  解向量增量
% c   解向量增量修正系数
X=x0;
% 对应OFFDESIGN的残差计算部分
Y=F(X);
n=length(x0);
I=0;
skip=0;
for k=1:MAX
    E=(dot(Y,Y)/n)^0.5;
if(E<=el)
    I=1;
    break;
end
%差分求解函数雅可比矩阵
K=diag(DX*X);
X_ARRAY=repmat(X,1,n)+K;
Y_ARRAY=0*X_ARRAY;
    for i=1:n
        X1=X_ARRAY(:,i);
        Y_ARRAY(:,i)=F(X1);
    end
%     (Y_ARRAY-repmat(Y,1,n))
%     [Y_ARRAY,Y]
%     [X_ARRAY,X]
    JF=(Y_ARRAY-Y)/K;
%求解解向量增量
%解向量增量修正
%求解自变量
X=X-JF\Y;
Y=F(X);
%迭代限制内有解
end
% X=I*X;
if skip==1
    X=x0;
end
end

