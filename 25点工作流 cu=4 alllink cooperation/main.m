function [ CU,channel,user,mean_makespan,a,user_num,temp_clock,temp_makespan,task_Queusers,tasktransport_Queusers] = main(taskCU,CUtask, CULink,auxpreSucc,PCP,I,Scu,K,auxD,B )
%MAIN �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%%%%%%%%%%%%%%%%%%%%������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

arrate_array=0.002:0.002:0.02
mean_makespan=zeros(1,length(arrate_array));
for aa=6:6
arrate=arrate_array(aa)
clock=1;
step=1;%��������
USENUM=1000; %��ʾ�ܵ��û���������ϵͳ���ɵ��û���500.

Sslice=Scu/K;
ET=I/Sslice;
user_num=0;
finished_user_flag=zeros(1,USENUM);
temp_makespan=[];%��Ϊclock��1��ʼ
temp_clock=[];%����temp����������ͼ����makespan�Ƿ�����
capacity=500;
a=[];
r=[];
%%%%%%%%%%%%%%%
%�����Ŷ��û�����Ϣ��¼
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
%%%%%%%%%%%%%%%%%CU�ṹ��%%%%%%%%%%%%%%%%%
%CU channel user����������id+��ʷ��Ϣ+��ǰ����ʣ����+�ȴ����м��ȴ������
for i=1:size(CULink,2)
    CU(i).id=i;
    CU(i).wait_user=[];
    CU(i).wait_user_num=length(CU(i).wait_user);
    for j=1:K
        CU(i).slice(j).id=[i,j];
        CU(i).slice(j).flag=0;%�е�ǰ����Ļ�Ϊ1
        CU(i).slice(j).history_inf=cell(0,0);%Ԫ�����飬��һ�� �û�id ����id �ڶ��� ����ʱ�� �ȴ���ʱ ��ʼ����ʱ�� ����ʱ�� �������ʱ��
        CU(i).slice(j).cur_task=[];%[�û�id������idһλ]Ҳ��������id
        CU(i).slice(j).remain_taskI=0;
        CU(i).slice(j).next_point=1;
        CU(i).slice(j).wait_task_queue=cell(0,0);%[�û�id������idһλ]Ҳ��������id
        CU(i).slice(j).wait_taskI=0;%�ȴ�������ļ��������ܺ�
        CU(i).slice(j).wait_task_num=length(CU(i).slice(j).wait_task_queue);        
    end    
end
%%%%%%%%%%%%%%%%%%%channel�ṹ��%%%%%%%%%%%
for i=1:size(CULink,1)
    for j=1:size(CULink,2)
        if (CULink(i,j)==1)
            channel(i).channel(j).exit=1;
            channel(i).channel(j).history_inf=cell(0,0);%Ԫ�����飬��һ�� �û�id ǰ������id ���������id��һλ �ڶ��� �����ŵ�ʱ�� �ȴ���ʱ ���俪ʼʱ�� ����ʱ�� �������ʱ��
            channel(i).channel(j).cur_task=[];%[�û���ǰ�����񣬺�������]
            channel(i).channel(j).remain_taskD=0;%ʣ���������
            channel(i).channel(j).next_point=1;
            channel(i).channel(j).wait_task_queue=cell(0,0);%[�û���ǰ�����񣬺�������]
            channel(i).channel(j).wait_task_num=length(channel(i).channel(j).wait_task_queue);
        end
    end
