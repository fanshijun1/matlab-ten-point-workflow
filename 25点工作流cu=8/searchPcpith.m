function [ PCP,layer_num,flag ] = searchPcpith( x,layer_num,preSucc,rank,flag,PCP ,tempPCP)
%SEARCHPCPITH �˴���ʾ�йش˺�����ժҪ
%���ܾ��ǵ�x���ڵ��PCP��Ѱ�ң�����ͨ���ݹ���ð�x�ڵ�֮���ȫ�����;��ȫ����Algorithm2��д��
%   �˴���ʾ��ϸ˵��
     layer_num=layer_num+1; 
    a=searchCS(x,preSucc,rank, flag);%���ڵ�1�������
        
    %��ʼ��һ��PCP��
    while a>0
        PCP{1,end+1}=[size(PCP,2)+1];%size ��ڶ�ά�Ĵ�С ��������1�������µ�PCP���к�
        PCP{2,end}=[];
        %PCP{2,1}(1,1)=1;


        %��һ��PCP�Ĺ���
        while a>0
            PCP{2,end}(1,end+1)=a;
             flag(a)=1;  
            a=searchCS(a,preSucc,rank, flag);
        end
        
        %ͨ���ݹ���������һ֧·�ϵ�����PCP  
       
        tempPCP{1,layer_num}=PCP{2,end};
        for j=1:length( tempPCP{1,layer_num})
            
            [ PCP ,layer_num,flag]=searchPcpith( tempPCP{1,layer_num}(1,j),layer_num,preSucc,rank,flag,PCP,tempPCP);%�������ú���ֻ����������ǵݹ���ñ���
            
        end 
        
        %�ҵ����ڵ����һ����ڣ�������̽ڵ�
        a = searchCS(x,preSucc,rank, flag);
    end
    layer_num=layer_num-1;
end


