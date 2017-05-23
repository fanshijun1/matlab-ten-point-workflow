ren_array=[500];
% AR_array=[0.012 0.016 0.02 0.024 0.028];
AR_array1=[0.004:0.004:0.02];%W3C仿真结果的lambda
AR_array2=0.002:0.002:0.05;%icloudlet 仿真结果lambda
AR_array=0.002:0.002:0.05;%理论值结果lambda
% AR_array=[0.001 0.002 0.004 0.008 0.012 0.016 0.02];
% AR_array=0.05;
recorder=cell(3,3);%行R，列分别放入dcomm，dvm,dadmit
recorder1=cell(3,3);%行R,分别放入有绿线，无绿线，WT
load('AT50')
taskall=[];
makespan1=[];
makespan2=[];
WT1=[];
WT2=[];
maxvalue=[];
for renaca=1:length(ren_array)
    for araca=1:length(AR_array1)
        name=['AP=',num2str(4),' AR=',num2str(AR_array1(araca)),' ren=',num2str(ren_array(renaca)),' clock=650000','.mat'];
       % load(name);
        temp=find(user_state(2,:));
        allmakespan=user_state(2,temp)-user_state(1,temp);
        makespan1(end+1)=mean(allmakespan);
        allWT=user_state(2,temp)-Arrtime(1,temp);
        WT1(end+1)=mean(allWT);
        
        Map_g=Map(1:length(I)+2,:);
        Assignrank_g=Assignrank(1:length(I)+2);
        Transferdataq_g=Transferdataq;
        for i=1:Nap
            task_in_Nap=Assignrank_g(find(Map_g(:,i)));
            for j=1:length(task_in_Nap)-1
                if Transferdataq_g(task_in_Nap(j),task_in_Nap(j+1))==0
                    Transferdataq_g(task_in_Nap(j),task_in_Nap(j+1))=1;
                end
            end
        end
        
        K_g=cell(2,size(Transferdataq_g,2));%% 有绿线的K和Transferdataq
        for i=1:size(Transferdataq_g,2)
            K_g{1,i}=(find(Transferdataq_g(:,i)))';%前节点,
            K_g{2,i}=find(Transferdataq_g(i,:));%后节点，前后驱节点都变成是横向的
        end
        
        ap_channel_task=cell(Nap,Nap);%记录每个AP之间通信的任务号，用一个数表示
        for i=2:size(Map,1)-1
            suc=K{2,i};
            from=find(Map(find(i==Assignrank),:));
            for j=1:length(suc)
                to=find(Map(find(suc(j)==Assignrank),:));
                if from~=to
                    ap_channel_task{from,to}(end+1)=i*100+suc(j);
                end
            end
        end
        ap_data=zeros(Nap,Nap);%AP之间传输的总任务量
        ap_data_means=zeros(Nap,Nap);%AP之间传输的平均数据的任务量
        ap_data_trantime=zeros(Nap,Nap);%AP之间传输的时间，有效带宽除以VMnum
        ap_alldata_trantime=zeros(Nap,Nap);%AP之间所有任务和的传输时间，有效带宽除以VMnum
        for i=1:size(ap_channel_task,1)
            for j=1:size(ap_channel_task,2)
                for k=1:length(ap_channel_task{i,j})
                    temp=ap_channel_task{i,j}(k);
                    ap_data(i,j)=Transferdataq(floor(temp/100),mod(temp,100))+ap_data(i,j);
                end
                if isempty(ap_channel_task{i,j})~=1
                    ap_data_means(i,j)=ap_data(i,j)/length(ap_channel_task{i,j});
                end
                if isempty(ap_channel_task{i,j})~=1
                    ap_data_trantime(i,j)=ap_data_means(i,j)/(B*B_eff(i,j));
                    ap_alldata_trantime(i,j)=ap_data(i,j)/(B*B_eff(i,j));
                end
            end
        end
        task_channel=task_channel(1:clock,:);
        task_channel_mean=mean(task_channel);
        APtoAP_busy=zeros(Nap,Nap);%AP之间平均拥堵的数据传输数量
        for i=1:Nap
            for j=1:Nap
                for k=1:length(ap_channel_task{i,j})
                    temp=find(ap_channel_task{i,j}(k)==task_in_channel);
                    APtoAP_busy(i,j)=APtoAP_busy(i,j)+task_channel_mean(temp);
                end
            end
        end
        %         AP_busy(1,2)=2500;
        delay_trans=zeros(Nap,Nap);
        for i=1:Nap
            for j=1:Nap
                if APtoAP_busy(i,j)~=0
                    delay_trans(i,j)=APtoAP_busy(i,j)*ap_data_trantime(i,j);
                end
            end
        end
        mean_user_trantime=zeros(size(Map,1),size(Map,1));
        mean_trandelay_time=zeros(size(Map,1),size(Map,1));
        for j=2:size(Map,1)
            suc=K{2,j};
            from=find(Map(find(j==Assignrank),:));
            for k=1:length(suc)
                to=find(Map(find(suc(k)==Assignrank),:));
                if from~=to
                    mean_trandelay_time(j,suc(k))=delay_trans(from,to);
                    mean_user_trantime(j,suc(k))=Transferdataq(j,suc(k))/(B*B_eff(from,to))+delay_trans(from,to);
                end
            end
        end
        user_before_task=user_before_task(1:clock,:);
        user_before_task_mean=mean(user_before_task);
        
        AP_busy=zeros(1,Nap);
        for j=2:length(I)+2
            c=find(Assignrank==j);
            the_AP=find(Map(c,:));
            AP_busy(the_AP)=AP_busy(the_AP)+user_before_task_mean(j);
        end
        
        dataap=zeros(1,Nap);
        dataapmean=zeros(1,Nap);
        for i=1:length(Task_map_ap)
            no_zero_task=0;
            for j=1:length(Task_map_ap{i})
                Vq=Iq/(Pap);
                if Task_map_ap{i}(j)<length(I)+2
                    dataap(i)=Vq(Task_map_ap{i}(j))+dataap(i);
                    no_zero_task= no_zero_task+1;
                end
            end
            dataapmean(i)=dataap(i)/ no_zero_task;
        end
        delay_ap=dataapmean*diag(AP_busy);
        mean_task_time=zeros(1,length(user_before_task_mean));% 计算资源延时
        for i=1:length(Task_map_ap)
            for j=1:length(Task_map_ap{i})
                mean_task_time(Task_map_ap{i}(j))=delay_ap(i);
            end
        end
        [rank_new]=pri(K,Iq/(Pap/VMnum)+mean_task_time,mean_user_trantime,I);
        [rank_new_g]=pri(K_g,Iq/(Pap/VMnum)+mean_task_time,mean_user_trantime,I);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   K   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