end
%%%%%%%%%%%%%%%%%user�ṹ��%%%%%%%%%%%%%%%%%
for i=1:USENUM%500���û�
    user(i).id=i;
    user(i).wait_time=0;
    user(i).start_time=0;
    user(i).finish_time=0;
    user(i).makespan=user(i).finish_time-user(i).start_time;
    user(i).finished_task_flag=zeros(1,length(I));%����������ȫ��������ɣ�����Ϊ1 
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
        user(i).task(j).finished_trans_flag=zeros(1,length(I));%����������ɣ�����idλ�ñ��Ϊ1
        user(i).task(j).finished_pretrans_flag=zeros(1,length(I));%ǰ��������ɣ�ǰ��λ�ñ��Ϊ1
        user(i).task(j).wait_start_time=0;
        user(i).task(j).compute_start_time=0;
        user(i).task(j).wait_delay_time=user(i).task(j).compute_start_time-user(i).task(j).wait_start_time;
        user(i).task(j).compute_finish_time=0;
        user(i).task(j).compute_delay_time=user(i).task(j).compute_finish_time-user(i).task(j).compute_start_time;
        
        for k=1:length(user(i).task(j).succ)%����ʱ�����Ҫָ���ĸ����
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
%%%%%%%%%%%��clock�˿̣���֤��һ���ڵ�������ɣ���ǰ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%arrate_queue����
arrate_queue=zeros(1,USENUM);
arrate_point=1;%����ָ����һ��Ҫ����ϵͳ��Ԫ��
for i=1:length(arrate_queue)
        arrate_queue(i)=i/arrate;%arrate_queue�д����ŵ�i������ĵ���ʱ��
