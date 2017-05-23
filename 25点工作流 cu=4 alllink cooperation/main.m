function [ CU,channel,user,mean_makespan,a,user_num,temp_clock,temp_makespan,task_Queusers,tasktransport_Queusers] = main(taskCU,CUtask, CULink,auxpreSucc,PCP,I,Scu,K,auxD,B )
%MAIN 此处显示有关此函数的摘要
%   此处显示详细说明
%%%%%%%%%%%%%%%%%%%%变量区%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

arrate_array=0.002:0.002:0.02
mean_makespan=zeros(1,length(arrate_array));
for aa=6:6
arrate=arrate_array(aa)
clock=1;
step=1;%步进幅度
USENUM=1000; %表示总的用户数，不是系统容纳的用户数500.

Sslice=Scu/K;
ET=I/Sslice;
user_num=0;
finished_user_flag=zeros(1,USENUM);
temp_makespan=[];%因为clock从1开始
temp_clock=[];%两个temp变量用来画图，看makespan是否收敛
capacity=500;
a=[];
r=[];
%%%%%%%%%%%%%%%
%两个排队用户数信息记录
for i=1:length(I)
        task_Queusers(i).num=[];     
        task_Queusers(i).mean=0;
end

for i=1:length(I)
    for j=1:length(auxpreSucc{2,i})%i->auxpreSucc{2,i}(1,j)
            if(taskCU{1,i}(1,2)~=taskCU{1,auxpreSucc{2,i}(1,j)}(1,2)&&CULink(taskCU{1,i}(1,2),taskCU{1,auxpreSucc{2,i}(1,j)}(1,2))==1)
                    tasktransport_Queusers(i).tasktransport_Queusers(auxpreSucc{2,i}(1,j)).num=[];                    
                    tasktransport_Queusers(i).tasktransport_Queusers(auxpreSucc{2,i}(1,j)).mean=0;
            end
    end
end
%%%%%%%%%%%%%%%%%CU结构体%%%%%%%%%%%%%%%%%
%CU channel user基本都是由id+历史信息+当前任务及剩余量+等待队列及等待量组成
for i=1:size(CULink,2)
    CU(i).id=i;
    CU(i).wait_user=[];
    CU(i).wait_user_num=length(CU(i).wait_user);
    for j=1:K
        CU(i).slice(j).id=[i,j];
        CU(i).slice(j).flag=0;%有当前任务的或为1
        CU(i).slice(j).history_inf=cell(0,0);%元包数组，第一行 用户id 任务id 第二行 进入时间 等待延时 开始计算时间 计算时间 计算完成时间
        CU(i).slice(j).cur_task=[];%[用户id，任务id一位]也就是任务id
        CU(i).slice(j).remain_taskI=0;
        CU(i).slice(j).next_point=1;
        CU(i).slice(j).wait_task_queue=cell(0,0);%[用户id，任务id一位]也就是任务id
        CU(i).slice(j).wait_taskI=0;%等待中任务的计算量的总和
        CU(i).slice(j).wait_task_num=length(CU(i).slice(j).wait_task_queue);        
    end    
end
%%%%%%%%%%%%%%%%%%%channel结构体%%%%%%%%%%%
for i=1:size(CULink,1)
    for j=1:size(CULink,2)
        if (CULink(i,j)==1)
            channel(i).channel(j).exit=1;
            channel(i).channel(j).history_inf=cell(0,0);%元胞数组，第一行 用户id 前驱任务id 后驱任务的id后一位 第二行 进入信道时间 等待延时 传输开始时间 传输时间 传输完成时间
            channel(i).channel(j).cur_task=[];%[用户，前驱任务，后驱任务]
            channel(i).channel(j).remain_taskD=0;%剩余的数据量
            channel(i).channel(j).next_point=1;
            channel(i).channel(j).wait_task_queue=cell(0,0);%[用户，前驱任务，后驱任务]
            channel(i).channel(j).wait_task_num=length(channel(i).channel(j).wait_task_queue);
        end
    end
