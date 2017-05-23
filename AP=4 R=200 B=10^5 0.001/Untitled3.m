%%%%%%%%%%%%%%%%%%%%第一阶段，PCP的选取和基站的分配%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ren=10;
Nap=3;
AR=0.01;
load('AT50');
Arrtime=AT{AR*1000};
% Arrtime=[1:1:50];
% Arrtime=[1];
Pap=100000;%单个AP的执行能力
VMnum=10;
% Nap=25;
P=ones(1,Nap)*Pap/VMnum;
Channum=100;
B=10^6;
Transferdata=[0,0,0,0,0,8334624,8362898,0,8287354,0,0,0,0,0,0,0,8326168,0,0,0,0,0,0,0,0;0,0,0,0,0,8343702,8371246,8311060,0,8301204,0,8340796,8311328,0,0,0,0,8323662,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,8314244,8299612,8304794,0,0,0,0,0,0,0,8364646,0,0,0,0,0,0;0,0,0,0,0,0,0,8348008,0,0,0,8346144,0,8326392,0,0,0,0,0,8341716,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,8307042,8282778,0,0,0,0,0,0,8315294,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,408676,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,314473,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,228889,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,176628,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,233738,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,251473,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,271522,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,313399,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,297528,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1889,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,265,265,265,265,265,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8326168,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8323662,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8364646,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8341716,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8315294,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1599,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,93019228,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1861129;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
data_name=['AP=',num2str(Nap),' AR=',num2str(AR),' ren=',num2str(ren),'.mat'];
%计算任务的关系D

D=zeros(size(Transferdata,1),size(Transferdata,2));
for i=1:size(Transferdata,1)
    for j=1:size(Transferdata,2)
        if Transferdata(i,j)>0
            D(i,j)=1;
        end
    end
end

E=zeros(size(D,1)+2,size(D,2)+2);
E(2:end-1,2:end-1)=D;%加entry exit
Hel=sum(E);%列求和
Heh=sum(E,2);%行求和
Transferdataq=zeros(size(Transferdata,1)+2,size(Transferdata,2)+2);
for j=2:size(E)-1
    if Hel(j)==0;
        E(1,j)=1;
        Transferdataq(1,j)=1;
    end
end   %加entry后的任务关系
for i=2:size(E)-1
    if Heh(i)==0;
        E(i,size(E))=1;
    end
end   %加exit后的任务关系

K=cell(2,size(E,2));
for i=1:size(E,2)
    K{1,i}=(find(E(:,i)))';%前节点,
    K{2,i}=find(E(i,:));%后节点，前后驱节点都变成是横向的
end   %计算直接前驱后驱任务



Transferdataq(2:end-1,2:end-1)=Transferdata;
Trantime=Transferdata/B;
Trantimeq=Transferdataq/B;
% xlswrite('distance1.xls',Transferdataq);
I=[1339000,1383000,1336000,1360000,1378000,1059000,1059000,1088000,1081000,1049000,1051000,1051000,1062000,1037000.00000000,72000,142000,1039000,1064000,1083000,1093000,1076000,139000,303000,386000,45000];
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
end   %计算每个任务MeanExetime，加入向量V中
Vq=[0 V 0];
[rank]=pri(K,Vq,Trantimeq);
ranksign=rank;
ranksign(1)=0; %已经被定义为全局的变量，在前面的程序中，看是否被sign
PCPcell={};
[PCPcell,ranksign] = SearchPCP(1,PCPcell,ranksign,K);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%三种算法，只激活一个%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PCP     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[  Map,TSF,Assignrank ] = AssignPCP( PCPcell,K,Exetimeq,rank,P,Trantimeq,Nap );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   HEFT    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ Map,TSF,Assignrank] = HEFT( rank,P,K,Exetimeq,Trantimeq);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%   PSO     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ gMap ] = PSO( rank,Trantimeq,K,Exetimeq,P );
Map(1,1)=0.0001;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%第二阶段，AP在二维平面中位置的选取%%%%%%%%%%%%%%%%%%%%
%某AP的内部与外部的数据传输次数LP,包括自己
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
%去除自己
LPqu=LP;
Channeldataqu=Channeldata;
for i=1:length(P)
    LPqu(i,i)=0;
    Channeldataqu(i,i)=0;
