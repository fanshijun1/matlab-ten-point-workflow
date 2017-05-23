%%%%%%%%%%%%%%%%%%%%��һ�׶Σ�PCP��ѡȡ�ͻ�վ�ķ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ user_state ] = Main( Nap,AR,Arrtime,ren,AP_loca)
Pap=100000;%����AP��ִ������
VMnum=10;
% Nap=25;
P=ones(1,Nap)*Pap/VMnum;
Channum=100;
B=10^5;
% Transferdata=[0,0,0,0,8334624,0,8873456,0,0;
%     0,0,0,0,8343702,8517569,0,0,0;
%     0,0,0,0,7511132,8340796,8324756,0,0;
%     0,0,0,0,0,815689,7853276,0,0;
%     0,0,0,0,0,0,0,8326168,0;
%     0,0,0,0,0,0,0,8861129,1861129;
%     0,0,0,0,0,0,0,8315294,8341716;
%     0,0,0,0,0,0,0,0,0;
%     0,0,0,0,0,0,0,0,0;];
Transferdata=[0,0,0,0,8334624,0,8873456,0;
    0,0,0,0,0,8517569,0,0;
    0,0,0,0,7511132,8340796,8324756,0;
    0,0,0,0,0,0,7853276,0;
    0,0,0,0,0,0,0,8326168;
    0,0,0,0,0,0,0,8861129;
    0,0,0,0,0,0,0,8315294;
    0,0,0,0,0,0,0,0;];
% Transferdata=[0,0,0,0,8334624,0,8873456,0;
%     0,0,0,0,8343702,8517569,0,0;
%     0,0,0,0,7511132,8340796,8324756,0;
%     0,0,0,0,0,815689,7853276,0;
%     0,0,0,0,0,0,0,8326168;
%     0,0,0,0,0,0,0,8861129;
%     0,0,0,0,0,0,0,8315294;
%     0,0,0,0,0,0,0,0;];
data_name=['AP=',num2str(Nap),' AR=',num2str(AR),' ren=',num2str(ren),'.mat'];
%��������Ĺ�ϵD
B_eff=zeros(Nap,Nap);
distance_ap=zeros(Nap,Nap);
for i=1:Nap
    for j=1:Nap
        distance=sqrt((AP_loca(i,1)-AP_loca(j,1))^2+(AP_loca(i,2)-AP_loca(j,2))^2);
        distance_ap(i,j)=distance;
        if distance>800
            B_eff(i,j)=0;
        end
        if distance<=800&&distance>600
            B_eff(i,j)=0;
        end
        if distance<=600&&distance>400
            B_eff(i,j)=0;
        end
        if distance<=400&&distance>200
            B_eff(i,j)=0;
        end
        if distance<=200&&distance>0
            B_eff(i,j)=1;
        end
    end
end

D=zeros(size(Transferdata,1),size(Transferdata,2));
for i=1:size(Transferdata,1)
    for j=1:size(Transferdata,2)
        if Transferdata(i,j)>0
            D(i,j)=1;
        end
    end
end

E=zeros(size(D,1)+2,size(D,2)+2);
E(2:end-1,2:end-1)=D;%��entry exit
Hel=sum(E);%�����
Heh=sum(E,2);%�����
Transferdataq=zeros(size(Transferdata,1)+2,size(Transferdata,2)+2);
for j=2:size(E)-1
    if Hel(j)==0;
        E(1,j)=1;
        Transferdataq(1,j)=1;
    end
end   %��entry��������ϵ
for i=2:size(E)-1
    if Heh(i)==0;
        E(i,size(E))=1;
        Transferdataq(i,size(E))=1;
    end
end   %��exit��������ϵ

K=cell(2,size(E,2));
for i=1:size(E,2)
    K{1,i}=(find(E(:,i)))';%ǰ�ڵ�,
    K{2,i}=find(E(i,:));%��ڵ㣬ǰ�����ڵ㶼����Ǻ����
end   %����ֱ��ǰ����������



Transferdataq(2:end-1,2:end-1)=Transferdata;
Trantime=Transferdata/B;
Trantimeq=Transferdataq/B;
% xlswrite('distance1.xls',Transferdataq);
I=[1339000,1383000,1336000,1378000,1037000,1059000,1088000,1755000];
Iq=[0.00001 I 0];

Exetime=zeros(length(P),size(D,2));
for i=1:size(D,2)
    for j=1:size(P,2)
        Exetime(j,i)=I(i)/P(j);
    end
end
Exetimeq=zeros(size(P,2),size(E,2));
Exetimeq(:,2:end-1)=Exetime;


V=zeros(1,size(D,2));
for i=1:size(D,2)
    heExetime=0;
    for j=1:size(P,2)
        heExetime=heExetime+Exetime(j,i);
    end
    V(i)=heExetime/size(P,2);
