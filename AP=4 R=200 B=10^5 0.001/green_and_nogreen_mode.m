ren_array=[200];
% AR_array=[0.012 0.016 0.02 0.024 0.028];
AR_array=[0.005 0.01:0.01:0.05];
% AR_array=0.05;
recorder=cell(3,3);%行R，列分别放入dcomm，dvm,dadmit
recorder1=cell(3,3);%行R,分别放入有绿线，无绿线，WT
load('AT50')
makespan=[];
green_line=[];
nogreen_line=[];
for renaca=1:length(ren_array)
    for araca=1:length(AR_array)
        name=['AP=',num2str(4),' AR=',num2str(AR_array(araca)),' ren=',num2str(ren_array(renaca)),' clock=1000000','.mat'];
        load(name);
        temp=find(user_state(2,:));
        allmakespan=user_state(2,temp)-user_state(1,temp);
        makespan(end+1)=mean(allmakespan);
        
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
%         maxpath=[1];
%         j=1;
%         while j~=length(I)+2
%             hou=K{2,j};
%             hourank=rank_new(hou);
%             temp_max=[];
%             for k=1:length(hourank)
%                 temp_max(end+1)=hourank(k)+mean_user_trantime(j,hou(k));
%             end
%             [~,y]=max(temp_max);
%             maxpath(end+1)=hou(y);
%             j=hou(y);
%         end
        nogreen_line(end+1)=max(rank_new);
        
        [rank_new_g]=pri(K_g,Iq/(Pap/VMnum)+mean_task_time,mean_user_trantime,I);
%         maxpath=[1];
%         j=1;
%         while j~=length(I)+2
%             hou=K_g{2,j};
%             hourank=rank_new_g(hou);
%             temp_max=[];
%             for k=1:length(hourank)
%                 temp_max(end+1)=hourank(k)+mean_user_trantime(j,hou(k));
%             end
%             [~,y]=max(temp_max);
%             maxpath(end+1)=hou(y);
%             j=hou(y);
%         end
        green_line(end+1)=max(rank_new_g);
    end
end
plot(AR_array,nogreen_line,'d-r')
hold on
plot(AR_array,green_line,'v-b')
hold on
plot(AR_array,makespan,'x-c')
legend('有绿线最长路径','无绿线最长路径','makespan')
xlabel('到达率')
ylabel('时间（s）')