end
%网格的选取，节点上放AP
%     x=0:100:1000;
%     y=0:100:1000;
%     Point=[];
%     for i=1:length(x)
%         for j=1:length(y)
%             Point(end+1,:)=[x(i),y(j)];
%         end
%     end %Point为多行，两列
%     [ locagather,maxarray ] = AssignAP( LP,Point,P ,LPqu);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%第三阶段，信道分配%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ Channel ] = Chanassign( Channum,P,LPqu );
Channel=cell(size(P,2),size(P,2));
for i=1:size(P,2)
    for j=1:size(P,2)
        if i~=j
            Channel{i,j}=[1];
        end
    end
end
% load('AT50');
% Arrtime=AT{round(AR*1000)};
% Arrtime=[1];
%     efficiency=zeros(length(P),length(P));
%     for i=1:length(P)
%         for j=1:length(P)
%             if Channeldataqu(i,j)>0
%                 efficiency(i,j)=Channeldataqu(i,j)/length(Channel{i,j});
%             end
%         end
%     end
%%%%%%%%VM2Task的结构数组%%%%%%%%%
for vm=1:ren %一共十个，每一个对应一个VM，内部装着属于各个AP的相应VM编号的Task
    VM2Task(vm).user_id=0;
    VM2Task(vm).resttask=[];
    VM2Task(vm).id=vm;
    for i=1:length(rank)
        VM2Task(vm).Task(i).rei=Iq(i); %任务剩余量的声明并初始化
        VM2Task(vm).Task(i).Task_id=i;
        temp=find(i==Assignrank);
        VM2Task(vm).Task(i).Map_AP=find(Map(temp,:));%任务的服务器选择的初始化
        VM2Task(vm).Task(i).pre=K{1,i};
        VM2Task(vm).Task(i).suc=K{2,i};
        VM2Task(vm).reTransferdata=Transferdataq;
    end
end

%%%%%%%AP的结构数组%%%%%%%%%
task_id_list=cell(1,length(P));% 这个id是真实的Task的任务顺序
for i=1:length(P)
    AP(i).AP_id=i;
    temp=(find(Map(:,i)))';
    task_id_list{1,i}=Assignrank(temp);
end
AP=struct('task_id_list',task_id_list);

%%%%%%%CS的结构数组%%%%%%%%%
for ap=1:length(P)
    temp=find(LPqu(ap,:));
    for cs=1:length(temp)
        AP(ap).CS(cs).from=ap;
        AP(ap).CS(cs).to=temp(cs);
        AP(ap).CS(cs).channel_num=Channel{ap,temp(cs)};
        AP(ap).CS(cs).pointer=1;%指针，指向，不断地增加，指向不同的queue
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

%%%%%%%VM的结构数组%%%%%%%%%
task_list=cell(1,length(P));% 里边装的是task 也是结构体
for ap=1:length(P)
    temp=(find(Map(:,ap)))';
    temp1=cell(1,length(temp));
    for j=1:length(temp)
        temp1{1,j}=VM2Task(1).Task(Assignrank(temp(j)));
    end
    task_list{1,ap}=temp1;
end
for ap=1:length(P)
    temp=(find(Map(:,ap)))';
    temp1=cell(1,length(temp));
    for vm=1:VMnum
        AP(ap).VM(vm).Pvm=P(ap);
        AP(ap).VM(vm).id=vm;
        AP(ap).VM(vm).state=0;%运行状态
        AP(ap).VM(vm).user_id=0;%VM所赋给的用户名
        AP(ap).VM(vm).Nowin=0; %现在正在执行的任务,初始化指向1
        AP(ap).VM(vm).task_list=temp1;
        AP(ap).VM(vm).cat=0;%接入点r的虚拟机v的计算时间累计
    end
end


