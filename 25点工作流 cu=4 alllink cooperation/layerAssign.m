function [ yA,flag ] = layerAssign( D,auxD,auxpreSucc )
%SLICEASSIGN 此处显示有关此函数的摘要
%   此处显示详细说明
%标记每个节点到后驱的边所在的层次 
yA=zeros(2,size(auxD,2));
flag=zeros(1,size(auxD,2));
for i=1:size(auxD,2)
        yA(1,i)=i;%第一行为节点号
end
yA(2,1)=1;%第一层
flag(1)=1;

%开始节点的直接后驱标记
for i=1:length(auxpreSucc{2,1})%auxpreSucc{2,1}(1,i)这个点
        yA(2,auxpreSucc{2,1}(1,i))=yA(2,1)+1;
        flag(auxpreSucc{2,1}(1,i))=1;
end

while(flag(size(D,2))==0)%终结点没有被标记
        PS=[];%表示自己没被标记，前驱都被标记的节点
        for i=2:size(auxD,2)
                if(flag(i)==0&&all(flag(auxpreSucc{1,i}))==1)
                        PS(end+1)=i;
                end
        end
        
        for i=1:length(PS)%PS(i)节点处理
                pre=auxpreSucc{1,PS(i)};
                yA(2,PS(i))=min(yA(2,pre))+1;%等于前驱中最小的层数加1；
                flag(PS(i))=1;
        end
end
end

