function [ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc )
%SEARCHLONGESTPATH �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
entry=1;%��ʼ�ڵ��λ��
exit=size(D,2);%�ս���λ��
L=zeros(1,size(auxD,2));%ÿ���ڵ���·���ı��ֵ
flag=zeros(1,size(auxD,2));
auxET=I/(Scu/K);%��������ڵ�ļ���ʱ��
auxTT=auxD/B;%��������ڵ�Ĵ���ʱ��

L(exit)=0;
flag(exit)=1;
%�ս���ֱ��ǰ������
predexit=auxpreSucc{1,exit};
for i=1:length(predexit)
        L(predexit(i))=dM(predexit(i))+auxET(predexit(i));      
        flag(predexit(i))=1;
end

while(flag(entry)==0)
        %find the task set PS
        PS=[];
        for i=1:size(auxD,2)
                %����˽ڵ�û�б�����Һ�̽ڵ�ȫ������ǣ���˽ڵ����PS
                if(flag(i)==0&&all(flag(auxpreSucc{2,i}))==1)
                        PS(end+1)=i;
                end
        end
        %����PS�еĽڵ�
        for i=1:length(PS)%PS(i)              
                %PS(i)�ڵ�ĺ��
                succPSI=auxpreSucc{2,PS(i)};
                %ÿһ����̽ڵ㵽PS(i)�ڵ�ĵȴ��Ӵ����ӳٵļ���
                succDelay=zeros(1,size(auxD,2));
                for j=1:length(succPSI)%succPSI(j)
                        succDelay(succPSI(j))=dE(PS(i),succPSI(j))+auxTT(PS(i),succPSI(j))+L(succPSI(j));
                end           
                L(PS(i))=dM(PS(i))+auxET(PS(i))+max(succDelay);
                flag(PS(i))=1;
        end
        
end
end

