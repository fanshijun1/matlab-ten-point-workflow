function [ PCP,layer_num,flag ] = searchPcpith( x,layer_num,preSucc,rank,flag,PCP ,tempPCP)
%SEARCHPCPITH 此处显示有关此函数的摘要
%功能就是第x个节点的PCP的寻找，并且通过递归调用把x节点之后的全部求出;完全按照Algorithm2编写；
%   此处显示详细说明
     layer_num=layer_num+1; 
    a=searchCS(x,preSucc,rank, flag);%根节点1的最大后继
        
    %初始化一个PCP组
    while a>0
        PCP{1,end+1}=[size(PCP,2)+1];%size 求第二维的大小 ，列数加1，就是新的PCP序列号
        PCP{2,end}=[];
        %PCP{2,1}(1,1)=1;


        %求一个PCP的过程
        while a>0
            PCP{2,end}(1,end+1)=a;
             flag(a)=1;  
            a=searchCS(a,preSucc,rank, flag);
        end
        
        %通过递归调用求出这一支路上的所有PCP  
       
        tempPCP{1,layer_num}=PCP{2,end};
        for j=1:length( tempPCP{1,layer_num})
            
            [ PCP ,layer_num,flag]=searchPcpith( tempPCP{1,layer_num}(1,j),layer_num,preSucc,rank,flag,PCP,tempPCP);%三个调用函数只有这个函数是递归调用本身
            
        end 
        
        %找到根节点的下一个入口，即最大后继节点
        a = searchCS(x,preSucc,rank, flag);
    end
    layer_num=layer_num-1;
end


