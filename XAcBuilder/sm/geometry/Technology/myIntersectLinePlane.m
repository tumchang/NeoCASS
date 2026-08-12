function [C,t]=myIntersectLinePlane(A,B,P,n)

close all, clear all, clc
P=[0 0 0]';
n=[1 0 1]';

A=[ 1 -2  3]';
B=[-1  2 -2]';

L=(B-A)'*n;
l=(P-A)'*n;

t=l/L;

C=(B-A)*t+A;


figure, hold on, axis equal
plot3([A(1) B(1)],[A(2) B(2)],[A(3) B(3)],'-o')
plot3([A(1) C(1)],[A(2) C(2)],[A(3) C(3)],'-o','linewidth',2)
% X=[P(1)-1 P(1)+1;...
%    P(1)-1 P(1)+1];
% Y=[P(2) P(2);...
%    P(2) P(2)];
% Z=[P(3)-1   P(3)-1;...
%    P(3)+1   P(3)+1];
% surf(X,Y',Z)
% plot3(P(1),P(2),P(3),'o')
% quiver3(P(1),P(2),P(3),n(1),n(2),n(3))
myPlane(P,n)
end


