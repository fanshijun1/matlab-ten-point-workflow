function [ PCP] = searchPcp( preSucc,rank )
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
tempPCP=cell(0,0);%��ʾ��layer_num���PCP{2,end},��Ϊ���ҵ���֮��PCP�Ѿ�����ԭ����PCP��
i=1;
layer_num=0;%��ʾ�ݹ���õĲ�����������Ϊ��һ��
[ PCP ,layer_num,flag] = searchPcpith(i,layer_num,preSucc,rank,flag,PCP,tempPCP);
PCP{2,1}(1,end+1)=1;%�Ѹ��ڵ�ӽ�ȥ 
PCP{2,1}=sort(PCP{2,1});%�����ڵ����ڵ�Ԫ��������������
rank(end)=0;%rankβ�ڵ�������Ϊ0