class=zeros(size(Map,1),size(Map,1));
for i=1:size(Map,1)
    for j=1:size(Map,1)
        if Transferdataq(i,j)~=0
            temp=K{1,i};
            if isempty(temp)
                class(i,j)=1;
            else
                l=1;
                while isempty(find(temp==1))
                    temp1=[];
                    for k=1:length(temp)
                        temp1(end+1:end+length(K{1,temp(k)}))=K{1,temp(k)};
                    end
                    temp=unique(temp1);
                    l=l+1;
                end
                class(i,j)=l+1;
            end
        end
    end
end
ap_i_sign=ap_alldata_trantime;
temp=[];%AP之间传输的总任务量最大值排序
temp1=[];%AP之间传输的总任务量最大值所在位置排序
task_temp=[];%位置排序带来的任务队列
task_class=[];%任务队列对应的class
value1=[];%最长路径的值
relate_task=[];
max_path_array=cell(1,length(find(ap_data_trantime~=0)));
for i=1:length(find(ap_data_trantime~=0))
    [x,y]=find(max(max(ap_i_sign))==ap_i_sign);
    x=x(1);
    y=y(1);
    temp1(end+1,:)=[x,y];
    temp(end+1)=max(max(ap_i_sign));
    ap_i_sign(x,y)=0;
    task_temp(end+1:end+length(ap_channel_task{x,y}))=ap_channel_task{x,y};
    for j=1:length(ap_channel_task{x,y})
        from=floor(ap_channel_task{x,y}(j)/100);
        to=mod(ap_channel_task{x,y}(j),100);
        task_class(end+1)=class(from,to);
    end
    unique_task_class=unique(task_class);
    beta=ren/length(unique_task_class);
    ren_in_channel=zeros(Nap,Nap);
    delay_trans=zeros(Nap,Nap);
    for j=1:length(temp)
        ren_in_channel(temp1(j,1),temp1(j,2))=ceil(beta*length(ap_channel_task{temp1(j,1),temp1(j,2)}));
        delay_trans(temp1(j,1),temp1(j,2))=ceil(beta*length(ap_channel_task{temp1(j,1),temp1(j,2)}))*ap_data_trantime(temp1(j,1),temp1(j,2));
    end
    mean_user_trantime=zeros(size(Map,1),size(Map,1));
    for j=2:size(Map,1)
        suc=K{2,j};
        from=find(Map(find(j==Assignrank),:));
        for k=1:length(suc)
            to=find(Map(find(suc(k)==Assignrank),:));
            if from~=to
                mean_user_trantime(j,suc(k))=Transferdataq(j,suc(k))/(B*B_eff(from,to))+delay_trans(from,to);
            end
        end
    end
    [rank_new]=pri(K,Iq/(Pap/VMnum),mean_user_trantime,I);
    maxpath=[1];
    j=1;
    while j~=length(I)+2
        hou=K{2,j};
        hourank=rank_new(hou);
        temp_max=[];
        for k=1:length(hourank)
            temp_max(end+1)=hourank(k)+mean_user_trantime(j,hou(k));
        end
        [~,y]=max(temp_max);
        maxpath(end+1)=hou(y);
        j=hou(y);
    end
    max_path_array{i}=maxpath;
    value1(end+1)=max(rank_new);
