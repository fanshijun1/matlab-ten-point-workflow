function [ PCP ] = searchPcpith( x,preSucc,rank,flag,PCP )
%SEARCHPCPITH �˴���ʾ�йش˺�����ժҪ
%���ܾ��ǵ�x���ڵ��PCP��Ѱ�ң�����ͨ���ݹ���ð�x�ڵ�֮���ȫ�����;��ȫ����Algorithm2��д��
%   �˴���ʾ��ϸ˵��

    a=searchCS(x,preSucc,rank, flag);%���ڵ�1�������

    
    %��ʼ��һ��PCP��
    while a>0
        PCP{1,end+1}=[size(PCP,2)+1];%size ��ڶ�ά�Ĵ�С
        PCP{2,end}=[];
        %PCP{2,1}(1,1)=1;


        %��һ��PCP�Ĺ���
        while a>0
            PCP{2,end}(1,end+1)=a;
            flag(a)=1;  
            a=searchCS(a,preSucc,rank, flag);
        end
        
        %ͨ���ݹ���������һ֧·�ϵ�����PCP
        %ӦΪ�ڵ����٣��ڸ�����������⣬����x=4 ��ȥ֮��������6.9.10���PCP���Ӷ��ڸ���x=8ʱ��
        %����PCP{2,end}�Ѿ����ǡ�4.8�������[6,9,10]
        
        for j=1:length(PCP{2,end})
            [ PCP ]=searchPcpith(PCP{2,end}(1,j),preSucc,rank,flag,PCP);
        end 
        
        %�ҵ����ڵ����һ����ڣ�������̽ڵ�
        a = searchCS(x,preSucc,rank, flag);
    end
    
end


