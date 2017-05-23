function [rank]=pri(K,Vq,Transtimeq,I)
%RANK 此处显示有关此函数的摘要
%   此处显示详细说明
rank=zeros(1,size(Transtimeq,2));
rank(length(I)+2)=0;
for i=1:size(K{1,length(I)+2},2)
    rank(K{1,length(I)+2}(1,i))=Vq(K{1,length(I)+2}(1,i));
end %初始化，exit的前驱都先直接给出rank
while rank(1)==0
      rank1=zeros(1,size(Transtimeq,2));%临时的rank，防止直接添加入rank 造成的for循环的改变
      temp2=[];
      for i=1:size(find(rank),2)
          temp=find(rank);% 找出rank中已经不为零的
          temp1=K{1,temp(i)};% 找出其中的i节点的前驱
          temp2(end+1:end+length(temp1))=temp1;
      end
          temp3=unique(temp2);%前驱中各个元素放入temp3这个向量中（去重）
      temp7=[];
      for t=1:length(temp3)
          if rank(temp3(t))==0
             temp7(end+1)=temp3(t);% 或者用[temp7 temp3(t)] 
          end
      end% 去除所有前驱中已经计算出rank的前驱
      for j=1:size(temp7,2)
          temp4=K{2,temp7(1,j)};% 前驱中j节点的后驱具体任务所在
          temp5=zeros(1,size(temp4,2));
               for k=1:size(temp4,2)
                   temp5(k)=rank(temp4(k));%将后驱的任务的rank取出 ，为下一步中的是否有零做准备
               end         
          if all(temp5)==1
             temp6=zeros(1,size(temp5,2));
             for l=1:size(temp5,2)
                 
                 temp6(l)=temp5(l)+Transtimeq(temp7(j),temp4(l));
             end % 将后续的temp5化为公式中可以比较的
                 rank1(temp7(j))=Vq(temp7(j))+max(temp6);
          end
      end %完成size（temp7，2）次，将新计算出的rank装入rank1中
      rank=rank1+rank;
end
end