end


[~,k_time]=max(value1);


ap_i_sign=ap_alldata_trantime;
temp=[];%AP之间传输的总任务量最大值排序
temp1=[];%AP之间传输的总任务量最大值所在位置排序
task_temp=[];%位置排序带来的任务队列
task_class=[];%任务队列对应的class
value1=[];%最长路径的值
relate_task=[];
max_path_array=cell(1,length(find(ap_data_trantime~=0)));
for i=1:k_time
    [x,y]=find(max(max(ap_i_sign))==ap_i_sign);
    x=x(1);
    y=y(1);
    temp1(end+1,:)=[x,y];
    temp(end+1)=max(max(ap_i_sign));
    ap_i_sign(x,y)=0;
    task_temp(end+1:end+length(ap_channel_task{x,y}))=ap_channel_task{x,y};
    for j=1:length(ap_channel_task{x,y})
        from=floor(ap_channel_task{x,y}(j)/100);
        to=mod(ap_channel_task{x,y}(j),100);
        task_class(end+1)=class(from,to);
    end
    unique_task_class=unique(task_class);
    beta=ren/length(unique_task_class);
    ren_in_channel=zeros(Nap,Nap);
    delay_trans=zeros(Nap,Nap);
    for j=1:length(temp)
        ren_in_channel(temp1(j,1),temp1(j,2))=ceil(beta*length(ap_channel_task{temp1(j,1),temp1(j,2)}));
        delay_trans(temp1(j,1),temp1(j,2))=ceil(beta*length(ap_channel_task{temp1(j,1),temp1(j,2)}))*ap_data_trantime(temp1(j,1),temp1(j,2));
    end
    mean_user_trantime=zeros(size(Map,1),size(Map,1));
    for j=2:size(Map,1)
        suc=K{2,j};
        from=find(Map(find(j==Assignrank),:));
        for k=1:length(suc)
            to=find(Map(find(suc(k)==Assignrank),:));
            if from~=to
                mean_user_trantime(j,suc(k))=Transferdataq(j,suc(k))/(B*B_eff(from,to))+delay_trans(from,to);
            end
        end
    end
    [rank_new]=pri(K,Iq/(Pap/VMnum),mean_user_trantime,I);
    maxpath=[1];
    j=1;
    while j~=length(I)+2
        hou=K{2,j};
        hourank=rank_new(hou);
        temp_max=[];
        for k=1:length(hourank)
            temp_max(end+1)=hourank(k)+mean_user_trantime(j,hou(k));
        end
        [~,y]=max(temp_max);
        maxpath(end+1)=hou(y);
        j=hou(y);
    end
    max_path_array{i}=maxpath;
    value1(end+1)=max(rank_new);
    max_length=max(rank_new);
end



suc_num=0;
for i=1:length(I)+1
    suc_num=suc_num+length(K{2,i});
end
alpha=suc_num/(length(I)+1);
alpha=1;
value1=[];%value1的意义变了，原为确定拥堵人数的最长路径序列，现为两公式交点的最长路径序列
% maxpath_array=cell(length(AR_array),:);
init=ren_in_channel;
for R=1:length(AR_array)
    init=ren_in_channel;
    init_temp=zeros(Nap,Nap);
    no_zero=find(init~=0);
    for i=1:length(no_zero)
        init_temp(no_zero(i))=100;
    end
    while(isempty(find(init-init_temp))~=1)
        for j=1:length(no_zero)
            delay_trans(temp1(j,1),temp1(j,2))=init(temp1(j,1),temp1(j,2))*ap_data_trantime(temp1(j,1),temp1(j,2));
        end
        mean_user_trantime=zeros(size(Map,1),size(Map,1));
        for j=2:size(Map,1)
            suc=K{2,j};
            from=find(Map(find(j==Assignrank),:));
            for k=1:length(suc)
                to=find(Map(find(suc(k)==Assignrank),:));
                if from~=to
                    mean_user_trantime(j,suc(k))=Transferdataq(j,suc(k))/(B*B_eff(from,to))+delay_trans(from,to);
                end
            end
        end
        [rank_new]=pri(K,Iq/(Pap/VMnum),mean_user_trantime,I);
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
        for j=1:length(no_zero)
            %             init(temp1(j,1),temp1(j,2))=min(max(rank_new)*AR_array1(R)/length(ap_channel_task{temp1(j,1),temp1(j,2)}),ren_in_channel(temp1(j,1),temp1(j,2)))*alpha;
            init(temp1(j,1),temp1(j,2))=min(max(rank_new)*AR_array(R),ren_in_channel(temp1(j,1),temp1(j,2)))*alpha;
        end
        if init_temp==init
            value1(end+1)=max(rank_new);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%通信快%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