end
%һ��ʱ϶�Ķ����Ӵ˴���while��ʼ
while(any(arrate_queue)==1||user_num>0)%�ܵ���һ�����user_num==0��arrate_queueȫΪ�����
        %��ÿһ��clock�ĳ�ʼֵ
       for i=1:length(I)
               if(clock>1)
                task_Queusers(i).num(clock)=task_Queusers(i).num(clock-1);   %����ֵ�ı�׼�Ǽ������ ,�����м�һ��          
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
        %%%%%%%%%%%%%%%%����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if(user_num<capacity&& arrate_queue(k)<=clock)%ǰ��ٸ��û����ܽ���              
                    %�ȿ�20s��ʱ��,�����һ��ʱ϶������һ��ʱ϶����ʼ�͹��̶���
                    user(k).id=k;
                    r(end+1)=k;
                    user(k).wait_time=clock-arrate_queue(k);
                    %�����û����� arrate_queue�� arrate_point
                    user_num=user_num+1
                    arrate_queue(k)=0;
                    arrate_point=arrate_point+1;
                    user(k).finished_task_flag(1,1)=1;
                    succ=[];%succ ���׽ڵ�ĺ�̽ڵ�
                    succ= user(k).task(1).succ;
                    SLICEcand=[];
                    SLICE=0;
                    for i=1:length(succ)
                        CUAssign=user(i).task(succ(i)).CUAssign;
                        for j=1:K
                            SLICEcand(1,j)=CU(CUAssign).slice(j).wait_taskI;
                        end
                        SLICE=min(find(min(SLICEcand)==SLICEcand));%��С.wait_taskI;ֵ���±�
                       %����ȴ�����
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
%%%%%%%%%%%%%%%%%%�������ݼ�%%%%%%%%%%%%%%%%%%%%%%%%
    for i=1:size(CULink,2)
        for j=1:K
            %������������
            %��ʼ����Ƭ
            %��������if��֧�ĵ�һ����֧������������� 1������ڵ����ŵ���2��ʵ�ڵ��뵶Ƭ
            if(CU(i).slice(j).remain_taskI==0)
                if(isempty(CU(i).slice(j).wait_task_queue)==0)
                   %��1������ڵ����ŵ�
                    %���µ�ǰ����           circle��ʾɨ��һȦ�Ϳ��Խ���ѭ���ˣ���Ҫ������ѭ�� 
                    %�ⲿ���ǽ�����ڵ�ֱ�Ӷ����ĺ���ѭ���������Ӧ���ŵ����У�circle������ֹ�ȴ�����ֻ������ڵ㣬���ܹ�ͨ���ڵ�ļ�������������������ѭ����
                    circle=0;
                    while(circle<length(CU(i).slice(j).wait_task_queue)&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))==0)%���������ڵ㣬������Ϊ�㣬ֱ�Ӳ���ͨ���ŵ���������һ������
                            %�����ŵ��ĵȴ��������,����ÿһ��������ڵ�CU�������ŵ��ĵȴ�����
                            if(isempty(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)==0)
                                    for k=1:length(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).wait_task_queue{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];
                                            if(i~=user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign)
                                                tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock) =tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock)+1;
                                            end
                                            %�����ŵ���ʷ��Ϣ
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];                                            
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{2,end}(1,1)=clock;
                                            %�����û��Ĵ���ȴ���ʼ��Ϣ
                                            user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).Succ(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).wait_start_time=clock;
                                    end 
                                    %��������ڵ�Ӽ���ȴ�����ɾ��
                                       CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];
                                      %����next_point
                                    if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                                       CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                                   else
                                       CU(i).slice(j).next_point=1;
                                   end
                            end
                            circle=circle+1;
                    end
                    %��2���� ʵ�ڵ����Ƭ
                   %�����������ڵ㣬���Ǽ�������Ϊ��.�����µ�ǰ�ļ�������
                   %���ȥ������ڵ�֮��ȴ����в��գ����Ƿ�����ڵ㣬����뵽��ǰ����
                   %�����ǵȴ�������Ϊ��������µĵڶ�����֧����һ����֧�Ǵ���������ڵ㣬ֱ�Ӽ��Ϻ�̽ڵ���봫���ŵ���һ�δ�����next_point��ָ�����������ڵ㣬��Ϊֻ��ָ�������ڵ�󲢼��뵽��ǰ������������Ƭ��������һ����м���
                   %                                                                       �ڶ�����֧�Ǵ���ʵ�ڵ㣬����ѡ�񵽵�ǰ����    
                    if(isempty(CU(i).slice(j).wait_task_queue)==0&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))~=0)
                            %���µ�ǰ����ʣ����������ӣ��ȴ�����ɾ�������񣬵ȵ�����������
                            CU(i).slice(j).cur_task=CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point};
                            task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)= task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)-1;
                            CU(i).slice(j).remain_taskI=I(CU(i).slice(j).cur_task(1,2));
                            CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];%ɾ�����Ԫ���Լ�λ��
                            CU(i).slice(j).wait_taskI=CU(i).slice(j).wait_taskI-I(CU(i).slice(j).cur_task(1,2));
                            %����next_point
                           if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                               CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                           else
                               CU(i).slice(j).next_point=1;
                           end
                           %���µ�Ƭ��ʷ��Ϣ�����㿪ʼʱ��͵ȴ���ʱ
                            CU(i).slice(j).history_inf{2,end}(1,3)=clock;
                            CU(i).slice(j).history_inf{2,end}(1,2)=CU(i).slice(j).history_inf{2,end}(1,3)-CU(i).slice(j).history_inf{2,end}(1,1); 
                            %�����û���ʷ��Ϣ�����㿪ʼʱ��͵ȴ���ʱ
                           user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time=clock;
                           user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_delay_time=user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time-user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_start_time;
                    end
                end
            
            %һ����������������һ��������㿪ʼ
            %���Ǽ����������ĵڶ�����֧��elseif�����Ľṹ��ʾ���������ṹֻ�ܽ�һ���ṹ
            %�ܹ����Ŀ����ݣ�ǰ�����Ǵ�������񣬺����鴦��������
            %1�����������ʷ��Ϣ�ĸ��£������������ʱ�䣬������ʱ��2.����������̽ڵ���뵽ͨ���ŶӶ��е���
            %3.�����������ڵ�Ĵ���ͬ��һ����֧����4.������ʵ�ڵ�Ĵ���ͬ��һ������
            %��2��3���������ŵ����е���ڣ�2��ʵ�ڵ��봫���ŵ���3��������ڵ��봫���ŵ�
            elseif(CU(i).slice(j).remain_taskI>0&&CU(i).slice(j).remain_taskI<=Sslice*step)
                    
            %��1���־ɽڵ���ʷ��Ϣ����
                %����Ѿ��ķѵ�ʱ��consume_time
                consume_time= CU(i).slice(j).remain_taskI/Sslice*step;
                %ʣ�����������㣬��־��ǰ����Ľ���
                CU(i).slice(j).remain_taskI=0;
               
                %��Ƭ��ʷ��Ϣ���� �������ʱ�� �ͼ�����ʱ
                CU(i).slice(j).history_inf{2,end}(1,5)=clock-1+consume_time;
                CU(i).slice(j).history_inf{2,end}(1,4)=CU(i).slice(j).history_inf{2,end}(1,5)-CU(i).slice(j).history_inf{2,end}(1,3);
                
                 %�û�������Ϣ���� �������ʱ�� �ͼ�����ʱ
                user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_finish_time=clock-1+consume_time;
                user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_delay_time=user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_finish_time-user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time;
                
             %��2���־ɽڵ�Ӻ�̽ڵ�����ŵ�
                %��ǰ�������ͨ���Ŷӣ���ֻ������һ�������ʱ�������Ѳ�Ļ���
                %ʵ�ڵ����ͨ�ŵ����
                for k=1:length(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ)
                     %�����ŵ��ȴ����У�����ǰ����ӵ��������Ӧ�ĵȴ����е��У�ע���ŵ�û�о���������CU��CUֻ��һ���ŵ���
                    channel(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign).channel(user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign).wait_task_queue{1,end+1}=[CU(i).slice(j).cur_task,user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)]; 
                    if(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign~=user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign)
                         tasktransport_Queusers(CU(i).slice(j).cur_task(1,2)).tasktransport_Queusers(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).num(clock)= tasktransport_Queusers(CU(i).slice(j).cur_task(1,2)).tasktransport_Queusers(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).num(clock)+1;
                    end
                    %�����ŵ���ʷ��Ϣ��id�ʹ���ȴ���ʼʱ�䣻
                    channel(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign).channel(user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign).history_inf{1,end+1}=[CU(i).slice(j).cur_task,user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)];
                    channel(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).CUAssign).channel(user(CU(i).slice(j).cur_task(1,1)).task(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).CUAssign).history_inf{2,end}(1,1)=clock-1+consume_time;
                    %�����û��Ĵ���ȴ���ʼʱ��
                    user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).Succ(user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).succ(1,k)).wait_start_time=clock-1+consume_time; 
                end
                %��յ�ǰ����
                CU(i).slice(j).cur_task=[];
              %��3���֣�����ڵ�Խ����Ƭ�����ŵ�
                %��һ��������뵱ǰ����
                if(isempty(CU(i).slice(j).wait_task_queue)==0)
                       circle=0;
                       while(circle<length(CU(i).slice(j).wait_task_queue)&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))==0)%���������ڵ㣬������Ϊ�㣬ֱ�Ӳ���ͨ���ŵ���������һ������
                            %�����ŵ��ĵȴ��������,����ÿһ��������ڵ�CU�������ŵ��ĵȴ�����
                            if(isempty(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)==0)
                                    for k=1:length(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ)
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).wait_task_queue{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];
                                             if( i~=user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign)
                                                    tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock)=  tasktransport_Queusers(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).tasktransport_Queusers(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).num(clock)+1;
                                             end
                                            %�����ŵ���ʷ��Ϣ
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{1,end+1}=[CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point},user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)];                                            
                                            channel(i).channel(user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).CUAssign).history_inf{2,end}(1,1)=clock;
                                            %�����û��Ĵ���ȴ���ʼ��Ϣ
                                            user(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,1)).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).Succ(user(i).task(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2)).succ(1,k)).wait_start_time=clock;
                                    end 
                                   CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];                               
                                   %����next_point
                                    if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                                       CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                                   else
                                       CU(i).slice(j).next_point=1;
                                   end
                            end
                              circle=circle+1;
                       end
                   %��4���� ʵ�ڵ���뵶Ƭ
                        %�����ǵȴ����в��գ�����ʵ�ڵ�
                         if(isempty(CU(i).slice(j).wait_task_queue)==0&&I(CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point}(1,2))~=0)%�����������ڵ㣬����������Ϊ��.�����µ�ǰ�ļ�������
                                 %���µ�ǰ����ʣ����������ӣ��ȴ�����ɾ�������񣬵ȵ�����������
                                CU(i).slice(j).cur_task=CU(i).slice(j).wait_task_queue{1,CU(i).slice(j).next_point};
                                task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)= task_Queusers(CU(i).slice(j).cur_task(1,2)).num(clock)-1;
                                remain_time=step-consume_time;
                                CU(i).slice(j).remain_taskI=I(CU(i).slice(j).cur_task(1,2))-remain_time*Sslice;
                                CU(i).slice(j).wait_task_queue(:,CU(i).slice(j).next_point)=[];%ɾ�����Ԫ���Լ�λ��
                                CU(i).slice(j).wait_taskI=CU(i).slice(j).wait_taskI-I(CU(i).slice(j).cur_task(1,2));
                                %����next_point
                               if(CU(i).slice(j).next_point<length(CU(i).slice(j).wait_task_queue))
                                   CU(i).slice(j).next_point=CU(i).slice(j).next_point+1;
                               else
                                   CU(i).slice(j).next_point=1;
                               end
                                 %���µ�Ƭ��ʷ��Ϣ�����㿪ʼʱ��͵ȴ���ʱ
                              CU(i).slice(j).history_inf{2,end}(1,3)=clock;
                              CU(i).slice(j).history_inf{2,end}(1,2)=CU(i).slice(j).history_inf{2,end}(1,3)-CU(i).slice(j).history_inf{2,end}(1,1); 
                              %�����û���ʷ��Ϣ�����㿪ʼʱ��͵ȴ���ʱ
                             user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time=clock;
                             user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_delay_time=user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).compute_start_time-user(CU(i).slice(j).cur_task(1,1)).task(CU(i).slice(j).cur_task(1,2)).wait_start_time;
                             
                         end%��ʵ�ڵ���� 4���ֽ���
                end%���½ڵ���� 3,4���ֽ���

            %������if��֧ ���ʣ�����������һ�ο��������ļ�����
            else
                CU(i).slice(j).remain_taskI=CU(i).slice(j).remain_taskI-Sslice*step;            
            end %������֧ȫ������       
        end%ʮ����Ƭѭ������
    end%�ĸ�CUѭ������

