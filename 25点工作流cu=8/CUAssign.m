function [ taskCU,CUtask,auxtask,auxpreSucc,auxD,TT,I ] = CUAssign( CULink,preSucc,PCP,I,Scu,K,D,B)
%CUASSIGN 此处显示有关此函数的摘要
%taskCU 以task为索引，任务数和下标数一致，用于求TRT,直接包含了虚拟任务
%元胞数组，第一行1-by-2矩阵，分别是任务号和CU号
%             第二行1-by-4矩阵，分别是TRT RRT EST EFT
%CUtask以CU为索引，CU数和下标一致，用于求RRT，直接包含了虚拟任务。
%   第二行是每个CU部署的任务下标组成的矩阵
% auxtask用于记录虚拟节点，auxpreSucc用于记录新的前后驱关系
%部署cu
%  TRT RRT EST EFT （TRSF） 这些都要依赖CU部署来计算，所以不能单独设立EFT函数，且没有递归调用，所以不需要初始化恢复化程序独立出来
%taskCU为所求 行数表示任务按PCP排得一列，列数表CU,内容表示EFT
%若能得到一个表格TRSF，表示不同任务的TRT RRT EST EFT
%CULink表示两个CU之间连通用1，不连通用0
% p表示PCP序数，q表示节点在PCP当中的序数
%   此处显示详细说明
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%初始化变量区域%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CUflag=zeros(1,size(CULink,2));%若cu被标记，则被置1，全被标记则又统一置0
Sslice=Scu/K;
ET=I/Sslice;

%给B赋值
B=zeros(size(CULink));
for n=1:size(CULink,1)
    for m=1:size(CULink,2)
        if(CULink(n,m)==1)
            B(n,m)=10^6;
        else
            B(n,m)=0;
        end
    end
end

%taskCU不考虑虚拟任务的初始化
taskCU=cell(2,length(I));
for i=1:length(I)
    taskCU{1,i}=zeros(1,2);
    taskCU{1,i}(1,1)=i;
    taskCU{2,i}=zeros(1,4);
end

%CUtask的初始化
CUtask=cell(2,size(CULink,1))
for i=1:size(CULink,1)
    CUtask{1,i}=i;
    CUtask{2,i}=[];
end 

auxtask=[];
TT=zeros(size(D));
auxpreSucc=preSucc;
auxD=D;
EFTcand=zeros(1,size(CULink,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%主程序开始%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%对每一组PCP开始部署，主要程序开始

for p=1:size(PCP,2)%p表示PCP个数即是PCPp，这是最外层的一个循环,对每一个PCP
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算EFT(p,n)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for m=1:size(CULink,2)%对每一个CUm
        if(CUflag(m)==0)
            
            for q=1:length(PCP{2,p})%对每一个节点
                taskCU{1,PCP{2,p}(1,q)}(1,2)=m;
                %先计算TRT               
                pre=preSucc{1,PCP{2,p}(1,q)};%找到前驱,p组第q个任务的前驱
                if(any(pre)==1)%前驱不空
                    TRTcand=zeros(1,length(pre));%TRTcand表示各个前驱算出来的EFT+TT
                    for k=1:length(pre)%pre(k)和 PCP{2,p}(1,q)的TRT
                        
                        n=taskCU{1,pre(k)}(1,2);%n->m
                        if(n~=m&&B(n,m)==0&&D(pre(k),PCP{2,p}(1,q))>1)
                             linkPath=findLinkPath( CULink,n,m );
                            TT(pre(k),PCP{2,p}(1,q))=0; 
                            for i=1:(length(linkPath)-2)
                                TT(pre(k),PCP{2,p}(1,q))=TT(pre(k),PCP{2,p}(1,q))+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);                               
                            end                         
                        end
                        if(n~=m&&B(n,m)~=0)
                            TT(pre(k),PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q))/B(n,m);
                        end 
                        if(n==m)
                           TT(pre(k),PCP{2,p}(1,q))=0; 
                        end
                        
                        TRTcand(1,k)=taskCU{2,pre(k)}(1,4)+TT(pre(k),PCP{2,p}(1,q));
                    end
                    taskCU{2,PCP{2,p}(1,q)}(1,1)=max(TRTcand);%TRT到此求出来了
                else
                    taskCU{2,PCP{2,p}(1,q)}(1,1)=0;%TRT等于零
                end
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%接下来求RRT，第q个节点%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               asd=CUtask{2,m};%在一个CUm当中的 任务PCP{2,p}(1,q)之前的任务的集合
               %asd中非虚拟节点的EFT
               taskCU{2,PCP{2,p}(1,q)}(1,2)=0;
               if(q==1)    
                   if(any(asd)==1)
                       RRTcand=zeros(1,length(asd));%asd(j)
                       for j=1:length(asd)
                           if(asd(j)<size(D,1))%确保asd(j)不是虚拟节点
                            RRTcand(1,j)=taskCU{2,asd(j)}(1,4);
                           end
                       end 
                      taskCU{2,PCP{2,p}(1,q)}(1,2)=max(RRTcand);
                   end
                   %同一个PCP中前一个任务的完成时间也是影响RRT的                    
               else
                    taskCU{2,PCP{2,p}(1,q)}(1,2) =taskCU{2,PCP{2,p}(1,q-1)}(1,4); 
               end
              
               
               
               
               %求第q个节点PCP{2,p}(1,q)的EST EFT
              taskCU{2,PCP{2,p}(1,q)}(1,3)=max(taskCU{2,PCP{2,p}(1,q)}(1,1),taskCU{2,PCP{2,p}(1,q)}(1,2));%EST=max(TRT,RRT)
              taskCU{2,PCP{2,p}(1,q)}(1,4)=ET(PCP{2,p}(1,q))+taskCU{2,PCP{2,p}(1,q)}(1,3);%对每一个PCP{2,p}(1,q)求出了EFT
            end%对每一个节点结束，也是对一个PCP结束
            
           
           EFTcand(1,m)=taskCU{2,PCP{2,p}(1,end)}(1,4)%EFTcand等于PCP中最后一个任务的完成时间
        end
    end%对每一个CUm结束
    %如果算出的EFT都相等，则取最小的吗
     sortEFTcand=sort(EFTcand);
     sm=find(EFTcand==sortEFTcand(find(sortEFTcand,1,'first')));
    if length(sm)>1
        sm=sm(1);
    end
      
    
    
       EFTcand=zeros(1,size(CULink,2)); 
