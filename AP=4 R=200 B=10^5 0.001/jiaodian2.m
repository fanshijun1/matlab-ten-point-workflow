ren=500;
AR_array=0.001:0.002:0.05;
init=100;

name=['AP=',num2str(3),' AR=',num2str(0.004),' ren=',num2str(500),' clock=1000000','.mat'];
% name=['AP=',num2str(15),' AR=0.01',' ren=10''.mat'];
load(name);
alpha=0;
for i=1:26
    alpha=alpha+length(K{2,i});
end
alpha=alpha/26;
alpha=1;
%注：这里load出来后不只是userstate，是把所有的数据都重新写出来了
% Arrtime=AT{round(0.01*1000)};%round取整
%         temp=find(Arrtime<=40000);
Task_AP=cell(1,Nap);
for i=1:Nap
    Task_AP{1,i}=Assignrank(find(Map(:,i)));%各个AP分配到的task
end
Task_AP{1}(1)=[];
delay_trans_data=zeros(Nap,Nap);
number=zeros(Nap,Nap);
for i=2:length(I)+1
    suc=K{2,i};
    from=find(Map(find(i==Assignrank),:));
    for j=1:length(suc)
        to=find(Map(find(suc(j)==Assignrank),:));
        if from~=to
            delay_trans_data(from,to)=Transferdataq(i,suc(j))+delay_trans_data(from,to);
            number(from,to)=1+number(from,to);
        end
    end
end
for i=1:Nap
    for j=1:Nap
        if i~=j
            delay_trans(i,j)=delay_trans_data(i,j)/number(i,j)/(B/VMnum);
        end
    end
end
dataap=zeros(1,Nap);
dataapmean=zeros(1,Nap);
for i=1:length(Task_AP)
    for j=1:length(Task_AP{i})
        dataap(i)=ceil(Vq(Task_AP{i}(j)))+dataap(i);
    end
    dataapmean(i)=dataap(i)/length(Task_AP{i});
end
temp=zeros(1,Nap);
for k=1:Nap
    eff=diag(ones(1,Nap));
    eff(k,k)=ren;
        delay_ap=dataapmean*eff/VMnum;
        mean_task_time=zeros(1,length(I)+2);
        for i=1:length(Task_AP)
            for j=1:length(Task_AP{i})
                mean_task_time(Task_AP{i}(j))=delay_ap(i);
            end
        end
        
        mean_user_trantime=zeros(length(I)+2,length(I)+2);
        for i=2:length(I)+1
            suc=K{2,i};
            from=find(Map(find(i==Assignrank),:));
            for j=1:length(suc)
                to=find(Map(find(suc(j)==Assignrank),:));
                if from~=to
                    mean_user_trantime(i,suc(j))=Trantimeq(i,suc(j))+delay_trans(from,to);
                end
            end
        end
        [rank_new]=pri(K,Vq+mean_task_time,mean_user_trantime);
        temp(k)=max(rank_new);
end
value=[];
makespan_array=[];
% maxpath_array=cell(length(AR_array),:);
for R=1:length(AR_array)
    
    init_temp=init+1;
    while(init~=init_temp)
        eff=diag(ones(1,Nap));
        eff(k,k)=init;
        delay_ap=dataapmean*eff/VMnum;
        mean_task_time=zeros(1,length(I)+2);
        for i=1:length(Task_AP)
            for j=1:length(Task_AP{i})
                mean_task_time(Task_AP{i}(j))=delay_ap(i);
            end
        end
        
        mean_user_trantime=zeros(length(I)+2,length(I)+2);
        for i=2:length(I)+1
            suc=K{2,i};
            from=find(Map(find(i==Assignrank),:));
            for j=1:length(suc)
                to=find(Map(find(suc(j)==Assignrank),:));
                if from~=to
                    mean_user_trantime(i,suc(j))=Trantimeq(i,suc(j))+delay_trans(from,to);
                end
            end
        end
        [rank_new]=pri(K,Vq+mean_task_time,mean_user_trantime);
        %         maxpath=[1];
        %         i=1;
        %         while i~=length(I)+2
        %             hou=K{2,i};
        %             hourank=rank_new(hou);
        %             temp=[];
        %             for j=1:length(hourank)
        %                 temp(end+1)=hourank(j)+mean_user_trantime(i,hou(j));
        %             end
        %             [~,y]=max(temp);
        %             maxpath(end+1)=hou(y);
        %             i=hou(y);
        %         end
        %         maxpath_array=maxpath
        init_temp=init;
        init=min(max(rank_new)*AR_array(R),ren)*alpha;
        if init_temp==init
            makespan_array(end+1)=max(rank_new);
        end
    end
    
    value(end+1)=init;
end
plot(AR_array,makespan_array,'v-g')
legend('makespan*')
xlabel('λ')
ylabel('时间（s）')
plot (0.004:0.004:0.02,temp{1},'^-b')
hold on
plot (0.004:0.004:0.02,temp{2},'v-r')
hold on
plot (0.004:0.004:0.02,temp{3},'d-k')
hold on
legend('1,makespan*','2,makespan*','3,makespan*')
xlabel('λ')
ylabel('时间（s）')

