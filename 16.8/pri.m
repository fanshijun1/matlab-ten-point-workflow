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
rank=zeros(1,length(I));
preTT = zeros(1,length(I));
rank(length(I))=0;
tempi=[length(I)];%tempi表示已被求出rank的一层任务节点，广度优先的算法，一层一层的求，不需要担心后继结点没有标记，
temp=[];
while(rank(1)==0)
   for i =1:length(tempi)
      tempj=preSucc{1,tempi(i)};%tempj表示正在求的这一层节点组成的数组；
      for j = 1:length(tempj)
          tempk=preSucc{2,tempj(j)};%tempk表示所求的节点的后驱组合成的数组；
          for k =1:length(tempk)
              if(rank(tempk(k))~=0) %j节点的前驱全部被标记
              preTT(k)=TT(tempj(j),tempk(k))+rank(tempk(k));%注意i，j，k都是数组序号，tempi(i)才是具体的值
              end
          rank(tempj(j))=ET(tempj(j))+max(preTT(k));% TT(i,x)+rank(x)=preTT[x]
          end
          temp=[temp tempj];%temp临时存储这一次迭代所求的节点，在下一次大循环中就是新的已经求出的tempi
      end
   end
   tempi=unique(temp);
end
     




  