clock=0;
clock_step=1;
user_max=50;
Can=1;
Tmax=100000;
% timechoice=unifrnd(1,Tmax,1,user_max);
% load('AT50');
% AR_array=[23 24 26 27]*10^(-3);
% for ar=1:length(AR_array)
%     AR=AR_array(ar);
%     Arrtime=AT{round(AR*1000)};
% end

% Arrtime=[1];
% Arrtimesign=Arrtime;

user_state=[];%第一行被系统接纳时间，第二行用户结束时间
Arrtimesign=Arrtime;
sign=ones(1,length(rank)-1);

% for i=1:63
%     Table(i).time=[];
% end
User_trantime=cell(1,5000);
for i=1:length(User_trantime)
    User_trantime{i}=zeros(length(I)+2,length(I)+2);
end
% greenline_add_time_stop=zeros(5000,length(I)+2);
% greenline_add_time_stopsign=zeros(5000,length(I)+2);
task_start_time=zeros(5000,length(I)+2);%放入任务的前驱都执行完的clock
task_start_timesign=zeros(5000,length(I)+2);
task_wait_time=zeros(5000,length(I)+2);%放入任务前驱都执行完，并且已经分配了vm的开始时间
user_vm_id=zeros(5000,Nap);%记录每个AP使用的VM的标号
ap_used_vm=zeros(1,Nap);%每个AP中已经被使用了的VM的数目
VM2Task_id=zeros(1,ren);%按照顺序放入各个VM2Task中的user标号，不存在的用0表示
used_VM2Task=0;
% vm_sign=zeros(1,Nap);
% ap1_temp=[];
% while length(find(vm_sign))~=Nap
%     if isempty(find(vm_sign))==1
%         ap1_temp(end+1)=1;
%         vm_sign(1)=1;
%         suctask=VM2Task(1).Task(AP(1).task_id_list(1)).suc;
%         for i=1:length(suctask)
%             vm_sign(VM2Task(1).Task(suctask(i)).Map_AP)=1;
%         end
%     else
%         add=min(find(vm_sign==0));
%         ap1_temp(end+1)=add;
%         vm_sign(add)=1;
%         suctask=VM2Task(1).Task(AP(add).task_id_list(1)).suc;
%         for i=1:length(suctask)
%             vm_sign(VM2Task(1).Task(suctask(i)).Map_AP)=1;
%         end
%     end
% end
% ap1_temp=[];
% for i=1:length(K{2,1});
%     ap1_temp(end+1)=VM2Task(1).Task(K{2,1}(i)).Map_AP;
% end
% ap1_temp=unique(ap1_temp);
while clock<Tmax
    %%%%%%%%%%%%%%%%%按照user数分配各个user的VM%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     if isempty(find(clock<Arrtime<clock+clock_step))==0
    
     VM2Task_id_sign=VM2Task_id;
    while isempty(find(VM2Task_id_sign))~=1
        VM2Task_id_sign_temp=VM2Task_id_sign;
        temp=find(VM2Task_id_sign==0);
        for i=1:length(temp)
            VM2Task_id_sign_temp(temp(i))=max(VM2Task_id_sign)+1;
        end
        [user_id,y]=min(VM2Task_id_sign_temp);
        if user_id==6||user_id==7
        end
        VM2Task_id_sign(y)=0;
        resttask=VM2Task(y).resttask;
        if (user_id==6||user_id==7)&&isempty(resttask)~=1
        end
        for i=1:length(resttask)
            Map_AP=VM2Task(y).Task(resttask(i)).Map_AP;
            pretask=VM2Task(y).Task(resttask(i)).pre;
            pretaskrei=[];%现在所有前驱任务的剩余任务量
            for j=1:length(pretask)
                pretaskrei(end+1)=VM2Task(y).Task(pretask(j)).rei;
            end
            pretasktrans=[];%这个任务的前驱是否完成传输
            for j=1:length(pretask)
                pretasktrans(end+1)=VM2Task(y).reTransferdata(pretask(j),resttask(i));
            end
            if (user_id==6||user_id==7)&&isempty(resttask)~=1&&isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1
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
                needadd_AP=[];%放入需要进行比较的通向的AP
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
                            for k=1:length(AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).data)
                                resti_temp(vm1)=AP(Map_AP).CS(needadd_AP_cs(j)).queue(vm1).data(k).amount+resti_temp(vm1);
                            end
                        end
                    else resti_temp(vm1)=inf;
                    end
                end
                [~,vm1]=min(resti_temp);
                if task_wait_time(user_id,resttask(i))==0%&&VM2Task(vm).Task(pre_task_temp).rei==0)%无前驱或者前驱任务量都剩零了并且已经传输完成
                    task_wait_time(user_id,resttask(i))=clock;
                end
                AP(Map_AP).VM(vm1).state=2;%VM的状态设置为1
                AP(Map_AP).VM(vm1).user_id=user_id;%同一个user使用不同AP的相同编号的VM
                AP(Map_AP).VM(vm1).Nowtask=resttask(i);
                AP(Map_AP).VM(vm1).cat=0;
                user_vm_id(user_id,Map_AP)=vm1;
                ap_used_vm(Map_AP)=ap_used_vm(Map_AP)+1;
                i1=find(VM2Task(y).resttask==resttask(i));
                VM2Task(y).resttask(i1)=[];
            end
        end
    end
    
    Can=1;%可以运行，就是有空闲的VM
    while isempty(find(Arrtimesign))~=1&&Arrtimesign(min(find(Arrtimesign)))<clock+clock_step&&Can==1&&used_VM2Task<ren;%到达时间小于clock且VM中有空闲，可以运行的标志为1
        user=min(find(Arrtimesign));
        if user==40
        end
        for vm=1:VMnum
            if AP(1).VM(vm).state==0  %只检查一个AP就说明了所有的VM的状态，因为用户在所有的AP中获得的VM的标号都是一样的
                AP(1).VM(vm).state=1;%VM的状态设置为1
                AP(1).VM(vm).user_id=user;%同一个user使用不同AP的相同编号的VM
                if user==37
                end
                AP(1).VM(vm).Nowtask=1;
                AP(1).VM(vm).cat=0;
                user_state(1,user)=clock; %记下用户开始时间，这一时刻的结尾，下一个时刻的开始为计时点
                user_state(2:5,user)=0;
                Arrtimesign(user)=0;
                user_vm_id(user,1)=vm;
                ap_used_vm(1)=1+ap_used_vm(1);
                for i=1:ren
                    if VM2Task(i).user_id==0
                        VM2Task(i).user_id=user;
                        VM2Task_id(i)=user;
                        used_VM2Task=1+used_VM2Task;
                        break
                    end
                end
                break
            end
        end
        
        Can=0; %先赋值为零，后边如果有空闲的VM再改
        for vm=1:VMnum
            if AP(1).VM(vm).state==0
                Can=1;
                break
            end
        end  %刷新Can的值
    end  %各个任务的VM已经给分配好了
    %     end
    %clock0时刻到clock1时刻,从上面的过程当中，AP，
    %%%%%%%%%%%%%%%%%按照VM进行AP与VM2Task的rei，reTransferdata的更新，CS的state的确认%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     VM2Task_id=zeros(1,Nap*VMnum);
    %     for i=1:Nap*VMnum
    %         if VM2Task(i).user_id~=0
    %             VM2Task_id(i)=VM2Task(i).user_id;%顺序放入所有VM2Task中的user标号，没有的话用0表示
    %         end
    %     end
   
    temp_AP=AP;%原来状态是temp_AP，通过对temp_AP的判断改变AP
    for ap=1:length(P)
        for vm=1:VMnum
            if temp_AP(ap).VM(vm).state==1 %如果这个VM没有运行且，现在的指针小于任务列表任务数，则可执行。
                user_id=temp_AP(ap).VM(vm).user_id;
                %                 if user_id==5&&ap==15
                %                 end
                Nowtask=temp_AP(ap).VM(vm).Nowtask;%现在指向的任务号是Nowtask
                vm_1=find(VM2Task_id==user_id);
                resttask=VM2Task(vm_1).resttask;
                %                 pretask=VM2Task(vm).Task(Nowtask).pre;
                %                 vm_1=VM2Task_id(user_id,1);%每一个用户以AP1所用的VM为准则
                %                 pretaskrei=[];%现在所有前驱任务的剩余任务量
                %                 for i=1:length(pretask)
                %                     pretaskrei(end+1)=VM2Task(vm_1).Task(pretask(i)).rei;
                %                 end
                %                 pretasktrans=[];%这个任务的前驱是否完成传输
                %                 for i=1:length(pretask)
                %                     pretasktrans(end+1)=VM2Task(vm_1).reTransferdata(pretask(i),Nowtask);
                %                 end
                %                 for i=1:length(Assignrank)
                %                     if Assignrank(i)==Nowtask;
                %                         in_assignrank=i;
                %                     end
                %                 end
                %                 r_temp=find(Map(in_assignrank,:));
                %                 task_in_ap=Assignrank(find(Map(:,r_temp)));
                %                 zhi=find(task_in_ap==Nowtask);
                %
                %                 if zhi>=2
                %                     pre_task_temp=task_in_ap(zhi-1);
                %                 else
                %                     if Nowtask==task_in_ap(end)
                %                         pre_task_temp=1;
                %                     else pre_task_temp=1;
                %                     end
                %                 end %%%%%%%%%%其实，这种情况不用考虑，因为AP中前一个任务肯定被执行了，在理论分析中有绿线，在仿真中绿线并没有体现，只是在过程中按步骤进行
                %                 if isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1&&VM2Task(vm).Task(pre_task_temp).rei~=0
                %                     greenline_add_time_startsign(temp_AP(ap).VM(vm).user_id,Nowtask)=1;
                %                     greenline_add_time_start(temp_AP(ap).VM(vm).user_id,Nowtask)=clock;
                %                 end
                %                 Map_AP=VM2Task(1).Task(Nowtask).Map_AP;
                %                 if Nowtask==23
                %                 end
                %                 if (isempty(find(pretaskrei))==1&&isempty(find(pretasktrans))==1)
                %                 end
                
                VM2Task(vm_1).Task(Nowtask).rei=VM2Task(vm_1).Task(Nowtask).rei-AP(1).VM(1).Pvm*clock_step;%更新VM2Task中的当先Task的rei
                AP(ap).VM(vm).cat=AP(ap).VM(vm).cat+clock_step;%刷新这个用户在这个AP上的一共的时间，最后会多加一个clock_step,因为最后一个任务，也有个时刻是前驱都完成的，也加入了一个clock_step
                %                   AP(ap).VM(vm).Sumofcat=AP(ap).VM(1vm).Sumofcat+clock_step;
                if VM2Task(vm_1).Task(Nowtask).rei<=0 %判断是否为最后一个时间点，让Task结束了，结束了之后，看后驱任务
                    if user_id==6||user_id==7