end
%%%%%%%%%%%%%%%%%user结构体%%%%%%%%%%%%%%%%%
for i=1:USENUM%500个用户
    user(i).id=i;
    user(i).wait_time=0;
    user(i).start_time=0;
    user(i).finish_time=0;
    user(i).makespan=user(i).finish_time-user(i).start_time;
    user(i).finished_task_flag=zeros(1,length(I));%如果后继任务全部传输完成，则标记为1 
    for j=1:length(I)
        user(i).task(j).id=[i,j];        
        user(i).task(j).pre=auxpreSucc{1,j}; %#ok<*AGROW>
        user(i).task(j).succ=auxpreSucc{2,j};
        user(i).task(j).CUAssign=taskCU{1,j}(1,2);
        if(I(j)==0)
            user(i).task(j).isAuxTask=1;            
        else
            user(i).task(j).isAuxTask=0;            
        end
        user(i).task(j).finished_trans_flag=zeros(1,length(I));%后驱传输完成，后驱id位置标记为1
        user(i).task(j).finished_pretrans_flag=zeros(1,length(I));%前区传输完成，前驱位置标记为1
        user(i).task(j).wait_start_time=0;
        user(i).task(j).compute_start_time=0;
        user(i).task(j).wait_delay_time=user(i).task(j).compute_start_time-user(i).task(j).wait_start_time;
        user(i).task(j).compute_finish_time=0;
        user(i).task(j).compute_delay_time=user(i).task(j).compute_finish_time-user(i).task(j).compute_start_time;
        
        for k=1:length(user(i).task(j).succ)%传输时间必须要指出哪个后继
            user(i).task(j).Succ(user(i).task(j).succ(1,k)).id=[i,j,user(i).task(j).succ(1,k)];
            user(i).task(j).Succ(user(i).task(j).succ(1,k)).wait_start_time=0;
            user(i).task(j).Succ(user(i).task(j).succ(1,k)).trans_start_time=0;
            user(i).task(j).Succ(user(i).task(j).succ(1,k)).wait_delay_time=user(i).task(j).Succ(k).trans_start_time-user(i).task(j).Succ(k).wait_start_time;
            user(i).task(j).Succ(user(i).task(j).succ(1,k)).trans_finish_time=0;
            user(i).task(j).Succ(user(i).task(j).succ(1,k)).trans_delay_time=user(i).task(j).Succ(k).trans_finish_time-user(i).task(j).Succ(k).trans_start_time;
            
        end
    end
    user(i).finish_time=user(i).task(length(I)).compute_finish_time;
    user(i).makespan=user(i).finish_time-user(i).start_time;
end
%%%%%%%%%%%在clock此刻，保证这一秒内的任务完成，是前向负责制%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%arrate_queue数组
arrate_queue=zeros(1,USENUM);
arrate_point=1;%用来指向下一个要进入系统的元素
for i=1:length(arrate_queue)
        arrate_queue(i)=i/arrate;%arrate_queue中储存着第i个任务的到达时间
end
%一个时隙的动作从此处的while开始
while(any(arrate_queue)==1||user_num>0)%管到这一秒结束user_num==0且arrate_queue全为零结束
        %赋每一个clock的初始值
       for i=1:length(I)
               if(clock>1)
                task_Queusers(i).num(clock)=task_Queusers(i).num(clock-1);   %增加值的标准是加入队列 ,出队列减一。          
               else
                        task_Queusers(i).num(1)=0;
               end
        end

        for i=1:length(I)
            for j=1:length(auxpreSucc{2,i})%i->auxpreSucc{2,i}(1,j)
                    if(taskCU{1,i}(1,2)~=taskCU{1,auxpreSucc{2,i}(1,j)}(1,2)&&CULink(taskCU{1,i}(1,2),taskCU{1,auxpreSucc{2,i}(1,j)}(1,2))==1)
                        if(clock>1)
                            tasktransport_Queusers(i).tasktransport_Queusers(auxpreSucc{2,i}(1,j)).num(clock)=tasktransport_Queusers(i).tasktransport_Queusers(auxpreSucc{2,i}(1,j)).num(clock-1);                    
                        else
                            tasktransport_Queusers(i).tasktransport_Queusers(auxpreSucc{2,i}(1,j)).num(clock)=0;
                        end
                    end
            end
        end
        for k=arrate_point:length(arrate_queue);
        %%%%%%%%%%%%%%%%部署新任务%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(user_num<capacity&& arrate_queue(k)<=clock)%前五百个用户才能进入              
                    %先看20s的时候,再想从一个时隙跳到另一个时隙，开始和过程都有
                    user(k).id=k;
                    r(end+1)=k;
                    user(k).wait_time=clock-arrate_queue(k);
                    %更新用户数， arrate_queue和 arrate_point
                    user_num=user_num+1
                    arrate_queue(k)=0;
                    arrate_point=arrate_point+1;
                    user(k).finished_task_flag(1,1)=1;
                    succ=[];%succ 是首节点的后继节点
                    succ= user(k).task(1).succ;
                    SLICEcand=[];
                    SLICE=0;
                    for i=1:length(succ)
                        CUAssign=user(i).task(succ(i)).CUAssign;
                        for j=1:K
                            SLICEcand(1,j)=CU(CUAssign).slice(j).wait_taskI;
                        end
                        SLICE=min(find(min(SLICEcand)==SLICEcand));%最小.wait_taskI;值的下标
                       %加入等待队列
                       CU(CUAssign).slice(SLICE).wait_task_queue{1,end+1}=user(k).task(succ(i)).id;
                       task_Queusers(succ(i)).num(clock)= task_Queusers(succ(i)).num(clock)+1;
                       CU(CUAssign).slice(SLICE).wait_taskI=CU(CUAssign).slice(SLICE).wait_taskI+I(succ(i));
                       CU(CUAssign).slice(SLICE).history_inf{1,end+1}=user(k).task(succ(i)).id;
                       CU(CUAssign).slice(SLICE).history_inf{2,end}(1,1) =clock;
                       user(k).task(succ(i)).wait_start_time=clock;
                       user(k).task(1).finished_trans_flag(1,user(k).task(1).succ(1,i))=1;
                       user(k).task(succ(1,i)).finished_pretrans_flag(1,1)=1;                      
                   end
                    user(k).start_time=clock;           
                    user(k).task(1).wait_start_time=clock;
                    CU(user(k).task(1).CUAssign).slice(SLICE).history_inf{1,end+1}=user(k).task(1).id;
                    CU(user(k).task(1).CUAssign).slice(SLICE).history_inf{2,end}(1,1)=clock;                
            end
        end