%%%%%%%%%%%%%���ݴ���ݼ�%%%%%%%%%%%%%%%%%%%%%%    
    for i=1:size(CULink,1)
        for j=1:size(CULink,2)
            if (CULink(i,j)==1)
            %�������ͬһ��CU�ĵ��У�����Ҫ���䡣1.�ս��Ĵ�������Ҫ�ٻص���Ƭ��2.���ս��Ĵ�����Ϣ���£���̽ڵ�ص���Ƭ��
                if(i==j)%�ܹ���������ʽ 4->8 6->9 8->9  9->10 (���ս���д���)
                        if(isempty(channel(i).channel(j).wait_task_queue)==0)
                               waitQueue=channel(i).channel(j).wait_task_queue;
                                for m=1:length(waitQueue)
                                      curTask=waitQueue{1,m};
                                      user(curTask(1,1)).task(curTask(1,2)).finished_trans_flag(1,curTask(1,3))=1;
                                      user(curTask(1,1)).task(curTask(1,3)).finished_pretrans_flag(1,curTask(1,2))=1;
                                      if(all( user(curTask(1,1)).task(curTask(1,2)).finished_trans_flag(user(curTask(1,1)).task(curTask(1,2)).succ))==1)
                                              user(curTask(1,1)).finished_task_flag(curTask(1,2))=1;%������е�������������񶼽����ˣ���ôǰ�������������������
                                      end
                                      %������ս��
                                      if(auxD(curTask(1,2), curTask(1,3))==1)                                              
                                               user(curTask(1,1)).finished_task_flag(1,curTask(1,3))=1;
                                               if(curTask(1,3)==27)
                                                       user_num=user_num-1
                                                       a(end+1)=curTask(1,1);
                                               end
                                               user(curTask(1,1)).finish_time=clock;  
                                               user(curTask(1,1)).makespan=user(curTask(1,1)).finish_time-user(curTask(1,1)).start_time;
                                               finished_user_flag(curTask(1,1))=1;
                                               %�ȴ�������ɾ��������
                                               channel(i).channel(j).wait_task_queue(:,1)=[];
                                              %�û�����ʱ��ĸ���
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time=clock;                                              
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time=clock
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time- user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time=clock; 
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time-user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time;
                                      else
                       
                                              %�����û�������Ϣ
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time=clock;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time=clock;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time- user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).wait_start_time;
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time=clock; 
                                               user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_delay_time=user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_finish_time-user(curTask(1,1)).task(curTask(1,2)).Succ(curTask(1,3)).trans_start_time;
                                               %ɾ���ȴ������еĴ�����
                                               channel(i).channel(j).wait_task_queue(:,1)=[];
                                               %����Ҫ�ļ���ȴ�������еĸ���
                                              %���˺�̽ڵ������ǰ���������ɴ��䣬������ڵ���뵽�ȴ����У�˵���˽ڵ������һ��ǰ������                             
                                              %��̽ڵ���뵽���㵶Ƭ
                                              curTask(:,2)=[];
                                              if(all(user(curTask(1,1)).task(curTask(1,2)).finished_pretrans_flag(user(curTask(1,1)).task(curTask(1,2)).pre))==1)
                                                    %ѡ��wait_taskI��С�ĵ�Ƭ
                                                     CUAssign=user(curTask(1,1)).task(curTask(1,2)).CUAssign;  
                                                     SLICEcand=[];
                                                     SLICE=0;
                                                    for k=1:K
                                                        SLICEcand(1,k)=CU(CUAssign).slice(k).wait_taskI;
                                                    end
                                                    SLICE=min(find(min(SLICEcand)==SLICEcand));%��С.wait_taskI;ֵ���±�
                                                   %������ɶ���
                                                   CU(CUAssign).slice(SLICE).wait_task_queue{1,end+1}=curTask;
                                                   task_Queusers(curTask(1,2)).num(clock)= task_Queusers(curTask(1,2)).num(clock)+1;
                                                   CU(CUAssign).slice(SLICE).wait_taskI=CU(CUAssign).slice(SLICE).wait_taskI+I(curTask(1,2));               
                                                   CU(CUAssign).slice(SLICE).history_inf{1,end+1}=curTask;
                                                   CU(CUAssign).slice(SLICE).history_inf{2,end}(1,1)=clock-1+consume_time;
                                                   user(curTask(1,1)).task(curTask(1,2)).wait_start_time=clock-1+consume_time;

                                            end%��̽ڵ������㵶Ƭ����
                                      end
                                end %��ÿһ������Ԫ�ش������                               
                                channel(i).channel(j).remain_taskD=0;    
                        end%���в�����������
                else%����if��i==j������ʼif(i~=j)
                        %��ʼ���ŵ�������
                        if(channel(i).channel(j).remain_taskD==0)%��ʼ��������
                            if(isempty(channel(i).channel(j).wait_task_queue)==0)                   
                                %����ǰ��ͨ������
                                channel(i).channel(j).cur_task=channel(i).channel(j).wait_task_queue{1,channel(i).channel(j).next_point};                                                         
                                tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;
                                channel(i).channel(j).remain_taskD=auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3));
                                channel(i).channel(j).wait_task_queue(:, channel(i).channel(j).next_point)=[];
                                  while(isempty( channel(i).channel(j).wait_task_queue)==0&&auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3))==0)
                                       user(channel(i).channel(j).cur_task(1,1)).finish_time=clock-1+consume_time;

                                         %����next_point
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
                                %���µ�ǰ�������ʷ��Ϣ ���俪ʼʱ��
                                channel(i).channel(j).history_inf{2,end}(1,3)=clock;
                                channel(i).channel(j).history_inf{2,end}(1,2)= channel(i).channel(j).history_inf{2,end}(1,3)- channel(i).channel(j).history_inf{2,end}(1,1);
                                 %���µȴ����У�ɾ��


                                %����next_point
                                if(channel(i).channel(j).next_point<length(channel(i).channel(j).wait_task_queue))
                                    channel(i).channel(j).next_point=channel(i).channel(j).next_point+1;
                                else
                                    channel(i).channel(j).next_point=1;
                                end
                                %�����û���Ϣ
                                %�����û�ͨ����Ϣ
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time=clock;         
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_start_time;
                                %�����û�������Ϣ
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time=clock;
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                            end

                        %ͨ�����ݵ�������ӵ�ǰ�û��ĸ���
                        elseif(channel(i).channel(j).remain_taskD>0&&channel(i).channel(j).remain_taskD<=B*step)
                            %��һ����������Ĵ���
                            consume_time=channel(i).channel(j).remain_taskD/B;
                            channel(i).channel(j).remain_taskD=0; 
                            %������ɱ�־��1
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(1,channel(i).channel(j).cur_task(1,3))=1;
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,3)).finished_pretrans_flag(1,channel(i).channel(j).cur_task(1,2))=1; 
                            if(all( user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).succ))==1)
                                  user(channel(i).channel(j).cur_task(1,1)).finished_task_flag(1,channel(i).channel(j).cur_task(1,2))=1;  
                            end
                            %ͨ�Ž������� 
                            %�������ʱ��ͼ�����ʱ
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time=clock-1+consume_time;
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_finish_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                            %ͨ�����ʱ���ͨ����ʱ
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time=clock-1+consume_time;
                            user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_delay_time= user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time- user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                            %�ŵ���ʷ��Ϣ
                            channel(i).channel(j).history_inf{2,end}(1,5)=clock-1+consume_time;
                            channel(i).channel(j).history_inf{2,end}(1,4)=channel(i).channel(j).history_inf{2,end}(1,5)-channel(i).channel(j).history_inf{2,end}(1,3);

                            %����Ҫ�ļ���ȴ�������еĸ���
                            %���˺�̽ڵ������ǰ���������ɴ��䣬������ڵ���뵽�ȴ����У�˵���˽ڵ������һ��ǰ������

                            bool=[];
                            succTask=channel(i).channel(j).cur_task;%succTask��ʾ����������һ��CU���������ͨ�ŵĽڵ�ĺ�̽ڵ�
                            channel(i).channel(j).cur_task=[];
                            succTask(:,2)=[];
                            if(all(user(succTask(1,1)).task(succTask(1,2)).finished_pretrans_flag(user(succTask(1,1)).task(succTask(1,2)).pre))==1)
                                    %ѡ��wait_taskI��С�ĵ�Ƭ
                                     CUAssign=user(succTask(1,1)).task(succTask(1,2)).CUAssign;  
                                     SLICEcand=[];
                                     SLICE=0;
                                    for k=1:K
                                        SLICEcand(1,k)=CU(CUAssign).slice(k).wait_taskI;
                                    end
                                    SLICE=min(find(min(SLICEcand)==SLICEcand));%��С.wait_taskI;ֵ���±�
                                   %������ɶ���
                                   CU(CUAssign).slice(SLICE).wait_task_queue{1,end+1}=succTask;
                                   task_Queusers(succTask(1,2)).num(clock)= task_Queusers(succTask(1,2)).num(clock)+1;
                                   CU(CUAssign).slice(SLICE).wait_taskI=CU(CUAssign).slice(SLICE).wait_taskI+I(succTask(1,2));               
                                   CU(CUAssign).slice(SLICE).history_inf{1,end+1}=succTask;
                                   CU(CUAssign).slice(SLICE).history_inf{2,end}(1,1)=clock-1+consume_time;
                                   user(succTask(1,1)).task(succTask(1,2)).wait_start_time=clock-1+consume_time;

                            end
                            %������ǰ����
                            %���remain_time��Ϊ�㣬��һֱ����������
                            remain_time=step-consume_time;
                            while(remain_time~=0&&isempty( channel(i).channel(j).wait_task_queue)==0)                                                                                   
                                 channel(i).channel(j).cur_task=channel(i).channel(j).wait_task_queue{1,channel(i).channel(j).next_point};          
                                 tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)=  tasktransport_Queusers(channel(i).channel(j).cur_task(1,2)).tasktransport_Queusers(channel(i).channel(j).cur_task(1,3)).num(clock)-1;
                                 channel(i).channel(j).remain_taskD=auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3));
                                 channel(i).channel(j).wait_task_queue(:, channel(i).channel(j).next_point)=[];
                                %�����һ��������[*,9,10]���־���������                       
                                while(isempty( channel(i).channel(j).wait_task_queue)==0&&auxD(channel(i).channel(j).cur_task(1,2),channel(i).channel(j).cur_task(1,3))==0)
                                       user(channel(i).channel(j).cur_task(1,1)).finish_time=clock-1+consume_time;

                                         %����next_point
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

                                %���µ�ǰ�������ʷ��Ϣ ���俪ʼʱ��
                                channel(i).channel(j).history_inf{2,end}(1,3)=clock-remain_time;
                                channel(i).channel(j).history_inf{2,end}(1,2)= channel(i).channel(j).history_inf{2,end}(1,3)- channel(i).channel(j).history_inf{2,end}(1,1);
                                 %���µȴ����У�ɾ��

                                %����next_point
                                if(channel(i).channel(j).next_point<length(channel(i).channel(j).wait_task_queue))
                                    channel(i).channel(j).next_point=channel(i).channel(j).next_point+1;
                                else
                                    channel(i).channel(j).next_point=1;
                                end
                                %�����û���Ϣ
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time=clock-remain_time;                
                                user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_delay_time=user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_start_time-user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).wait_start_time;
                                if(channel(i).channel(j).remain_taskD~=0)                                        
                                        if(channel(i).channel(j).remain_taskD>=B*remain_time)
                                            channel(i).channel(j).remain_taskD=channel(i).channel(j).remain_taskD-B*remain_time;
                                            remain_time=0;
                                        else%���ʣ��ʱ�����Ҫ����������������ʱ�䣬�򲻶ϸ���������֪��ʣ��ʱ��Ϊ��
                                                remain_time=remain_time-channel(i).channel(j).remain_taskD/B;
                                                channel(i).channel(j).remain_taskD=0; 
                                                    %������ɱ�־��1
                                                     user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(1,channel(i).channel(j).cur_task(1,3))=1;
                                                     user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,3)).finished_pretrans_flag(1,channel(i).channel(j).cur_task(1,2))=1; 
                                                     if(all( user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).finished_trans_flag(user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).succ))==1)
                                                          user(channel(i).channel(j).cur_task(1,1)).finished_task_flag(1,channel(i).channel(j).cur_task(1,2))=1;  
                                                     end
                                                    %ͨ�Ž������� 
                                %                     %������нڵ㶼�����ɣ�����û���ʾ��ɣ�10�Žڵ���ô��
                                %                     if(all())
                                %                     end                                                 
                                                    %ͨ�����ʱ���ͨ����ʱ
                                                    user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time=clock-remain_time;
                                                    user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_delay_time= user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).Succ(channel(i).channel(j).cur_task(1,3)).trans_finish_time- user(channel(i).channel(j).cur_task(1,1)).task(channel(i).channel(j).cur_task(1,2)).compute_start_time;
                                                    %�ŵ���ʷ��Ϣ
                                                    channel(i).channel(j).history_inf{2,end}(1,5)=clock-remain_time;
                                                    channel(i).channel(j).history_inf{2,end}(1,4)=channel(i).channel(j).history_inf{2,end}(1,5)-channel(i).channel(j).history_inf{2,end}(1,3);

                                                    %����Ҫ�ļ���ȴ�������еĸ���
                                                    %���˺�̽ڵ������ǰ���������ɴ��䣬������ڵ���뵽�ȴ����У�˵���˽ڵ������һ��ǰ������

                                                    bool=[];
                                                    succTask=channel(i).channel(j).cur_task;%succTask��ʾ����������һ��CU���������ͨ�ŵĽڵ�ĺ�̽ڵ�
                                                    channel(i).channel(j).cur_task=[];
                                                    succTask(:,2)=[];
                                                    if(all(user(succTask(1,1)).task(succTask(1,2)).finished_pretrans_flag(user(succTask(1,1)).task(succTask(1,2)).pre))==1)
                                                            %ѡ��wait_taskI��С�ĵ�Ƭ
                                                             CUAssign=user(succTask(1,1)).task(succTask(1,2)).CUAssign;  
                                                             SLICEcand=[];
                                                             SLICE=0;
                                                            for k=1:K
                                                                SLICEcand(1,k)=CU(CUAssign).slice(k).wait_taskI;
                                                            end
                                                            SLICE=min(find(min(SLICEcand)==SLICEcand));%��С.wait_taskI;ֵ���±�
                                                           %������ɶ���
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


                        %ֻ������ͨ������
                        else
                            channel(i).channel(j).remain_taskD=channel(i).channel(j).remain_taskD-B*step;
                        end
                end
            end
        end
    end
    %����һ�����ɵ��û���ƽ����temp_makespan
    if(any(finished_user_flag)==0)%���û����ɵ��û���temp_makespanΪ��
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
%��makespan�ľ�ֵ
for i=1:USENUM
        mean_makespan(aa)=mean_makespan(aa)+user(i).makespan;
end
mean_makespan(aa)=mean_makespan(aa)/USENUM;

end
plot(arrate_array,mean_makespan);
hold on;
end