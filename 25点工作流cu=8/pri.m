function [ rank ] = pri(preSucc,I,Scu,K,D,B )
% %PRI �˴���ʾ�йش˺�����ժҪ
% preSuc�� Ԫ�����飬��һ�д洢ǰ���ڵ��±���󣬵ڶ��д洢�����ڵ��±����
%   I:     ÿ������ļ�������
%  Scu:    ÿ�����㵥ԪCU�ļ���������
%  K:      ÿ�����㵥ԪCU��K����Ƭ���Խ��룻
%  D:      ��ͬ����ڵ�֮������ݴ���������
%  B:      �ڵ�֮��Ĵ������ʣ�
% Sslice��Sslice=Scu/KΪ������Ƭ�ļ���������MIPS
%  ET��    ET=I/SsliceΪÿ������ļ���ִ��ʱ�� execution time��
% TT��    TT=D/B Ϊ��ͬ����֮������ݴ���ʱ�� transimision time��
% rank:   ��ʾ���ڵ��Ȩֵ��
% %   �˴���ʾ��ϸ˵��
Sslice=Scu/K;
ET=I/Sslice;
TT=D/B;
flag=zeros(1,length(I));%���rankֵ�ı��Ϊ1
rank=zeros(1,length(I));
rank(length(I))=0;
flag(length(I))=1;
for i=1:length(preSucc{1,length(I)})%preSucc{1,length(I)}(1,i)->length(I)
        rank(preSucc{1,length(I)}(1,i))=ET(preSucc{1,length(I)}(1,i));
        flag(preSucc{1,length(I)}(1,i))=1;
end

while(flag(1)==0)
        %find the task 1.�Լ�û�б���ǡ�2.����ȫ������ǡ��ŵ�PS������
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
     




  