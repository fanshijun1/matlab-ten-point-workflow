function [ CU,user,mean_makespan,user_num] = main( CULink,I,Scu,K )
%MAIN 此处显示有关此函数的摘要
%   此处显示详细说明
%%%%%%%%%%%%%%%%%%%%变量区%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

arrate_array=0.012
mean_makespan=zeros(1,length(arrate_array));
for aa=1:1
    arrate=arrate_array(aa)
    clock=1;
    step=1;%步进幅度
    USERNUM=1000; %表示总的用户数，不是系统容纳的用户数500.

    Sslice=Scu/K;
    ET=I/Sslice;
    user_num=0;
    finished_user_flag=zeros(1,USERNUM);
    temp_makespan=[];%因为clock从1开始
    temp_clock=[];%两个temp变量用来画图，看makespan是否收敛
    capacity=500;
    userI=sum(I);


    %%%%%%%%%%%%%%%%%CU结构体%%%%%%%%%%%%%%%%%
    %CU channel user基本都是由id+历史信息+当前任务及剩余量+等待队列及等待量组成
    for i=1:size(CULink,2)
        CU(i).id=i;
        CU(i).wait_user=[];
        CU(i).location=zeros(1,2);
        CU(i).wait_task_queue=[];%[用户id，任务id一位]也就是任务id     
        for j=1:K
            CU(i).slice(j).id=[i,j];      
            CU(i).slice(j).cur_task=[];%[用户id，任务id一位]也就是任务id
            CU(i).slice(j).remain_taskI=0;        
        end    
    end

    CU(1).location=[750,150];
    CU(2).location=[750,450];
    CU(3).location=[750,750];
    CU(4).location=[450,150];
    CU(5).location=[450,450];
    CU(6).location=[450,750];
    CU(7).location=[150,150];
    CU(8).location=[150,450];
    CU(9).location=[150,750];

    for i=1:USERNUM
        user(i).id=i;
        user(i).location=900*rand(1,2)
        user(i).distance=zeros(1,size(CULink,2));
        for j=1:size(CULink,2)
                user(i).distance(1,j)=sqrt((user(i).location(1)-CU(j).location(1))^2+((user(i).location(2)-CU(j).location(2))^2));
        end
        user(i).CUAssign=min(find(user(i).distance==min(user(i).distance)));
        user(i).wait_time=0;
        user(i).start_time=0;
        user(i).finish_time=0;
        user(i).makespan=user(i).finish_time-user(i).start_time;
    end

    %%%%%%%%%%%在clock此刻，保证这一秒内的任务完成，是前向负责制%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %arrate_queue数组
    arrate_queue=zeros(1,USERNUM);
    arrate_point=1;%用来指向下一个要进入系统的元素
    for i=1:length(arrate_queue)
            arrate_queue(i)=i/arrate;%arrate_queue中储存着第i个任务的到达时间
    end
    %一个时隙的动作从此处的while开始
    while(any(arrate_queue)==1||user_num>0)
             for k=arrate_point:length(arrate_queue);            
                    %新进用户
                    if(user_num<=capacity&&arrate_point<=length(arrate_queue)&&arrate_queue(k)<clock)
                       CU(user(arrate_point).CUAssign).wait_task_queue(end+1)=arrate_point;
                       user(arrate_point).start_time=clock;
                       user_num=user_num+1
                       arrate_queue(arrate_point)=0;
                       arrate_point=arrate_point+1;
                    end
            end
  
            %计算削减
            for i=1:size(CULink,2)
                for j=1:K 
%                         if(isempty(CU(i).wait_task_queue)==0||CU(i).slice(j).remain_taskI~=0)
                            %添加任务
                            if(CU(i).slice(j).remain_taskI==0&&isempty(CU(i).wait_task_queue)==0)
                                CU(i).slice(j).cur_task=CU(i).wait_task_queue(1);%取第一个排到的用户
                                CU(i).slice(j).remain_taskI=userI;
                                %此任务去掉，下一个任务自动进前
                                CU(i).wait_task_queue(:,1)=[];
                            %任务量不足一次削减，添加新用户
                            elseif(CU(i).slice(j).remain_taskI>0&&CU(i).slice(j).remain_taskI<=(Scu/K))
                                consume_time=CU(i).slice(j).remain_taskI/(Scu/K);
                                %结束一个用户的操作
                                user(CU(i).slice(j).cur_task(1)).finish_time=clock-1+consume_time;
                                user(CU(i).slice(j).cur_task(1)).makespan=user(CU(i).slice(j).cur_task(1)).finish_time-user(CU(i).slice(j).cur_task(1)).start_time;
                                user_num=user_num-1

                                CU(i).slice(j).cur_task=[];
                                CU(i).slice(j).remain_taskI=0;
                                %用户的第二个入口，在计算单元中排队，让刀片空闲时挑选进行计算
                                if(CU(i).slice(j).remain_taskI==0&&isempty(CU(i).wait_task_queue)==0)
                                    CU(i).slice(j).cur_task=CU(i).wait_task_queue(1);%取第一个排到的用户
                                    CU(i).slice(j).remain_taskI=userI;
                                    %此任务去掉，下一个任务自动进前
                                    CU(i).wait_task_queue(:,1)=[];
                                
                            %任务量削减
                                remain_time=step-consume_time;
                                CU(i).slice(j).remain_taskI=CU(i).slice(j).remain_taskI-(Scu/K)*remain_time;
                                end

                            elseif(CU(i).slice(j).remain_taskI>(Scu/K))
                                CU(i).slice(j).remain_taskI=CU(i).slice(j).remain_taskI-(Scu/K);
                            else
                                    continue;
                            end
%                         end
                end
            end
            clock=clock+step;
    end

    %求makespan的均值
    for i=1:USERNUM
            mean_makespan(aa)=mean_makespan(aa)+user(i).makespan;
    end
    mean_makespan(aa)=mean_makespan(aa)/USERNUM;
end
plot(arrate_array,mean_makespan);
hold on;
end