%                         user_id
%                         Nowtask
                    end
                    if user_id==7
                    end
                    if user_id==6&&Nowtask==24
                    end
                    VM2Task(vm_1).Task(Nowtask).rei=0;
                    user_state(3,user_id)=user_state(3,user_id)+AP(ap).VM(vm).cat;
                    AP(ap).VM(vm).state=0;
                    AP(ap).VM(vm).user_id=0;
                    AP(ap).VM(vm).Nowtask=0;
                    AP(ap).VM(vm).cat=0;
                    user_vm_id(user_id,ap)=0;
                    ap_used_vm(ap)=ap_used_vm(ap)-1;
                    if user_id==5&&Nowtask==17
                    end
                    if user_id==5
                    end
                    %                       Table(AP(ap).VM(vm).user_id).time(2,Nowtask)=clock;
                    suctask=VM2Task(vm_1).Task(Nowtask).suc;
                    if suctask==length(rank)%判断是否后驱就是exit任务了
                        exitpre=VM2Task(vm_1).Task(suctask).pre;
                        exitprerei=[];
                        for i=1:length(exitpre)
                            exitprerei(end+1)=VM2Task(vm_1).Task(exitpre(i)).rei;
                        end
                        if isempty(find(exitprerei))==1%exit任务的前驱都已经完成
                            %后驱为空，工作流结束
                            % AP(ap).VM(vm).cat=AP(ap).VM(vm).cat;%把前边的多加的clock_step去掉
                            %                                 user_id=AP(ap).VM(vm).user_id;%已经完成的user的ID记录下来，作为user_state的列变量
                            VM2Task_id(find(VM2Task_id))
                            if user_id>min(VM2Task_id(find(VM2Task_id)))
                            end
                            user_state(2,user_id)=clock;%完成时刻，这是一个clock的时间轴上的点，指的是这个时刻的结束，进行存储
                            %                                 user_state(3:5,user_id)=0;
                            VM2Task(vm_1).user_id=0;
                            VM2Task_id(vm_1)=0;
                            used_VM2Task=used_VM2Task-1;
                            %                                 VM2Task(find(VM2Task_id==user_id))=0;
                            for i=1:length(rank)
                                VM2Task(vm_1).Task(i).rei=Iq(i); %任务剩余量的声明并初始化
                                VM2Task(vm_1).reTransferdata=Transferdataq;
                            end
                        end
                        save([data_name]);
                        % % % % % % % % % % % % % % % % % % % % % %                          save
                    else %承接上一部分Task结束之后，后驱还存在
                        for i=1:length(suctask)
                            suc_id=suctask(i);%后驱任务的id
                            receiver=VM2Task(1).Task(suc_id).Map_AP;%后驱任务所在的AP,VM2Task(1)中就可以找到
                            if isempty(find(resttask==suc_id))==1&&task_start_time(user_id,suc_id)==0
                                VM2Task(vm_1).resttask(end+1)=suc_id;
                            end
                            if ap==receiver%在这个ap执行,无需CS
                                
                                %                                     for vm1=1:VMnum
                                %                                         if AP(receiver).VM(vm1).state==0
                                %                                             AP(receiver).VM(vm1).state=2;%VM的状态设置为1
                                %                                             AP(receiver).VM(vm1).user_id=user_id;%同一个user使用不同AP的相同编号的VM
                                %                                             AP(receiver).VM(vm1).Nowtask=suc_id;
                                %                                             AP(receiver).VM(vm1).cat=0;
                                %                                             user_vm_id(user_id,receiver)=vm1;
                                %                                             ap_used_vm(receiver)=ap_used_vm(receiver)+1;
                                %                                             break
                                %                                             if vm1==VMnum
                                %                                                 VM2Task(vm_1).resttask(end+1)=suc_id;
                                %                                                 vm1=0;
                                %                                             end
                                %                                         end
                                %                                     end
                                %                                     if vm1~=0
                                VM2Task(vm_1).reTransferdata(Nowtask,suc_id)=0;
                                %                                         VM2Task(vm_1).Task(Nowtask).rei=0;
                                %                                     end
                            else %不在这个ap执行，则通过CS发送到其他的AP
                                for j=1:length(AP(ap).CS)
                                    if AP(ap).CS(j).to==receiver
                                        choice=j;
                                        break
                                    end
                                end
                                if AP(ap).CS(choice).queue(vm).state==0
                                    AP(ap).CS(choice).queue(vm).state=2;%预备状态，程序执行的这个clock当中，并不执行,当这一时刻传输处理完成之后，变为1。此时rear==front==1，加入数据后，rear依然指向队尾，front依然指向队头
                                else
                                    AP(ap).CS(choice).queue(vm).rear=AP(ap).CS(choice).queue(vm).rear+1;%当还有其他的data到达的时候，rear指向最后一个data
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
    %%%%%%%%%%%%%%%%%按照给定的CS的状态进行传输%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for ap=1:length(P)
        for cs=1:length(temp_AP(ap).CS)
            channel_num=length(temp_AP(ap).CS(cs).channel_num);
            pointer=temp_AP(ap).CS(cs).pointer;%pointer指向队列
            i=1;
            empty_queue=0;
            while i<=channel_num&&empty_queue<VMnum% pointer从1到10搜索，当搜到十个空的时候，说明没有传输了
                pointer=mod(pointer,VMnum);
                if pointer==0
                    pointer=VMnum;
                end
                if AP(ap).CS(cs).queue(pointer).state==1%queue内有数据，clock0到clock1这段时间中，没有数据进入
                    front=AP(ap).CS(cs).queue(pointer).front;%队头
                    
                    AP(ap).CS(cs).queue(pointer).data(front).amount=AP(ap).CS(cs).queue(pointer).data(front).amount-B*clock_step;
                    user_id=AP(ap).CS(cs).queue(pointer).data(front).user_id;
                    if user_id==7&&ap==7&&cs==1
                    end
                    user_state(4,user_id)=user_state(4,user_id)+1;
                    if ap==7&&cs==1&&pointer==5
                    end
                    if  AP(ap).CS(cs).queue(pointer).data(front).last_trans_clock~=clock%当queue数小于Channel数的时候，这一个clock中，有可能同一个queue被几个Channel共同传输
                        AP(ap).CS(cs).queue(pointer).data(front).last_trans_clock=clock;%当两者相等的时候，说明此时还是在搜索queue的过程当中，这时信道还没完全的分配满，在同一个clock之内，不用更新
                        %                         AP(ap).CS(cs).queue(pointer).data(front).tat= AP(ap).CS(cs).queue(pointer).data(front).tat+clock_step;%可以刷新的时候，data的通信时间加上
                    end
                    if  AP(ap).CS(cs).queue(pointer).data(front).amount<=0%这个data的数据传输完成
                        AP(ap).CS(cs).queue(pointer).data(front).amount=0;
                        
                        if clock==144
                        end
                        from_task=AP(ap).CS(cs).queue(pointer).data(front).from_task;
                        to_task=AP(ap).CS(cs).queue(pointer).data(front).to_task;
                        %                         if from_task==24&&to_task==25
                        %                         end
                        user_id=AP(ap).CS(cs).queue(pointer).data(front).user_id;
                        %                         if user_id==5
                        %                         end
                        tat=AP(ap).CS(cs).queue(pointer).data(front).tat;
                        User_trantime{user_id}(from_task,to_task)=clock-tat;
                        AP(ap).CS(cs).queue(pointer).data(front).tat=0;
                        VM2Task(find(VM2Task_id==user_id)).reTransferdata(from_task,to_task)=0;
                        
                        
                        
                        AP(ap).CS(cs).queue(pointer).data(front).tft=clock;%这个data的完成时间
                        
                        %一个数据块传完了，两件事情：1 更改子任务的pre的状态； 2 队头front后移
                        %                             AP(r).CS(receiver).QUEUE(pointer).data(front)  % 打印
                        %                          from_vm= AP(ap).CS(cs).queue(pointer).from_vm;
                        %                          VM2Task(from_vm).Task(Nowtask).rei=0;
                        %2 队头front后移，并判断队列中还有没有数据，没有则队列状态转0
                        AP(ap).CS(cs).queue(pointer).front=front+1;
                        if AP(ap).CS(cs).queue(pointer).front>AP(ap).CS(cs).queue(pointer).rear%队头比队尾大
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
                else%队列为空
                    i=i-1;
                    empty_queue=empty_queue+1;
                end
                i=i+1;
                pointer=pointer+1;
            end
            AP(ap).CS(cs).pointer=pointer;
        end %AP(r)的CS遍历结束
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
    %%%%%%%%%% 所有新接纳的用户的计算均从下一个clock_step开始；%%%%%%%%%%%%
    
    
    %         for i=2:length(rank)-1
    %             if VM2Task(1).Task(i).rei~=I(i-1)&&sign(i)==1
    %                 Table(1,i)=clock;
    %                 sign(i)=0;
    %             end
    %         end
    
    clock=clock+clock_step;
    %     end_time=datestr(now);
    clock
    
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


