function [ CU,user,mean_makespan,user_num] = main( CULink,I,Scu,K )
%MAIN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%%%%%%%%%%%%%%%%%%%%������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

arrate_array=0.012
mean_makespan=zeros(1,length(arrate_array));
for aa=1:1
    arrate=arrate_array(aa)
    clock=1;
    step=1;%��������
    USERNUM=1000; %��ʾ�ܵ��û���������ϵͳ���ɵ��û���500.

    Sslice=Scu/K;
    ET=I/Sslice;
    user_num=0;
    finished_user_flag=zeros(1,USERNUM);
    temp_makespan=[];%��Ϊclock��1��ʼ
    temp_clock=[];%����temp����������ͼ����makespan�Ƿ�����
    capacity=500;
    userI=sum(I);


    %%%%%%%%%%%%%%%%%CU�ṹ��%%%%%%%%%%%%%%%%%
    %CU channel user����������id+��ʷ��Ϣ+��ǰ����ʣ����+�ȴ����м��ȴ������
    for i=1:size(CULink,2)
        CU(i).id=i;
        CU(i).wait_user=[];
        CU(i).location=zeros(1,2);
        CU(i).wait_task_queue=[];%[�û�id������idһλ]Ҳ��������id     
        for j=1:K
            CU(i).slice(j).id=[i,j];      
            CU(i).slice(j).cur_task=[];%[�û�id������idһλ]Ҳ��������id
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

    %%%%%%%%%%%��clock�˿̣���֤��һ���ڵ�������ɣ���ǰ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %arrate_queue����
    arrate_queue=zeros(1,USERNUM);
    arrate_point=1;%����ָ����һ��Ҫ����ϵͳ��Ԫ��
    for i=1:length(arrate_queue)
            arrate_queue(i)=i/arrate;%arrate_queue�д����ŵ�i������ĵ���ʱ��
    end
    %һ��ʱ϶�Ķ����Ӵ˴���while��ʼ
    while(any(arrate_queue)==1||user_num>0)
             for k=arrate_point:length(arrate_queue);            
                    %�½��û�
                    if(user_num<=capacity&&arrate_point<=length(arrate_queue)&&arrate_queue(k)<clock)
                       CU(user(arrate_point).CUAssign).wait_task_queue(end+1)=arrate_point;
                       user(arrate_point).start_time=clock;
                       user_num=user_num+1
                       arrate_queue(arrate_point)=0;
                       arrate_point=arrate_point+1;
                    end
            end
  
            %��������
            for i=1:size(CULink,2)
                for j=1:K 
%                         if(isempty(CU(i).wait_task_queue)==0||CU(i).slice(j).remain_taskI~=0)
                            %�������
                            if(CU(i).slice(j).remain_taskI==0&&isempty(CU(i).wait_task_queue)==0)
                                CU(i).slice(j).cur_task=CU(i).wait_task_queue(1);%ȡ��һ���ŵ����û�
                                CU(i).slice(j).remain_taskI=userI;
                                %������ȥ������һ�������Զ���ǰ
                                CU(i).wait_task_queue(:,1)=[];
                            %����������һ��������������û�
                            elseif(CU(i).slice(j).remain_taskI>0&&CU(i).slice(j).remain_taskI<=(Scu/K))
                                consume_time=CU(i).slice(j).remain_taskI/(Scu/K);
                                %����һ���û��Ĳ���
                                user(CU(i).slice(j).cur_task(1)).finish_time=clock-1+consume_time;
                                user(CU(i).slice(j).cur_task(1)).makespan=user(CU(i).slice(j).cur_task(1)).finish_time-user(CU(i).slice(j).cur_task(1)).start_time;
                                user_num=user_num-1

                                CU(i).slice(j).cur_task=[];
                                CU(i).slice(j).remain_taskI=0;
                                %�û��ĵڶ�����ڣ��ڼ��㵥Ԫ���Ŷӣ��õ�Ƭ����ʱ��ѡ���м���
                                if(CU(i).slice(j).remain_taskI==0&&isempty(CU(i).wait_task_queue)==0)
                                    CU(i).slice(j).cur_task=CU(i).wait_task_queue(1);%ȡ��һ���ŵ����û�
                                    CU(i).slice(j).remain_taskI=userI;
                                    %������ȥ������һ�������Զ���ǰ
                                    CU(i).wait_task_queue(:,1)=[];
                                
                            %����������
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

    %��makespan�ľ�ֵ
    for i=1:USERNUM
            mean_makespan(aa)=mean_makespan(aa)+user(i).makespan;
    end
    mean_makespan(aa)=mean_makespan(aa)/USERNUM;
end
plot(arrate_array,mean_makespan);
hold on;
end