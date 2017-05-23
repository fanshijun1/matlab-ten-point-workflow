function [ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc )
%SEARCHLONGESTPATH 此处显示有关此函数的摘要
%   此处显示详细说明
entry=1;%初始节点的位置
exit=size(D,2);%终结点的位置
L=zeros(1,size(auxD,2));%每个节点的最长路径的标记值
flag=zeros(1,size(auxD,2));
auxET=I/(Scu/K);%加上虚拟节点的计算时间
auxTT=auxD/B;%加上虚拟节点的传输时间

L(exit)=0;
flag(exit)=1;
%终结点的直接前驱集合
predexit=auxpreSucc{1,exit};
for i=1:length(predexit)
        L(predexit(i))=dM(predexit(i))+auxET(predexit(i));      
        flag(predexit(i))=1;
end

while(flag(entry)==0)
        %find the task set PS
        PS=[];
        for i=1:size(auxD,2)
                %如果此节点没有被标记且后继节点全部被标记，则此节点加入PS
                if(flag(i)==0&&all(flag(auxpreSucc{2,i}))==1)
                        PS(end+1)=i;
                end
        end
        %处理PS中的节点
        for i=1:length(PS)%PS(i)              
                %PS(i)节点的后继
                succPSI=auxpreSucc{2,PS(i)};
                %每一个后继节点到PS(i)节点的等待加传输延迟的集合
                succDelay=zeros(1,size(auxD,2));
                for j=1:length(succPSI)%succPSI(j)
                        succDelay(succPSI(j))=dE(PS(i),succPSI(j))+auxTT(PS(i),succPSI(j))+L(succPSI(j));
                end           
                L(PS(i))=dM(PS(i))+auxET(PS(i))+max(succDelay);
                flag(PS(i))=1;
        end
        
end
end