%%%%%%%%%%%%%%%%%%计算量递减%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:size(CULink,2)
        for j=1:K
            %计算量的消减
            %初始化刀片
            %此是三个if分支的第一个分支，完成两个任务 1是虚拟节点入信道，2是实节点入刀片
            if(CU(i).slice(j).remain_taskI==0)
                if(isempty(CU(i).slice(j).wait_task_queue)==0)
                   %第1部分虚节点入信道
                    %更新当前任务           circle表示扫描一圈就可以结束循环了，不要陷入死循环 
                    %这部分是将虚拟节点直接对它的后驱循环，放入对应的信道当中，circle用来防止等待队列只有虚拟节点，则不能够通过节点的计算量不等于零来结束循环；
                    circle=0;
                    while(circle<length(CU(i).slice(j).wait_task_queue)&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))==0)%如果是虚拟节点，计算量为零，直接部署到通信信道，并挑下一个任务
                            %更新信道的等待任务队列,。对每一个后继所在的CU，跟新信道的等待队列
                            if(isempty(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)==0)
                                    for k=1:length(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).wait_task_queue{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];
                                            if(i~=user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign)
                                                tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock) =tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock)+1;
                                            end
                                            %更新信道历史信息
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];                                            
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{2,end}(1,1)=clock;
                                            %更新用户的传输等待开始信息
                                            user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).Succ(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).wait_start_time=clock;
                                    end 
                                    %将此虚拟节点从计算等待队列删掉
                                       CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];
                                      %跟新next_point
                                    if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                                       CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                                   else
                                       CU(i).slice(j).next_point=1;
                                   end
                            end
                            circle=circle+1;
                    end
                    %第2部分 实节点进刀片
                   %如果不是虚拟节点，即是计算量不为零.。更新当前的计算任务
                   %如果去除虚拟节点之后等待队列不空，且是非虚拟节点，则加入到当前任务
                   %这里是等待任务量为零的条件下的第二个分支。第一个分支是处理了虚拟节点，直接加上后继节点进入传输信道，一次处理完next_point所指向的所有虚拟节点，因为只有指向非虚拟节点后并加入到当前的任务后，这个刀片才能在下一秒进行计算
                   %                                                                       第二个分支是处理实节点，将其选择到当前任务    
                    if(isempty(CU(i).slice(j).wait_task_queue)==0&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))~=0)
                            %更新当前任务，剩余计算量增加，等待队列删除此任务，等到任务量减少
                            CU(i).slice(j).cur_task=CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point};
                            task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)= task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)-1;
                            CU(i).slice(j).remain_taskI=I(CU(i).slice(j).cur_task(1,2));
                            CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];%删除这个元素以及位置
                            CU(i).slice(j).wait_taskI=CU(i).slice(j).wait_taskI-I(CU(i).slice(j).cur_task(1,2));
                            %更新next_point
                           if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                               CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                           else
                               CU(i).slice(j).next_point=1;
                           end
                           %更新刀片历史信息，计算开始时间和等待延时
                            CU(i).slice(j).history_inf{2,end}(1,3)=clock;
                            CU(i).slice(j).history_inf{2,end}(1,2)=CU(i).slice(j).history_inf{2,end}(1,3)-CU(i).slice(j).history_inf{2,end}(1,1); 
                            %更新用户历史信息，计算开始时间和等待延时
                           user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time=clock;
                           user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_delay_time=user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time-user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_start_time;
                    end
                end
            
            %一个任务计算结束，另一个任务计算开始
            %这是计算量削减的第二个分支，elseif这样的结构表示三个条件结构只能进一个结构
            %总共有四块内容，前两块是处理旧任务，后两块处理新任务
            %1，旧任务的历史信息的更新，包括计算完成时间，计算用时；2.旧任务加其后继节点放入到通信排队队列当中
            %3.新任务的虚拟节点的处理（同上一个分支）；4.新任务实节点的处理（同上一个任务）
            %第2。3个部分是信道队列的入口，2是实节点入传输信道，3，是虚拟节点入传输信道
            elseif(CU(i).slice(j).remain_taskI>0&&CU(i).slice(j).remain_taskI<=Sslice*step)
                    
            %第1部分旧节点历史信息更新
                %求出已经耗费的时间consume_time
                consume_time= CU(i).slice(j).remain_taskI/Sslice*step;
                %剩余任务量清零，标志当前任务的结束
                CU(i).slice(j).remain_taskI=0;
               
                %刀片历史信息更新 计算完成时间 和计算用时
                CU(i).slice(j).history_inf{2,end}(1,5)=clock-1+consume_time;
                CU(i).slice(j).history_inf{2,end}(1,4)=CU(i).slice(j).history_inf{2,end}(1,5)-CU(i).slice(j).history_inf{2,end}(1,3);
                
                 %用户计算信息更新 计算完成时间 和计算用时
                user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_finish_time=clock-1+consume_time;
                user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_delay_time=user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_finish_time-user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time;
                
             %第2部分旧节点加后继节点进入信道
                %当前任务进入通信排队，且只能在下一秒结束的时候参与轮巡的机会
                %实节点进入通信的入口
                for k=1:length(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ)
                     %更新信道等待队列，将当前任务加到后继所对应的等待队列当中，注意信道没有竞争条件，CU到CU只有一个信道；
                    channel(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign).channel(user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign).wait_task_queue{1,end+1}=[CU(i).slice(j).cur_task,user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)]; 
                    if(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign~=user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign)
                         tasktransport_Queusers(CU(i).slice(j).cur_task(1,2)).tasktransport_Queusers(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).num(clock)= tasktransport_Queusers(CU(i).slice(j).cur_task(1,2)).tasktransport_Queusers(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).num(clock)+1;
                    end
                    %更新信道历史信息，id和传输等待开始时间；
                    channel(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign).channel(user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign).history_inf{1,end+1}=[CU(i).slice(j).cur_task,user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)];
                    channel(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign).channel(user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign).history_inf{2,end}(1,1)=clock-1+consume_time;
                    %更新用户的传输等待开始时间
                    user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).Succ(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).wait_start_time=clock-1+consume_time; 
                end
                %清空当前任务
                CU(i).slice(j).cur_task=[];
              %第3部分，虚拟节点越过刀片进入信道
                %下一个任务进入当前任务
                if(isempty(CU(i).slice(j).wait_task_queue)==0)
                       circle=0;
                       while(circle<length(CU(i).slice(j).wait_task_queue)&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))==0)%如果是虚拟节点，计算量为零，直接部署到通信信道，并挑下一个任务
                            %更新信道的等待任务队列,。对每一个后继所在的CU，跟新信道的等待队列
                            if(isempty(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)==0)
                                    for k=1:length(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).wait_task_queue{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];
                                             if( i~=user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign)
                                                    tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock)=  tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock)+1;
                                             end
                                            %更新信道历史信息
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];                                            
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{2,end}(1,1)=clock;
                                            %更新用户的传输等待开始信息
                                            user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).Succ(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).wait_start_time=clock;
                                    end 
                                   CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];                               
                                   %跟新next_point
                                    if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                                       CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                                   else
                                       CU(i).slice(j).next_point=1;
                                   end
                            end
                              circle=circle+1;
                       end
                   %第4部分 实节点进入刀片
                        %条件是等待队列不空，且是实节点
                         if(isempty(CU(i).slice(j).wait_task_queue)==0&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))~=0)%如果不是虚拟节点，即计算量不为零.。更新当前的计算任务
                                 %更新当前任务，剩余计算量增加，等待队列删除此任务，等到任务量减少
                                CU(i).slice(j).cur_task=CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point};
                                task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)= task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)-1;
                                remain_time=step-consume_time;
                                CU(i).slice(j).remain_taskI=I(CU(i).slice(j).cur_task(1,2))-remain_time*Sslice;
                                CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];%删除这个元素以及位置
                                CU(i).slice(j).wait_taskI=CU(i).slice(j).wait_taskI-I(CU(i).slice(j).cur_task(1,2));
                                %更新next_point
                               if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                                   CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                               else
                                   CU(i).slice(j).next_point=1;
                               end
                                 %更新刀片历史信息，计算开始时间和等待延时
                              CU(i).slice(j).history_inf{2,end}(1,3)=clock;
                              CU(i).slice(j).history_inf{2,end}(1,2)=CU(i).slice(j).history_inf{2,end}(1,3)-CU(i).slice(j).history_inf{2,end}(1,1); 
                              %更新用户历史信息，计算开始时间和等待延时
                             user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time=clock;
                             user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_delay_time=user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time-user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_start_time;
                             
                         end%加实节点结束 4部分结束
                end%加新节点结束 3,4部分结束

            %第三个if分支 如果剩余计算量多于一次可以削减的计算量
            else
                CU(i).slice(j).remain_taskI=CU(i).slice(j).remain_taskI-Sslice*step;            
            end %三个分支全部结束       
        end%十个刀片循环结束
    end%四个CU循环结束