end   %����ÿ������MeanExetime����������V��
Vq=[0 V 0];
[rank]=pri_Bequal0(K,Vq,Trantimeq,I);
% [rank]=pri(K,Vq,Trantimeq,I);
ranksign=rank;
ranksign(1)=0; %�Ѿ�������Ϊȫ�ֵı�������ǰ��ĳ����У����Ƿ�sign
PCPcell={};
[PCPcell,ranksign] = SearchPCP(1,PCPcell,ranksign,K);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%�����㷨��ֻ����һ��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PCP     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[  Map,TSF,Assignrank,Iq,Transferdataq] = AssignPCP( PCPcell,K,Exetimeq,rank,P,Transferdataq,B,Nap,B_eff,Iq);


K=cell(2,size(Transferdataq,2));
for i=1:size(Transferdataq,2)
    K{1,i}=(find(Transferdataq(:,i)))';%ǰ�ڵ�,
    K{2,i}=find(Transferdataq(i,:));%��ڵ㣬ǰ�����ڵ㶼����Ǻ����
end   %����ֱ��ǰ����������

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

K_g=cell(2,size(Transferdataq_g,2));%% �����ߵ�K��Transferdataq
for i=1:size(Transferdataq_g,2)
    K_g{1,i}=(find(Transferdataq_g(:,i)))';%ǰ�ڵ�,
    K_g{2,i}=find(Transferdataq_g(i,:));%��ڵ㣬ǰ�����ڵ㶼����Ǻ����
end 
Transtimeq_g=Transferdataq_g/B;
for i=1:Nap
    task_in_Nap=Assignrank_g(find(Map_g(:,i)));
    for j=1:length(task_in_Nap)
        for k=1:length(task_in_Nap)
            if Transtimeq_g(task_in_Nap(j),task_in_Nap(k))~=0
            end
            Transtimeq_g(task_in_Nap(j),task_in_Nap(k))=0;
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �������·��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [rank_g]=pri(K_g,Iq/(Pap/VMnum),Transtimeq_g,I);
% maxpath=[1];
% j=1;
% while j~=length(I)+2
%     hou=K_g{2,j};
%     hourank=rank_g(hou);
%     temp_max=[];
%     for k=1:length(hourank)
%         temp_max(end+1)=hourank(k)+Transtimeq_g(j,hou(k));
%     end
%     [~,y]=max(temp_max);
%     maxpath(end+1)=hou(y);
%     j=hou(y);
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% �������·��%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HEFT    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ Map,TSF,Assignrank] = HEFT( rank,P,K,Exetimeq,Trantimeq);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PSO     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ gMap ] = PSO( rank,Trantimeq,K,Exetimeq,P );
Task_map_ap=cell(1,Nap);
for i=1:Nap
    Task_map_ap{i}=Assignrank(find(Map(:,i)));
end
Map(1,1)=0.0001;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%�ڶ��׶Σ�AP�ڶ�άƽ����λ�õ�ѡȡ%%%%%%%%%%%%%%%%%%%%
%ĳAP���ڲ����ⲿ�����ݴ������LP,�����Լ�
LP=zeros(length(P),length(P));
Channeldata=zeros(length(P),length(P));
for i=1:length(P)
    locagather=find(Map(:,i));
    for k=1:length(locagather)
        temp1=Assignrank(locagather(k));
        for l=1:length(K{2,temp1})
            temp2=find(Assignrank==K{2,temp1}(l));
            temp3=find(Map(temp2,:));
            LP(i,temp3)=LP(i,temp3)+1;
            Channeldata(i,temp3)= Channeldata(i,temp3)+Transferdataq(temp1,K{2,temp1}(l));
        end
    end
end
%ȥ���Լ�
LPqu=LP;
Channeldataqu=Channeldata;
for i=1:length(P)
    LPqu(i,i)=0;
    Channeldataqu(i,i)=0;
end
Channel=cell(size(P,2),size(P,2));
for i=1:size(P,2)
    for j=1:size(P,2)
        if i~=j
            Channel{i,j}=[1];
        end
    end
end
%%%%%%%%VM2Task�Ľṹ����%%%%%%%%%
for vm=1:ren %һ��ʮ����ÿһ����Ӧһ��VM���ڲ�װ�����ڸ���AP����ӦVM��ŵ�Task
    VM2Task(vm).user_id=0;
    VM2Task(vm).resttask=[];
    VM2Task(vm).vir_resttask=[];
    VM2Task(vm).id=vm;
    for i=1:size(Map,1)
        VM2Task(vm).Task(i).rei=Iq(i); %����ʣ��������������ʼ��
        VM2Task(vm).Task(i).Task_id=i;
        temp=find(i==Assignrank);
        VM2Task(vm).Task(i).Map_AP=find(Map(temp,:));%����ķ�����ѡ��ĳ�ʼ��
        VM2Task(vm).Task(i).pre=K{1,i};
        VM2Task(vm).Task(i).suc=K{2,i};
        VM2Task(vm).reTransferdata=Transferdataq;
    end
