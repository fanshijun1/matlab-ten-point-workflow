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
rank=zeros(1,length(I));
preTT = zeros(1,length(I));
rank(length(I))=0;
tempi=[length(I)];%tempi��ʾ�ѱ����rank��һ������ڵ㣬������ȵ��㷨��һ��һ����󣬲���Ҫ���ĺ�̽��û�б�ǣ�
temp=[];
while(rank(1)==0)
   for i =1:length(tempi)
      tempj=preSucc{1,tempi(i)};%tempj��ʾ���������һ��ڵ���ɵ����飻
      for j = 1:length(tempj)
          tempk=preSucc{2,tempj(j)};%tempk��ʾ����Ľڵ�ĺ�����ϳɵ����飻
          for k =1:length(tempk)
              if(rank(tempk(k))~=0) %j�ڵ��ǰ��ȫ�������
              preTT(k)=TT(tempj(j),tempk(k))+rank(tempk(k));%ע��i��j��k����������ţ�tempi(i)���Ǿ����ֵ
              end
          rank(tempj(j))=ET(tempj(j))+max(preTT(k));% TT(i,x)+rank(x)=preTT[x]
          end
          temp=[temp tempj];%temp��ʱ�洢��һ�ε�������Ľڵ㣬����һ�δ�ѭ���о����µ��Ѿ������tempi
      end
   end
   tempi=unique(temp);
end
     




  