function [ PCP ] = searchPcp( preSucc,rank )
%SEARCHPCP �˴���ʾ�йش˺�����ժҪ
%���������һЩ��ʼ���ͽ������һЩ�ָ��Զ�������Щ�������ܹ��ݹ����
%PCP��һ��Ԫ������.�о����������
%i�ĳ�ʼֵ����1
%flag�ĳ�ʼֵ�׽ڵ�Ϊ1
%   �˴���ʾ��ϸ˵��
flag=zeros(1,length(rank));
flag(1)=1;
rank(end)=1;
PCP=cell(0,0);
i=1;
[ PCP ] = searchPcpith(i,preSucc,rank,flag,PCP);
PCP{2,1}(1,end+1)=1;%�Ѹ��ڵ�ӽ�ȥ 
PCP{2,1}=sort(PCP{2,1});%�����ڵ����ڵ�Ԫ��������������
rank(end)=0;%rankβ�ڵ�������Ϊ1





