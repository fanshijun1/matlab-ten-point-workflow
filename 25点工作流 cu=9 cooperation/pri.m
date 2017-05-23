function [ rank ] = pri(preSucc,I,Scu,K,D,B )
% %PRI 此处显示有关此函数的摘要
% preSuc： 元胞数组，第一行存储前驱节点下标矩阵，第二行存储后驱节点下标矩阵；
%   I:     每个任务的计算量；
%  Scu:    每个计算单元CU的计算能力；
%  K:      每个计算单元CU有K个刀片可以接入；
%  D:      不同任务节点之间的数据传输量矩阵；
%  B:      节点之间的传输速率；
% Sslice：Sslice=Scu/K为单个刀片的计算能力，MIPS
%  ET：    ET=I/Sslice为每个任务的计算执行时间 execution time；
% TT：    TT=D/B 为不同任务之间的数据传输时间 transimision time；
% rank:   表示各节点的权值。
% %   此处显示详细说明
Sslice=Scu/K;
ET=I/Sslice;
TT=D/B;
flag=zeros(1,length(I));%求出rank值的标记为1
rank=zeros(1,length(I));
rank(length(I))=0;
flag(length(I))=1;
for i=1:length(preSucc{1,length(I)})%preSucc{1,length(I)}(1,i)->length(I)
        rank(preSucc{1,length(I)}(1,i))=ET(preSucc{1,length(I)}(1,i));
        flag(preSucc{1,length(I)}(1,i))=1;
end

while(flag(1)==0)
        %find the task 1.自己没有被标记。2.后驱全部被标记。放到PS集合中
        PS=[];
        for i=1:length(I)
                if(flag(i)==0&&all(flag(preSucc{2,i}))==1)
                        PS(end+1)=i;
                end
        end
        
        for i=1:length(PS)%PS(i)->succ(j)
                succ=preSucc{2,PS(i)};
                succTT=[];
                for j=1:length(succ)
                        succTT(end+1)=TT(PS(i),succ(j))+rank(succ(j));
                end
                rank(PS(i))=ET(PS(i))+max(succTT);
                flag(PS(i))=1;
        end

end
     




  