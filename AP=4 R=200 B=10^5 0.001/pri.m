function [rank]=pri(K,Vq,Transtimeq,I)
%RANK �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
rank=zeros(1,size(Transtimeq,2));
rank(length(I)+2)=0;
for i=1:size(K{1,length(I)+2},2)
    rank(K{1,length(I)+2}(1,i))=Vq(K{1,length(I)+2}(1,i));
end %��ʼ����exit��ǰ������ֱ�Ӹ���rank
while rank(1)==0
      rank1=zeros(1,size(Transtimeq,2));%��ʱ��rank����ֱֹ�������rank ��ɵ�forѭ���ĸı�
      temp2=[];
      for i=1:size(find(rank),2)
          temp=find(rank);% �ҳ�rank���Ѿ���Ϊ���
          temp1=K{1,temp(i)};% �ҳ����е�i�ڵ��ǰ��
          temp2(end+1:end+length(temp1))=temp1;
      end
          temp3=unique(temp2);%ǰ���и���Ԫ�ط���temp3��������У�ȥ�أ�
      temp7=[];
      for t=1:length(temp3)
          if rank(temp3(t))==0
             temp7(end+1)=temp3(t);% ������[temp7 temp3(t)] 
          end
      end% ȥ������ǰ�����Ѿ������rank��ǰ��
      for j=1:size(temp7,2)
          temp4=K{2,temp7(1,j)};% ǰ����j�ڵ�ĺ���������������
          temp5=zeros(1,size(temp4,2));
               for k=1:size(temp4,2)
                   temp5(k)=rank(temp4(k));%�������������rankȡ�� ��Ϊ��һ���е��Ƿ�������׼��
               end         
          if all(temp5)==1
             temp6=zeros(1,size(temp5,2));
             for l=1:size(temp5,2)
                 
                 temp6(l)=temp5(l)+Transtimeq(temp7(j),temp4(l));
             end % ��������temp5��Ϊ��ʽ�п��ԱȽϵ�
                 rank1(temp7(j))=Vq(temp7(j))+max(temp6);
          end
      end %���size��temp7��2���Σ����¼������rankװ��rank1��
      rank=rank1+rank;
end
end