end

%%%%%%%AP�Ľṹ����%%%%%%%%%
task_id_list=cell(1,length(P));% ���id����ʵ��Task������˳��
for i=1:length(P)
    AP(i).AP_id=i;
    temp=(find(Map(:,i)))';
    task_id_list{1,i}=Assignrank(temp);
end
AP=struct('task_id_list',task_id_list);

%%%%%%%CS�Ľṹ����%%%%%%%%%
for ap=1:length(P)
    temp=find(LPqu(ap,:));
    for cs=1:length(temp)
        AP(ap).CS(cs).from=ap;
        AP(ap).CS(cs).to=temp(cs);
        AP(ap).CS(cs).channel_num=Channel{ap,temp(cs)};
        AP(ap).CS(cs).pointer=1;%ָ�룬ָ�򣬲��ϵ����ӣ�ָ��ͬ��queue
        for que=1:VMnum
            AP(ap).CS(cs).queue(que).state=0;
            AP(ap).CS(cs).queue(que).from_vm=vm;
            AP(ap).CS(cs).queue(que).front=1;
            AP(ap).CS(cs).queue(que).rear=1;
            
            AP(ap).CS(cs).queue(que).data.from_task=0;
            AP(ap).CS(cs).queue(que).data.to_task=0;
            AP(ap).CS(cs).queue(que).data.amount=0;
            %             AP(ap).CS(cs).queue(que).data.from_vm_id=0;
            AP(ap).CS(cs).queue(que).data.gt=0;
            AP(ap).CS(cs).queue(que).data.tft=0;
            AP(ap).CS(cs).queue(que).data.tat=0;
            AP(ap).CS(cs).queue(que).data.last_trans_clock=0;
        end
    end
end
% for ap=1:length(P)
%     temp=find(LPqu(ap,:));
%     for cs=1:length(temp)
%         AP(ap).CS(cs).from=ap;
%         AP(ap).CS(cs).to=temp(cs);
%         AP(ap).CS(cs).channel_num=Channel{ap,temp(cs)};
%         AP(ap).CS(cs).pointer=1;%ָ�룬ָ�򣬲��ϵ����ӣ�ָ��ͬ��queue
%         for que=1:VMnum
%             AP(ap).CS(cs).queue(que).state=0;
%             AP(ap).CS(cs).queue(que).from_vm=vm;
%             AP(ap).CS(cs).queue(que).front=1;
%             AP(ap).CS(cs).queue(que).rear=1;
%             
%             AP(ap).CS(cs).queue(que).data.from_task=0;
%             AP(ap).CS(cs).queue(que).data.to_task=0;
%             AP(ap).CS(cs).queue(que).data.amount=0;
%             %             AP(ap).CS(cs).queue(que).data.from_vm_id=0;
%             AP(ap).CS(cs).queue(que).data.gt=0;
%             AP(ap).CS(cs).queue(que).data.tft=0;
%             AP(ap).CS(cs).queue(que).data.tat=0;
%             AP(ap).CS(cs).queue(que).data.last_trans_clock=0;
%         end
%     end
% end

%%%%%%%VM�Ľṹ����%%%%%%%%%
% task_list=cell(1,length(P));% ���װ����task Ҳ�ǽṹ��
% for ap=1:length(P)
%     temp=(find(Map(:,ap)))';
%     temp1=cell(1,length(temp));
%     for j=1:length(temp)
%         temp1{1,j}=VM2Task(1).Task(Assignrank(temp(j)));
%     end
%     task_list{1,ap}=temp1;
% end
for ap=1:length(P)
    temp=(find(Map(:,ap)))';
    temp1=cell(1,length(temp));
    for vm=1:VMnum
        AP(ap).VM(vm).Pvm=P(ap);
        AP(ap).VM(vm).id=vm;
        AP(ap).VM(vm).state=0;%����״̬
        AP(ap).VM(vm).user_id=0;%VM���������û���
        AP(ap).VM(vm).Nowin=0; %��������ִ�е�����,��ʼ��ָ��1
        AP(ap).VM(vm).task_list=temp1;
        AP(ap).VM(vm).cat=0;%�����r�������v�ļ���ʱ���ۼ�
    end
end


task_in_channel=[];
for i=2:size(Map,1)
    suc=K_g{2,i};%�������γɵ�ǰ������ϵһ����ͬһ��AP��û�д�����ʱ��������K��K_g��һ��
    from=find(Map(find(i==Assignrank),:));
    for j=1:length(suc)
        to=find(Map(find(suc(j)==Assignrank),:));
        if from~=to
            task_in_channel(end+1)=i*100+suc(j);
        end
    end
end

clock=0;
clock_step=1;
Can=1;
Tmax=1000000;
% Arrtime=[1];
% Arrtimesign=Arrtime;