%%%%%%%%%%%%%%%%%%%%%%%%%%为分配的PCP计算各个节点的TRSF%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    for q=1:length(PCP{2,p})%对每一个节点
        taskCU{1,PCP{2,p}(1,q)}(1,2)=sm;     
        %先计算TRT               
        pre=preSucc{1,PCP{2,p}(1,q)};%找到前驱,p组第q个任务的前驱
        if(any(pre)==1)%前驱不空
            TRTcand=zeros(1,length(pre));%TRTcand表示各个前驱算出来的EFT+TT
            for k=1:length(pre)%pre(k)和 PCP{2,p}(1,q)的TRT
                n=taskCU{1,pre(k)}(1,2);%n->sm
                if(n~=sm&&B(n,sm)==0&&D(pre(k),PCP{2,p}(1,q))>1)
                    linkPath=findLinkPath( CULink,n,sm );
                    TT(pre(k),PCP{2,p}(1,q))=0; 
                    for i=1:length(linkPath)-2
                        TT(pre(k),PCP{2,p}(1,q))=TT(pre(k),PCP{2,p}(1,q))+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);                               
                    end                         
                end
                if(n~=sm&&B(n,sm)~=0)
                    TT(pre(k),PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q))/B(n,sm);
                end 
                if(n==sm)
                       TT(pre(k),PCP{2,p}(1,q))=0; 
                end
                TRTcand(1,k)=taskCU{2,pre(k)}(1,4)+TT(pre(k),PCP{2,p}(1,q));%完成时间加传输时间
            end
            taskCU{2,PCP{2,p}(1,q)}(1,1)=max(TRTcand);%TRT到此求出来了
        else
            taskCU{2,PCP{2,p}(1,q)}(1,1)=0;%TRT等于零
        end
        %开始计算RRT
      asd=CUtask{2,sm};%在一个CUm当中的 任务PCP{2,p}(1,q)之前的任务的集合
               %asd中非虚拟节点的EFT
               taskCU{2,PCP{2,p}(1,q)}(1,2)=0;
               if(q==1)    
                   if(any(asd)==1)
                       RRTcand=zeros(1,length(asd));%asd(j)
                       for j=1:length(asd)
                           if(asd(j)<size(D,1))%确保asd(j)不是虚拟节点
                            RRTcand(1,j)=taskCU{2,asd(j)}(1,4);
                           end
                       end 
                      taskCU{2,PCP{2,p}(1,q)}(1,2)=max(RRTcand);
                   end
                   %同一个PCP中前一个任务的完成时间也是影响RRT的                    
               else
                    taskCU{2,PCP{2,p}(1,q)}(1,2) =taskCU{2,PCP{2,p}(1,q-1)}(1,4); 
               end



       %求第q个节点PCP{2,p}(1,q)的EST EFT
      taskCU{2,PCP{2,p}(1,q)}(1,3)=max(taskCU{2,PCP{2,p}(1,q)}(1,1),taskCU{2,PCP{2,p}(1,q)}(1,2));%EST=max(TRT,RRT)
      taskCU{2,PCP{2,p}(1,q)}(1,4)=ET(PCP{2,p}(1,q))+taskCU{2,PCP{2,p}(1,q)}(1,3);%对每一个PCP{2,p}(1,q)求出了EFT
    end%对每一个节点结束，也是对一个PCP结束
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%虚拟节点的重新计算%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for q=1:length(PCP{2,p})%对每一个节点                 
        pre=preSucc{1,PCP{2,p}(1,q)};%找到前驱,p组第q个任务的前驱
        if(any(pre)==1)%前驱不空
            for k=1:length(pre)%pre(k)和 PCP{2,p}(1,q)的TRT
                n=taskCU{1,pre(k)}(1,2);%n->sm
                linkPath=findLinkPath( CULink,n,sm );
                if(B(n,sm)==0&&D(pre(k),PCP{2,p}(1,q))>1)%B(n,sm)==0表示不是相邻的节点
                    
                    sub=length(linkPath)-2%sub表示需要补充的虚拟节点的个数
                    for i=1:sub
                        I(end+1)=0;
                        auxtask(end+1)=length(I);
                         %改变前后驱关系以及auxD
                       if(i==1)
                           auxpreSucc{2,pre(k)}(1,find(auxpreSucc{2,pre(k)}==PCP{2,p}(1,q)))=length(I);%pre(k)的后驱换为length（I）
                           auxpreSucc{1,length(I)}=pre(k);
                           auxpreSucc{2,length(I)}=length(I)+1;
                           auxpreSucc{1,PCP{2,p}(1,q)}(1,find(auxpreSucc{1,PCP{2,p}(1,q)}==pre(k)))=length(I);%PCP{2,p}(1,q)的前驱换为虚拟节点
                           if(i==1&&sub==1)
                           auxpreSucc{2,length(I)}=PCP{2,p}(1,q);
                           end
                           auxD(pre(k),end+1)=D(pre(k),PCP{2,p}(1,q));
                           auxD(end+1,pre(k))=D(pre(k),PCP{2,p}(1,q));
                           if(sub==1)
                           auxD(end,PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q));
                           auxD(PCP{2,p}(1,q),end)=D(pre(k),PCP{2,p}(1,q));
                           end
                       end
                       if(i>1&&i<sub)
                            auxpreSucc{1,length(I)}=length(I)-1;
                            auxpreSucc{2,length(I)}=length(I)+1;
                            auxD(end+1,end)=D(pre(k),PCP{2,p}(1,q));
                            auxD(end-1,end+1)=D(pre(k),PCP{2,p}(1,q));
                       end
                        if(i==sub&&sub~=1)
                            auxpreSucc{2,length(I)-1}=length(I);
                            auxpreSucc{1,length(I)}=length(I)-1;
                            auxpreSucc{2,length(I)}=PCP{2,p}(1,q);
                            auxpreSucc{1,PCP{2,p}(1,q)}(1,find(auxpreSucc{1,PCP{2,p}(1,q)}==length(I)-sub+1))=length(I);%i=1时的值换过来，注意是加2
                            
                            auxD(end+1,PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q));
                            auxD(end-1,end+1)=D(pre(k),PCP{2,p}(1,q));
                            auxD(end,end-1)=D(pre(k),PCP{2,p}(1,q));
                            auxD(PCP{2,p}(1,q),end)=D(pre(k),PCP{2,p}(1,q));
                        end
                        %增加辅助taskCUif(n<sm)
                        if(n<=sm)
                        CUtask{2,min(n,sm)+i}(1,end+1)=length(I);%length(I)节点
                        taskCU{1,end+1}=[length(I),min(n,sm)+i];
                        else%如果是4->1,则32节点分配到3CU，33节点分配到2CU
                                CUtask{2,max(n,sm)-i}(1,end+1)=length(I);%length(I)节点
                                taskCU{1,end+1}=[length(I),max(n,sm)-i];
                        end
                       if(i==1)                                  
                           taskCU{2,length(I)}(1,4)= taskCU{2,pre(k)}(1,4)+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);%求出length(I)的完成时间
                           %虚拟任务不需要求资源准备
                           taskCU{2,length(I)}(1,3)=taskCU{2,length(I)}(1,4);
                           taskCU{2,length(I)}(1,1)=taskCU{2,pre(k)}(1,4);
                       else
                           taskCU{2,end}(1,4)=taskCU{2,end-1}(1,4)+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);
                           taskCU{2,end}(1,3)=taskCU{2,end}(1,4);
                           taskCU{2,end}(1,1)=taskCU{2,end-1}(1,4);
                       end
                       
                    end
                end
            end
        end 
    end            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    CUtask{2,sm}(end+1:end+length(PCP{2,p}))=PCP{2,p};
    CUflag(1,sm)=1;
     if(all(CUflag)==1)
        CUflag=zeros(1,size(CULink,2));
     end
end    










