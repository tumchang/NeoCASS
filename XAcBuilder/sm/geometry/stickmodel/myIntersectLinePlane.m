function [C,t]=myIntersectLinePlane(A,B,P,n,PLOT)

% close all, clear all, clc
% P=[0 0 0]';
% n=[1 0 1]';
% 
% A=[ 1 -2  3]';
% B=[-1  2 -2]';
%figure, hold on, axis equal

L=(B-A)'*n;
l=(P-A)'*n;

t=l/L;

C=(B-A)*t+A;


if PLOT
    plot3([A(1) B(1)],[A(2) B(2)],[A(3) B(3)],'-o')
    plot3([A(1) C(1)],[A(2) C(2)],[A(3) C(3)],'-o','linewidth',2)
    myPlane(P,n)
end
end