init=100;
suc_num=0;
for i=2:length(I)+1
    suc_num=suc_num+length(K{2,i});
end
alpha=suc_num/length(I);
alpha=1;
value4=[];
for k=1:Nap
    eff=diag(ones(1,Nap));
    eff(k,k)=ren;
    delay_ap=dataapmean*eff;
    mean_task_time=zeros(1,size(Map,1));
    for i=1:length(Task_map_ap)
        for j=1:length(Task_map_ap{i})
            mean_task_time(Task_map_ap{i}(j))=delay_ap(i);
        end
    end
    
    mean_user_trantime=zeros(size(Map,1),size(Map,1));
    for i=2:size(Map,1)
        suc=K{2,i};
        from=find(Map(find(i==Assignrank),:));
        for j=1:length(suc)
            to=find(Map(find(suc(j)==Assignrank),:));
            if from~=to
                mean_user_trantime(i,suc(j))=Transferdataq(i,suc(j))/(B*B_eff(from,to))+ap_data_trantime(from,to);
            end
        end
    end
    [rank_new]=pri(K,Iq/(Pap/VMnum)+mean_task_time,mean_user_trantime,I);
    value4(end+1)=max(rank_new);
end
[~,k]=max(value4);
value4=[];
for R=1:length(AR_array)
    init_temp=init+1;
    while(init~=init_temp)
        eff=diag(ones(1,Nap));
        eff(k,k)=init;
        delay_ap=dataapmean*eff;
        mean_task_time=zeros(1,size(Map,1));
        for i=1:length(Task_map_ap)
            for j=1:length(Task_map_ap{i})
                if  Task_map_ap{i}(j)<length(I)+2
                    mean_task_time(Task_map_ap{i}(j))=delay_ap(i);
                end
            end
        end
        
        mean_user_trantime=zeros(size(Map,1),size(Map,1));
        for i=2:size(Map,1)
            suc=K{2,i};
            from=find(Map(find(i==Assignrank),:));
            for j=1:length(suc)
                to=find(Map(find(suc(j)==Assignrank),:));
                if from~=to
                    mean_user_trantime(i,suc(j))=Transferdataq(i,suc(j))/(B*B_eff(from,to))+ap_data_trantime(from,to);
                end
            end
        end
        [rank_new]=pri(K,Iq/(Pap/VMnum)+mean_task_time,mean_user_trantime,I);
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
            value4(end+1)=max(rank_new);
        end
    end
end
d_AP=sum(I)/length(I)/Pap;
link=0;
all_tran=0;
for i=1:Nap
    for j=1:Nap
        link=link+length(ap_channel_task{i,j});
        all_tran=ap_data(i,j)+all_tran;
    end
end
d_link=all_tran/link/B;
value10=[];
for i=1:length(AR_array)
    value10(end+1)=value1(i)*d_link/(d_AP+d_link)+value4(i)*d_AP/(d_AP+d_link);
end



for araca=1:length(AR_array2)
    name=['AP=',num2str(4),' AR=',num2str(AR_array2(araca)),'.mat'];
    load(name);
    temp=find(user_state(2,:));
    allmakespan=user_state(2,temp)-user_state(1,temp);
    makespan2(end+1)=mean(allmakespan);
    allWT=user_state(2,temp)-Arrtime(1,temp);
    WT2(end+1)=mean(allWT);
end

% plot(AR_array,value1,'v-g')
% hold on
% plot(AR_array,value4,'d-c')
% hold on
plot(AR_array,value10,'x-b')
hold on
% plot(AR_array1,value10,'d-g')
% hold on
plot(AR_array1,makespan1,'*-r')
hold on
% plot(AR_array1,WT1,'^-r')
% hold on
% plot(AR_array2,makespan2,'^-y')
% hold on

% plot(AR_array2,WT2,'^-y'),'makespan,icloud
legend('makespan*','makespan,W3C')
xlabel('到达率')
ylabel('时间（s）')






