function [ yA,flag ] = layerAssign( D,auxD,auxpreSucc )
%SLICEASSIGN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%���ÿ���ڵ㵽�����ı����ڵĲ�� 
yA=zeros(2,size(auxD,2));
flag=zeros(1,size(auxD,2));
for i=1:size(auxD,2)
        yA(1,i)=i;%��һ��Ϊ�ڵ��
end
yA(2,1)=1;%��һ��
flag(1)=1;

%��ʼ�ڵ��ֱ�Ӻ������
for i=1:length(auxpreSucc{2,1})%auxpreSucc{2,1}(1,i)�����
        yA(2,auxpreSucc{2,1}(1,i))=yA(2,1)+1;
        flag(auxpreSucc{2,1}(1,i))=1;
end

while(flag(size(D,2))==0)%�ս��û�б����
        PS=[];%��ʾ�Լ�û����ǣ�ǰ��������ǵĽڵ�
        for i=2:size(auxD,2)
                if(flag(i)==0&&all(flag(auxpreSucc{1,i}))==1)
                        PS(end+1)=i;
                end
        end
        
        for i=1:length(PS)%PS(i)�ڵ㴦��
                pre=auxpreSucc{1,PS(i)};
                yA(2,PS(i))=min(yA(2,pre))+1;%����ǰ������С�Ĳ�����1��
                flag(PS(i))=1;
        end
end
end

