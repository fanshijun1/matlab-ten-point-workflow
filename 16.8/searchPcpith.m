function [ PCP ] = searchPcpith( x,preSucc,rank,flag,PCP )
%SEARCHPCPITH 此处显示有关此函数的摘要
%功能就是第x个节点的PCP的寻找，并且通过递归调用把x节点之后的全部求出;完全按照Algorithm2编写；
%   此处显示详细说明

    a=searchCS(x,preSucc,rank, flag);%根节点1的最大后继

    
    %初始化一个PCP组
    while a>0
        PCP{1,end+1}=[size(PCP,2)+1];%size 求第二维的大小
        PCP{2,end}=[];
        %PCP{2,1}(1,1)=1;


        %求一个PCP的过程
        while a>0
            PCP{2,end}(1,end+1)=a;
            flag(a)=1;  
            a=searchCS(a,preSucc,rank, flag);
        end
        
        %通过递归调用求出这一支路上的所有PCP
        %应为节点数少，掩盖了这里的问题，当从x=4 进去之后，生成了6.9.10这个PCP，从而掩盖了x=8时候
        %进入PCP{2,end}已经不是【4.8】变成了[6,9,10]
        
        for j=1:length(PCP{2,end})
            [ PCP ]=searchPcpith(PCP{2,end}(1,j),preSucc,rank,flag,PCP);
        end 
        
        %找到根节点的下一个入口，即最大后继节点
        a = searchCS(x,preSucc,rank, flag);
    end
    
end