user_state=[];%��һ�б�ϵͳ����ʱ�䣬�ڶ����û�����ʱ��
Arrtimesign=Arrtime;
sign=ones(1,length(rank)-1);
User_trantime=cell(1,50000);
for i=1:length(User_trantime)
    User_trantime{i}=zeros(size(Transferdataq,1),size(Transferdataq,2));
end
task_start_time=zeros(50000,size(Transferdataq,1));%���������ǰ����ִ�����clock
task_start_timesign=zeros(50000,size(Transferdataq,1));
task_wait_time=zeros(50000,size(Transferdataq,1));%��������ǰ����ִ���꣬�����Ѿ�������vm�Ŀ�ʼʱ��
user_vm_id=zeros(50000,Nap);%��¼ÿ��APʹ�õ�VM�ı��
ap_used_vm=zeros(1,Nap);%ÿ��AP���Ѿ���ʹ���˵�VM����Ŀ
VM2Task_id=zeros(1,ren);%����˳��������VM2Task�е�user��ţ������ڵ���0��ʾ
used_VM2Task=0;
y_point=0;
user_in_vm=zeros(Tmax,size(Transferdataq,1));
user_before_task=zeros(Tmax,size(Transferdataq,1));
task_channel=zeros(Tmax,length(task_in_channel));
while clock<Tmax
    
    %%%%%%%%%%%%%%%%%����user���������user��VM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     if isempty(find(clock<Arrtime<clock+clock_step))==0
    
    VM2Task_id_sign=VM2Task_id;
    for z=1:ren
        vir_resttask=VM2Task(z).vir_resttask;
        resttask=VM2Task(z).resttask;
        for i=1:length(vir_resttask)
            user_id=VM2Task(z).user_id;
            Map_AP=VM2Task(z).Task(vir_resttask(i)).Map_AP;
            pretask=VM2Task(z).Task(vir_resttask(i)).pre;
            pretaskrei=[];%��������ǰ�������ʣ��������
            for j=1:length(pretask)
                pretaskrei(end+1)=VM2Task(z).Task(pretask(j)).rei;
            end
            pretasktrans=[];%��������ǰ���Ƿ���ɴ���
            for j=1:length(pretask)
                pretasktrans(end+1)=VM2Task(z).reTransferdata(pretask(j),vir_resttask(i));
            end
            if (user_id==6||user_id==7)&&isempty(vir_resttask)~=1&&isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
            end
            if isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                if task_start_timesign(user_id,vir_resttask(i))==0
                    task_start_time(user_id,vir_resttask(i))=clock;
                    task_start_timesign(user_id,vir_resttask(i))=1;
                    task_wait_time(user_id,vir_resttask(i))=clock;
                end
            end
            if isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                if z==2 && suc_id==11
                end
                                if z==2
                end
                suc_id=VM2Task(1).Task(vir_resttask(i)).suc;%���������id
                receiver=VM2Task(1).Task(suc_id).Map_AP;%�����������ڵ�AP,VM2Task(1)�оͿ����ҵ�
                needadd_AP=[];%������Ҫ���бȽϵ�ͨ���AP
                needadd_AP_cs=[];
                for j=1:length(suc_id)
                    needadd_AP(end+1)=suc_id(j);
                    for k=1:length(AP(Map_AP).CS)
                        if AP(Map_AP).CS(k).to==VM2Task(1).Task(suc_id(j)).Map_AP
                            choice=k;
                            break
                        end
                    end
                    needadd_AP_cs(end+1)=choice;
                end
                resti_temp=zeros(1,VMnum);
                for vm1=1:VMnum
                    for j=1:length(needadd_AP_cs)
                        for k=AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).front:AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).rear
                            resti_temp(vm1)=AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).data(k).amount+resti_temp(vm1);
                        end
                    end
                end
                [~,vm1]=min(resti_temp);
                

                user_vm_id(user_id,Map_AP)=vm1;
                i1=find(VM2Task(z).vir_resttask==vir_resttask(i));
                VM2Task(z).vir_resttask(i1)=[];
                
                if AP(Map_AP).CS(choice).queue(vm1).state==0
                    AP(Map_AP).CS(choice).queue(vm1).state=1;%Ԥ��״̬������ִ�е����clock���У�����ִ��,����һʱ�̴��䴦�����֮�󣬱�Ϊ1����ʱrear==front==1���������ݺ�rear��Ȼָ���β��front��Ȼָ���ͷ
                else
                    AP(Map_AP).CS(choice).queue(vm1).rear=AP(Map_AP).CS(choice).queue(vm1).rear+1;%������������data�����ʱ��rearָ�����һ��data
                end
                if ap==7&&cs==1&&vm==5
                end
                rear=AP(Map_AP).CS(choice).queue(vm1).rear;
                AP(Map_AP).CS(choice).queue(vm1).data(rear).from_task=vir_resttask(i);
                AP(Map_AP).CS(choice).queue(vm1).data(rear).to_task=suc_id;
                AP(Map_AP).CS(choice).queue(vm1).data(rear).amount=Transferdataq(vir_resttask(i),suc_id);
                %                                         AP(ap).CS(choice).queue(vm).data(rear).from_vm_id=vm1;
                AP(Map_AP).CS(choice).queue(vm1).data(rear).gt=clock;
                %                                     AP(ap).CS(choice).queue(vm).data(rear).tft=0;
                AP(Map_AP).CS(choice).queue(vm1).data(rear).tat=clock;
                AP(Map_AP).CS(choice).queue(vm1).data(rear).last_trans_clock=0;%
                AP(Map_AP).CS(choice).queue(vm1).data(rear).user_id=user_id;
                if vir_resttask(i)==32
                end
                if isempty(find(resttask==suc_id))==1 && task_start_time(user_id,suc_id)==0 && suc_id<=length(I)+2
                    VM2Task(z).resttask(end+1)=suc_id;
                end
                if isempty(find(vir_resttask==suc_id))==1 && task_start_time(user_id,suc_id)==0 && suc_id>length(I)+2
                    VM2Task(z).vir_resttask(end+1)=suc_id;
                end
            end
        end
        
        
        
    end
    
    for z=1:ren
        y=mod(y_point+z-1,ren);
        if y==0
            y=ren;
        end
        resttask=VM2Task(y).resttask;
        if length(find(ap_used_vm==VMnum))==Nap
            y_point=mod(y_point,ren)+1;
            
            break
        else
            if z==ren
                y_point=mod(y_point+1,ren);
            end
            for i=1:length(resttask)
                user_id=VM2Task(y).user_id;
                Map_AP=VM2Task(y).Task(resttask(i)).Map_AP;
                pretask=VM2Task(y).Task(resttask(i)).pre;
                pretaskrei=[];%��������ǰ�������ʣ��������
                for j=1:length(pretask)
                    pretaskrei(end+1)=VM2Task(y).Task(pretask(j)).rei;
                end
                pretasktrans=[];%��������ǰ���Ƿ���ɴ���
                for j=1:length(pretask)
                    pretasktrans(end+1)=VM2Task(y).reTransferdata(pretask(j),resttask(i));
                end
                if (user_id==6||user_id==7)&&isempty(resttask)~=1&&isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                end
                if user_id==2
                end
                if isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                    if task_start_timesign(user_id,resttask(i))==0
                        task_start_time(user_id,resttask(i))=clock;
                        task_start_timesign(user_id,resttask(i))=1;
                    end
                end
                if ap_used_vm(Map_AP)==VMnum&&isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                end
                if ap_used_vm(Map_AP)<VMnum&&isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                    needadd_AP=[];%������Ҫ���бȽϵ�ͨ���AP
                    needadd_AP_cs=[];
                    suc_1=VM2Task(1).Task(resttask(i)).suc;
                    for j=1:length(suc_1)
                        if VM2Task(1).Task(suc_1(j)).Map_AP~=Map_AP
                            needadd_AP(end+1)=suc_1(j);
                            for k=1:length(AP(Map_AP).CS)
                                if AP(Map_AP).CS(k).to==VM2Task(1).Task(suc_1(j)).Map_AP
                                    choice=k;
                                    break
                                end
                            end
                            needadd_AP_cs(end+1)=choice;
                        end
                    end
                    resti_temp=zeros(1,VMnum);
                    for vm1=1:VMnum
                        if AP(Map_AP).VM(vm1).state==0
                            for j=1:length(needadd_AP_cs)
                                for k=AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).front:AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).rear
                                    resti_temp(vm1)=AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).data(k).amount+resti_temp(vm1);
                                end
                            end
                        else resti_temp(vm1)=inf;
                        end
                    end
                    [~,vm1]=min(resti_temp);
                    if task_wait_time(user_id,resttask(i))==0%&&VM2Task(vm).Task(pre_task_temp).rei==0)%��ǰ������ǰ����������ʣ���˲����Ѿ��������
                        task_wait_time(user_id,resttask(i))=clock;
                    end
                    AP(Map_AP).VM(vm1).state=2;%VM��״̬����Ϊ1
                    AP(Map_AP).VM(vm1).user_id=user_id;%ͬһ��userʹ�ò�ͬAP����ͬ��ŵ�VM
                    AP(Map_AP).VM(vm1).Nowtask=resttask(i);
                    AP(Map_AP).VM(vm1).cat=0;
                    user_vm_id(user_id,Map_AP)=vm1;
                    ap_used_vm(Map_AP)=ap_used_vm(Map_AP)+1;
                    i1=find(VM2Task(y).resttask==resttask(i));
                    VM2Task(y).resttask(i1)=[];
                end
            end
        end
    end
    Can=1;%�������У������п��е�VM
    while isempty(find(Arrtimesign))~=1&&Arrtimesign(min(find(Arrtimesign)))<clock+clock_step&&Can==1&&used_VM2Task<ren;%����ʱ��С��clock��VM���п��У��������еı�־Ϊ1
        user_in_task=min(find(Arrtimesign));
        if user_in_task==5
        end
        for vm=1:VMnum
            if AP(1).VM(vm).state==0  %ֻ���һ��AP��˵�������е�VM��״̬����Ϊ�û������е�AP�л�õ�VM�ı�Ŷ���һ����
                AP(1).VM(vm).state=1;%VM��״̬����Ϊ1
                AP(1).VM(vm).user_id=user_in_task;%ͬһ��userʹ�ò�ͬAP����ͬ��ŵ�VM
                if user_in_task==37
                end
                AP(1).VM(vm).Nowtask=1;
                AP(1).VM(vm).cat=0;
                user_state(1,user_in_task)=clock; %�����û���ʼʱ�䣬��һʱ�̵Ľ�β����һ��ʱ�̵Ŀ�ʼΪ��ʱ��
                user_state(2:5,user_in_task)=0;
                Arrtimesign(user_in_task)=0;
                user_vm_id(user_in_task,1)=vm;
                ap_used_vm(1)=1+ap_used_vm(1);
                for i=1:ren
                    if VM2Task(i).user_id==0
                        VM2Task(i).user_id=user_in_task;
                        VM2Task_id(i)=user_in_task;
                        used_VM2Task=1+used_VM2Task;
                        break
                    end
                end
                break
            end
        end
        
        Can=0; %�ȸ�ֵΪ�㣬�������п��е�VM�ٸ�
        for vm=1:VMnum
            if AP(1).VM(vm).state==0
                Can=1;
                break
            end
        end  %ˢ��Can��ֵ
    end  %���������VM�Ѿ����������
    for i=1:ren
        resttask=VM2Task(i).resttask;
        if isempty(resttask)~=1
            temp_flag=zeros(1,Nap);
            for j=1:length(resttask)
                pretask=VM2Task(i).Task(resttask(j)).pre;
                pretaskrei=[];%��������ǰ�������ʣ��������
                for k=1:length(pretask)
                    pretaskrei(end+1)=VM2Task(i).Task(pretask(k)).rei;
                end
                pretasktrans=[];%��������ǰ���Ƿ���ɴ���
                for k=1:length(pretask)
                    pretasktrans(end+1)=VM2Task(i).reTransferdata(pretask(k),resttask(j));
                end
                if isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
                    if clock~=0
                        user_before_task(clock,resttask(j))=1+user_before_task(clock,resttask(j));
                    end
                end
            end
        end
    end
    ARR=Arrtimesign(Arrtimesign>0&Arrtimesign<clock);
    if clock~=0
        user_before_task(clock,1)=length(ARR);
    end
    for ap=1:Nap
        for vm=1:VMnum
            if AP(ap).VM(vm).state~=0
                if clock~=0
                    user_in_vm(clock,AP(ap).VM(vm).Nowtask)=user_in_vm(clock,AP(ap).VM(vm).Nowtask)+1;
                end
            end
        end
    end
    temp_AP=AP;%ԭ��״̬��temp_AP��ͨ����temp_AP���жϸı�AP
    for ap=1:length(P)
        for vm=1:VMnum
            if temp_AP(ap).VM(vm).state==1 %������VMû�������ң����ڵ�ָ��С�������б������������ִ�С�
                user_id=temp_AP(ap).VM(vm).user_id;
                %                 if user_id==5&&ap==15
                %                 end
                Nowtask=temp_AP(ap).VM(vm).Nowtask;%����ָ����������Nowtask
                vm_1=find(VM2Task_id==user_id);
                resttask=VM2Task(vm_1).resttask;
                VM2Task(vm_1).Task(Nowtask).rei=VM2Task(vm_1).Task(Nowtask).rei-AP(1).VM(1).Pvm*clock_step;%����VM2Task�еĵ���Task��rei
                AP(ap).VM(vm).cat=AP(ap).VM(vm).cat+clock_step;%ˢ������û������AP�ϵ�һ����ʱ�䣬������һ��clock_step,��Ϊ���һ������Ҳ�и�ʱ����ǰ������ɵģ�Ҳ������һ��clock_step
                %                   AP(ap).VM(vm).Sumofcat=AP(ap).VM(1vm).Sumofcat+clock_step;
                if VM2Task(vm_1).Task(Nowtask).rei<=0 %�ж��Ƿ�Ϊ���һ��ʱ��㣬��Task�����ˣ�������֮�󣬿���������
                    VM2Task(vm_1).Task(Nowtask).rei=0;
                    user_state(3,user_id)=user_state(3,user_id)+AP(ap).VM(vm).cat;
                    AP(ap).VM(vm).state=0;
                    AP(ap).VM(vm).user_id=0;
                    AP(ap).VM(vm).Nowtask=0;
                    AP(ap).VM(vm).cat=0;
                    user_vm_id(user_id,ap)=0;
                    ap_used_vm(ap)=ap_used_vm(ap)-1;
                    suctask=VM2Task(vm_1).Task(Nowtask).suc;
                    if suctask==length(rank)%�ж��Ƿ��������exit������
                        exitpre=VM2Task(vm_1).Task(suctask).pre;
                        exitprerei=[];
                        for i=1:length(exitpre)
                            exitprerei(end+1)=VM2Task(vm_1).Task(exitpre(i)).rei;
                        end
                        if isempty(find(exitprerei))==1%exit�����ǰ�����Ѿ����
                            if user_id>min(VM2Task_id(find(VM2Task_id)))
                            end
                            user_state(2,user_id)=clock;%���ʱ�̣�����һ��clock��ʱ�����ϵĵ㣬ָ�������ʱ�̵Ľ��������д洢
                            VM2Task(vm_1).user_id=0;
                            VM2Task_id(vm_1)=0;
                            used_VM2Task=used_VM2Task-1;
                            for i=1:length(rank)
                                VM2Task(vm_1).Task(i).rei=Iq(i); %����ʣ��������������ʼ��
                                VM2Task(vm_1).reTransferdata=Transferdataq;
                            end
                        end
                        save([data_name]);
                        % % % % % % % % % % % % % % % % % % % % % %                          save
                    else %�н���һ����Task����֮�󣬺���������
                        if Nowtask==1
                            for i=1:length(suctask)
                                suc_id=suctask(i);%���������id
                                VM2Task(vm_1).reTransferdata(Nowtask,suc_id)=0;
                            end
                            VM2Task(vm_1).resttask=suctask;
                        else
                            for i=1:length(suctask)
                                suc_id=suctask(i);%���������id
                                receiver=VM2Task(1).Task(suc_id).Map_AP;%�����������ڵ�AP,VM2Task(1)�оͿ����ҵ�
                                if isempty(find(resttask==suc_id))==1&&task_start_time(user_id,suc_id)==0
                                    if suc_id>length(I)+2
                                        VM2Task(vm_1).vir_resttask(end+1)=suc_id;
                                    else
                                        VM2Task(vm_1).resttask(end+1)=suc_id;
                                    end
                                end
                                if ap==receiver%�����apִ��,����CS
                                    
                                    VM2Task(vm_1).reTransferdata(Nowtask,suc_id)=0;
                                    %                                         VM2Task(vm_1).Task(Nowtask).rei=0;
                                    %                                     end
                                else %�������apִ�У���ͨ��CS���͵�������AP
                                    for j=1:length(AP(ap).CS)
                                        if AP(ap).CS(j).to==receiver
                                            choice=j;
                                            break
                                        end
                                    end
                                    if AP(ap).CS(choice).queue(vm).state==0
                                        AP(ap).CS(choice).queue(vm).state=2;%Ԥ��״̬������ִ�е����clock���У�����ִ��,����һʱ�̴��䴦�����֮�󣬱�Ϊ1����ʱrear==front==1���������ݺ�rear��Ȼָ���β��front��Ȼָ���ͷ
                                    else
                                        AP(ap).CS(choice).queue(vm).rear=AP(ap).CS(choice).queue(vm).rear+1;%������������data�����ʱ��rearָ�����һ��data
                                    end
                                    if ap==7&&cs==1&&vm==5
                                    end
                                    rear=AP(ap).CS(choice).queue(vm).rear;
                                    AP(ap).CS(choice).queue(vm).data(rear).from_task=Nowtask;
                                    AP(ap).CS(choice).queue(vm).data(rear).to_task=suc_id;
                                    AP(ap).CS(choice).queue(vm).data(rear).amount=Transferdataq(Nowtask,suc_id);
                                    %                                         AP(ap).CS(choice).queue(vm).data(rear).from_vm_id=vm1;
                                    AP(ap).CS(choice).queue(vm).data(rear).gt=clock;
                                    %                                     AP(ap).CS(choice).queue(vm).data(rear).tft=0;
                                    AP(ap).CS(choice).queue(vm).data(rear).tat=clock;
                                    AP(ap).CS(choice).queue(vm).data(rear).last_trans_clock=0;%
                                    AP(ap).CS(choice).queue(vm).data(rear).user_id=user_id;
                                end
                            end
                        end
                    end
                end
            end
            
        end
    end
    %%%%%%%%%%%%%%%%%���ո�����CS��״̬���д���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for ap=1:length(P)
        for cs=1:length(temp_AP(ap).CS)
            channel_num=length(temp_AP(ap).CS(cs).channel_num);
            pointer=temp_AP(ap).CS(cs).pointer;%pointerָ�����
            i=1;
            empty_queue=0;
            while i<=channel_num&&empty_queue<VMnum% pointer��1��10���������ѵ�ʮ���յ�ʱ��˵��û�д�����
                pointer=mod(pointer,VMnum);
                if pointer==0
                    pointer=VMnum;
                end
                if AP(ap).CS(cs).queue(pointer).state==1%queue�������ݣ�clock0��clock1���ʱ���У�û�����ݽ���
                    from_ap=AP(ap).CS(cs).from;
                    to_ap=AP(ap).CS(cs).to;
                    front=AP(ap).CS(cs).queue(pointer).front;%��ͷ
                    
                    AP(ap).CS(cs).queue(pointer).data(front).amount=AP(ap).CS(cs).queue(pointer).data(front).amount-B*B_eff(from_ap,to_ap)*clock_step;
                    user_id=AP(ap).CS(cs).queue(pointer).data(front).user_id;
                    if user_id==7&&ap==7&&cs==1
                    end
                    user_state(4,user_id)=user_state(4,user_id)+1;
                    if ap==7&&cs==1&&pointer==5
                    end
                    if  AP(ap).CS(cs).queue(pointer).data(front).last_trans_clock~=clock%��queue��С��Channel����ʱ����һ��clock�У��п���ͬһ��queue������Channel��ͬ����
                        AP(ap).CS(cs).queue(pointer).data(front).last_trans_clock=clock;%��������ȵ�ʱ��˵����ʱ����������queue�Ĺ��̵��У���ʱ�ŵ���û��ȫ�ķ���������ͬһ��clock֮�ڣ����ø���
                    end
                    if  AP(ap).CS(cs).queue(pointer).data(front).amount<=0%���data�����ݴ������
                        AP(ap).CS(cs).queue(pointer).data(front).amount=0;
                        from_task=AP(ap).CS(cs).queue(pointer).data(front).from_task;
                        to_task=AP(ap).CS(cs).queue(pointer).data(front).to_task;

                        user_id=AP(ap).CS(cs).queue(pointer).data(front).user_id;
                        if from_task==30 && to_task==11
                        end
                        if from_task==29 && to_task==11 && user_id==2
                        end
                        tat=AP(ap).CS(cs).queue(pointer).data(front).tat;
                        User_trantime{user_id}(from_task,to_task)=clock-tat;
                        AP(ap).CS(cs).queue(pointer).data(front).tat=0;
                        VM2Task(find(VM2Task_id==user_id)).reTransferdata(from_task,to_task)=0;
                        AP(ap).CS(cs).queue(pointer).data(front).tft=clock;%���data�����ʱ��
                        AP(ap).CS(cs).queue(pointer).front=front+1;
                        if AP(ap).CS(cs).queue(pointer).front>AP(ap).CS(cs).queue(pointer).rear%��ͷ�ȶ�β��
                            queue=AP(ap).CS(cs).queue(pointer);
                            queue.state=0;
                            queue.from_vm=vm;
                            queue.front=1;
                            queue.rear=1;
                            queue.data=struct('amount',0,'from_task',0,'to_task',0,'from_vm_id',0,'gt',0,'tft',0,'tat',0,'last_trans_clock',0);
                            AP(ap).CS(cs).queue(pointer)=queue;
                        end
                    end
                    empty_queue=0;
                else%����Ϊ��
                    i=i-1;
                    empty_queue=empty_queue+1;
                end
                i=i+1;
                pointer=pointer+1;
            end
            AP(ap).CS(cs).pointer=pointer;
        end %AP(r)��CS��������
    end
    for ap=1:length(P)
        for cs=1:length(temp_AP(ap).CS)
            for vm=1:VMnum
                if AP(ap).CS(cs).queue(vm).state==2
                    AP(ap).CS(cs).queue(vm).state=1;
                end
            end
        end
    end
    
    for i=1:length(AP)
        for j=1:length(AP(i).CS)
            for k=1:length(AP(i).CS(j).queue)
                if AP(i).CS(j).queue(k).state==1
                    for l= AP(i).CS(j).queue(k).front:AP(i).CS(j).queue(k).rear
                        temp=AP(i).CS(j).queue(k).data(l).from_task*100+AP(i).CS(j).queue(k).data(l).to_task;
                        task_channel(clock,find(temp==task_in_channel))=task_channel(clock,find(temp==task_in_channel))+1;
                    end
                end
            end
        end
    end
    clock=clock+clock_step;
    clock
    order_in=50000:50000:1000000;
    if isempty(find(clock==order_in))~=1
        name1=['AP=',num2str(Nap),' AR=',num2str(AR),' ren=',num2str(ren),' clock=',num2str(clock),'.mat'];
        save([name1])
    end
    for ap=1:length(P)
        for vm=1:VMnum
            if AP(ap).VM(vm).state==2
                AP(ap).VM(vm).state=1;
            end
        end
    end
    if clock==10000
    end
    
end
end

