function [ PCP ] = searchPcp( preSucc,rank )
%SEARCHPCP 此处显示有关此函数的摘要
%本函数完成一些初始化和结束后的一些恢复性动作，这些动作不能够递归调用
%PCP是一个元胞数组.感觉是深度优先
%i的初始值等于1
%flag的初始值首节点为1
%   此处显示详细说明
flag=zeros(1,length(rank));
flag(1)=1;
rank(end)=1;
PCP=cell(0,0);
i=1;
[ PCP ] = searchPcpith(i,preSucc,rank,flag,PCP);
PCP{2,1}(1,end+1)=1;%把根节点加进去 
PCP{2,1}=sort(PCP{2,1});%将根节点所在的元胞矩阵重新排序
rank(end)=0;%rank尾节点重新置为1