%%%%%%%%%%%%%数据传输递减%%%%%%%%%%%%%%%%%%%%%%    
    for i=1:size(CULink,1)
        for j=1:size(CULink,2)
            if (CULink(i,j)==1)
            %如果是在同一个CU的当中，则不需要传输。1.终结点的处理，不需要再回到刀片；2.非终结点的处理，信息更新，后继节点回到刀片；
                if(i==j)%总共就三种形式 4->8 6->9 8->9  9->10 (在终结点中处理)
                        if(isempty(channel(i).channel(j).wait_task_queue)==0)
                               waitQueue=channel(i).channel(j).wait_task_queue;
                                for m=1:length(waitQueue)
                                      curTask=waitQueue{1,m};
                                      user(curTask(1,1)).task(curTask(1,2)).finished_trans_flag(1,curTask(1,3))=1;
                                      user(curTask(1,1)).task(curTask(1,3)).finished_pretrans_flag(1,curTask(1,2))=1;
                                      if(all( user(curTask(1,1)).task(curTask(1,2)).finished_trans_flag(user(curTask(1,1)).task(curTask(1,2)).succ))==1)
                                              user(curTask(1,1)).finished_task_flag(curTask(1,2))=1;%如果所有的向后驱传输任务都结束了，那么前驱任务才算真正结束了
                                      end
                                      %如果是终结点
                                      if(auxD(curTask(1,2), curTask(1,3))==1)                                              
                                               user(curTask(1,1)).finished_task_flag(1,curTask(1,3))=1;
                                               if(curTask(1,3)==27)
                                                       user_num=user_num-1
                                                       a(end+1)=curTask(1,1);
                                               end
                                               user(curTask(1,1)).finish_time=clock;  
                                               user(curTask(1,1)).makespan=user(curTask(1,1)).finish_time-user(curTask(1,1)).start_time;
                                               finished_user_flag(curTask(1,1))=1;
                                               %等待队列中删除此任务
                                               channel(i).channel(j).wait_task_queue(:,1)=[];
                                              %用户传输时间的更新
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time=clock;                                              
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time=clock
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time- user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time=clock; 
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time-user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time;
                                      else
                       
                                              %更新用户传输信息
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time=clock;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time=clock;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time- user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time=clock; 
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time-user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time;
                                               %删除等待队列中的此任务
                                               channel(i).channel(j).wait_task_queue(:,1)=[];
                                               %很重要的计算等待任务队列的更新
                                              %若此后继节点的所有前区都标记完成传输，则将这个节点加入到等待队列，说明此节点是最后一个前驱任务                             
                                              %后继节点加入到计算刀片
                                              curTask(:,2)=[];
                                              if(all(user(curTask(1,1)).task(curTask(1,2)).finished_pretrans_flag(user(curTask(1,1)).task(curTask(1,2)).pre))==1)
                                                    %选择wait_taskI最小的刀片
                                                     CUAssign=user(curTask(1,1)).task(curTask(1,2)).CUAssign;  
                                                     SLICEcand=[];
                                                     SLICE=0;
                                                    for k=1:K
                                                        SLICEcand(1,k)=CU(CUAssign).slice(k).wait_taskI;
                                                    end
                                                    SLICE=min(find(min(SLICEcand)==SLICEcand));%最小.wait_taskI;值的下标
                                                   %加入完成队列
                                                   CU(CUAssign).slice(SLICE).wait_task_queue{1,end+1}=curTask;
                                                   task_Queusers(curTask(1,2)).num(clock)= task_Queusers(curTask(1,2)).num(clock)+1;
                                                   CU(CUAssign).slice(SLICE).wait_taskI=CU(CUAssign).slice(SLICE).wait_taskI+I(curTask(1,2));               
                                                   CU(CUAssign).slice(SLICE).history_inf{1,end+1}=curTask;
                                                   CU(CUAssign).slice(SLICE).history_inf{2,end}(1,1)=clock-1+consume_time;
                                                   user(curTask(1,1)).task(curTask(1,2)).wait_start_time=clock-1+consume_time;

                                            end%后继节点加入计算刀片结束
                                      end
                                end %对每一个队列元素处理结束                               
                                channel(i).channel(j).remain_taskD=0;    
                        end%队列不空条件结束
                else%结束if（i==j）；开始if(i~=j)
                        %初始化信道的作用
                        if(channel(i).channel(j).remain_taskD==0)%初始化的作用
                            if(isempty(channel(i).channel(j).wait_task_queue)==0)                   
                                %换当前的通信任务
                                channel(i).channel(j).cur_task=channel(i).channel(j).wait_task_queue{1,channel(i).channel(j).next_point};                                                         
                                tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;
                                channel(i).channel(j).remain_taskD=auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3));
                                channel(i).channel(j).wait_task_queue(:, channel(i).channel(j).next_point)=[];
                                  while(isempty( channel(i).channel(j).wait_task_queue)==0&&auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3))==0)
                                       user(channel(i).channel(j).cur_task(1,1)).finish_time=clock-1+consume_time;

                                         %更新next_point
                                        if(channel(i).channel(j).next_point<length(channel(i).channel(j).wait_task_queue))
                                            channel(i).channel(j).next_point=channel(i).channel(j).next_point+1;
                                        else
                                            channel(i).channel(j).next_point=1;
                                        end
                                        channel(i).channel(j).cur_task=channel(i).channel(j).wait_task_queue{1,channel(i).channel(j).next_point}; 
                                        tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;                               tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;
                                        channel(i).channel(j).remain_taskD=auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3));
                                        channel(i).channel(j).wait_task_queue(:, channel(i).channel(j).next_point)=[];                               
                                end
                                %更新当前任务的历史信息 传输开始时间
                                channel(i).channel(j).history_inf{2,end}(1,3)=clock;
                                channel(i).channel(j).history_inf{2,end}(1,2)= channel(i).channel(j).history_inf{2,end}(1,3)- channel(i).channel(j).history_inf{2,end}(1,1);
                                 %更新等待队列，删除


                                %更新next_point
                                if(channel(i).channel(j).next_point<length(channel(i).channel(j).wait_task_queue))
                                    channel(i).channel(j).next_point=channel(i).channel(j).next_point+1;
                                else
                                    channel(i).channel(j).next_point=1;
                                end
                                %更新用户信息
                                %更新用户通信信息
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time=clock;         
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_start_time;
                                %更新用户计算信息
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time=clock;
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                            end

                        %通信数据的削减外加当前用户的更换
                        elseif(channel(i).channel(j).remain_taskD>0&&channel(i).channel(j).remain_taskD<=B*step)
                            %上一个传输任务的处理
                            consume_time=channel(i).channel(j).remain_taskD/B;
                            channel(i).channel(j).remain_taskD=0; 
                            %任务完成标志置1
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(1,channel(i).channel(j).cur_task(1,3))=1;
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,3)).finished_pretrans_flag(1,channel(i).channel(j).cur_task(1,2))=1; 
                            if(all( user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).succ))==1)
                                  user(channel(i).channel(j).cur_task(1,1)).finished_task_flag(1,channel(i).channel(j).cur_task(1,2))=1;  
                            end
                            %通信结束出口 
                            %计算完成时间和计算延时
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time=clock-1+consume_time;
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                            %通信完成时间和通信延时
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time=clock-1+consume_time;
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_delay_time= user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time- user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                            %信道历史信息
                            channel(i).channel(j).history_inf{2,end}(1,5)=clock-1+consume_time;
                            channel(i).channel(j).history_inf{2,end}(1,4)=channel(i).channel(j).history_inf{2,end}(1,5)-channel(i).channel(j).history_inf{2,end}(1,3);

                            %很重要的计算等待任务队列的更新
                            %若此后继节点的所有前区都标记完成传输，则将这个节点加入到等待队列，说明此节点是最后一个前驱任务

                            bool=[];
                            succTask=channel(i).channel(j).cur_task;%succTask表示即将放入下一个CU的任务，完成通信的节点的后继节点
                            channel(i).channel(j).cur_task=[];
                            succTask(:,2)=[];
                            if(all(user(succTask(1,1)).task(succTask(1,2)).finished_pretrans_flag(user(succTask(1,1)).task(succTask(1,2)).pre))==1)
                                    %选择wait_taskI最小的刀片
                                     CUAssign=user(succTask(1,1)).task(succTask(1,2)).CUAssign;  
                                     SLICEcand=[];
                                     SLICE=0;
                                    for k=1:K
                                        SLICEcand(1,k)=CU(CUAssign).slice(k).wait_taskI;
                                    end
                                    SLICE=min(find(min(SLICEcand)==SLICEcand));%最小.wait_taskI;值的下标
                                   %加入完成队列
                                   CU(CUAssign).slice(SLICE).wait_task_queue{1,end+1}=succTask;
                                   task_Queusers(succTask(1,2)).num(clock)= task_Queusers(succTask(1,2)).num(clock)+1;
                                   CU(CUAssign).slice(SLICE).wait_taskI=CU(CUAssign).slice(SLICE).wait_taskI+I(succTask(1,2));               
                                   CU(CUAssign).slice(SLICE).history_inf{1,end+1}=succTask;
                                   CU(CUAssign).slice(SLICE).history_inf{2,end}(1,1)=clock-1+consume_time;
                                   user(succTask(1,1)).task(succTask(1,2)).wait_start_time=clock-1+consume_time;

                            end
                            %更换当前任务
                            %如果remain_time不为零，则一直更新新任务
                            remain_time=step-consume_time;
                            while(remain_time~=0&&isempty( channel(i).channel(j).wait_task_queue)==0)                                                                                   
                                 channel(i).channel(j).cur_task=channel(i).channel(j).wait_task_queue{1,channel(i).channel(j).next_point};          
                                 tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;
                                 channel(i).channel(j).remain_taskD=auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3));
                                 channel(i).channel(j).wait_task_queue(:, channel(i).channel(j).next_point)=[];
                                %如果下一个任务是[*,9,10]则标志着任务结束                       
                                while(isempty( channel(i).channel(j).wait_task_queue)==0&&auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3))==0)
                                       user(channel(i).channel(j).cur_task(1,1)).finish_time=clock-1+consume_time;

                                         %更新next_point
                                        if(channel(i).channel(j).next_point<length(channel(i).channel(j).wait_task_queue))
                                            channel(i).channel(j).next_point=channel(i).channel(j).next_point+1;
                                        else
                                            channel(i).channel(j).next_point=1;
                                        end
                                        channel(i).channel(j).cur_task=channel(i).channel(j).wait_task_queue{1,channel(i).channel(j).next_point}; 
                                        tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;
                                        channel(i).channel(j).remain_taskD=auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3));
                                        channel(i).channel(j).wait_task_queue(:, channel(i).channel(j).next_point)=[];                               
                                end

                                %更新当前任务的历史信息 传输开始时间
                                channel(i).channel(j).history_inf{2,end}(1,3)=clock-remain_time;
                                channel(i).channel(j).history_inf{2,end}(1,2)= channel(i).channel(j).history_inf{2,end}(1,3)- channel(i).channel(j).history_inf{2,end}(1,1);
                                 %更新等待队列，删除

                                %更新next_point
                                if(channel(i).channel(j).next_point<length(channel(i).channel(j).wait_task_queue))
                                    channel(i).channel(j).next_point=channel(i).channel(j).next_point+1;
                                else
                                    channel(i).channel(j).next_point=1;
                                end
                                %更新用户信息
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time=clock-remain_time;                
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_start_time;
                                if(channel(i).channel(j).remain_taskD~=0)                                        
                                        if(channel(i).channel(j).remain_taskD>=B*remain_time)
                                            channel(i).channel(j).remain_taskD=channel(i).channel(j).remain_taskD-B*remain_time;
                                            remain_time=0;
                                        else%如果剩余时间多于要传输的数据量所需的时间，则不断更换新任务，知道剩余时间为零
                                                remain_time=remain_time-channel(i).channel(j).remain_taskD/B;
                                                channel(i).channel(j).remain_taskD=0; 
                                                    %任务完成标志置1
                                                     user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(1,channel(i).channel(j).cur_task(1,3))=1;
                                                     user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,3)).finished_pretrans_flag(1,channel(i).channel(j).cur_task(1,2))=1; 
                                                     if(all( user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).succ))==1)
                                                          user(channel(i).channel(j).cur_task(1,1)).finished_task_flag(1,channel(i).channel(j).cur_task(1,2))=1;  
                                                     end
                                                    %通信结束出口 
                                %                     %如果所有节点都标记完成，则此用户表示完成？10号节点肿么办
                                %                     if(all())
                                %                     end                                                 
                                                    %通信完成时间和通信延时
                                                    user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time=clock-remain_time;
                                                    user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_delay_time= user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time- user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                                                    %信道历史信息
                                                    channel(i).channel(j).history_inf{2,end}(1,5)=clock-remain_time;
                                                    channel(i).channel(j).history_inf{2,end}(1,4)=channel(i).channel(j).history_inf{2,end}(1,5)-channel(i).channel(j).history_inf{2,end}(1,3);

                                                    %很重要的计算等待任务队列的更新
                                                    %若此后继节点的所有前区都标记完成传输，则将这个节点加入到等待队列，说明此节点是最后一个前驱任务

                                                    bool=[];
                                                    succTask=channel(i).channel(j).cur_task;%succTask表示即将放入下一个CU的任务，完成通信的节点的后继节点
                                                    channel(i).channel(j).cur_task=[];
                                                    succTask(:,2)=[];
                                                    if(all(user(succTask(1,1)).task(succTask(1,2)).finished_pretrans_flag(user(succTask(1,1)).task(succTask(1,2)).pre))==1)
                                                            %选择wait_taskI最小的刀片
                                                             CUAssign=user(succTask(1,1)).task(succTask(1,2)).CUAssign;  
                                                             SLICEcand=[];
                                                             SLICE=0;
                                                            for k=1:K
                                                                SLICEcand(1,k)=CU(CUAssign).slice(k).wait_taskI;
                                                            end
                                                            SLICE=min(find(min(SLICEcand)==SLICEcand));%最小.wait_taskI;值的下标
                                                           %加入完成队列
                                                           CU(CUAssign).slice(SLICE).wait_task_queue{1,end+1}=succTask;
                                                           task_Queusers(succTask(1,2)).num(clock)= task_Queusers(succTask(1,2)).num(clock)+1;
                                                           CU(CUAssign).slice(SLICE).wait_taskI=CU(CUAssign).slice(SLICE).wait_taskI+I(succTask(1,2));               
                                                           CU(CUAssign).slice(SLICE).history_inf{1,end+1}=succTask;
                                                           CU(CUAssign).slice(SLICE).history_inf{2,end}(1,1)=clock-1+consume_time;
                                                           user(succTask(1,1)).task(succTask(1,2)).wait_start_time=clock-1+consume_time;

                                                    end                                               
                                         end                                               
                                  end                         
                            end


                        %只是削减通信数据
                        else
                            channel(i).channel(j).remain_taskD=channel(i).channel(j).remain_taskD-B*step;
                        end
                end
            end
        end
    end
    %求这一秒的完成的用户的平均的temp_makespan
    if(any(finished_user_flag)==0)%如果没有完成的用户，temp_makespan为零
            temp_makespan(clock)=0;
            temp_clock(clock)=clock;
    end
    if(any(finished_user_flag)==1)
            finished_user=find(finished_user_flag);
            temp_makespan(clock)=0;
            for i=1:length(finished_user)
                    temp_makespan(clock)=temp_makespan(clock)+user(finished_user(i)).makespan;
                    temp_clock(clock)=clock;
            end
             temp_makespan(clock)= temp_makespan(clock)/length(finished_user);
    end
clock=clock+step;    
end
% plot(temp_clock,temp_makespan,'g');
% hold on ;
for i=1:length(I)
task_Queusers(i).mean=mean(task_Queusers(i).num);
end
for i=1:length(I)
    for j=1:length(auxpreSucc{2,i})%i->auxpreSucc{2,i}(1,j)
            if(taskCU{1,i}(1,2)~=taskCU{1,auxpreSucc{2,i}(1,j)}(1,2)&&CULink(taskCU{1,i}(1,2),taskCU{1,auxpreSucc{2,i}(1,j)}(1,2))==1)                  
                    tasktransport_Queusers(i).tasktransport_Queusers(j).mean=mean(tasktransport_Queusers(i).tasktransport_Queusers(j).num);
            end
    end
end
%求makespan的均值
for i=1:USENUM
        mean_makespan(aa)=mean_makespan(aa)+user(i).makespan;
end
mean_makespan(aa)=mean_makespan(aa)/USENUM;

end
plot(arrate_array,mean_makespan);
hold on;
end