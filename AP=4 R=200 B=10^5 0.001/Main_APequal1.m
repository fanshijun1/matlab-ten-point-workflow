%%%%%%%%%%%%%%%%%%%%第一阶段，PCP的选取和基站的分配%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ user_state ] = Main_APequal1( Nap,AR,Arrtime)
Pap=100000;%单个AP的执行能力
VMnum=10;
P=ones(1,Nap)*Pap/VMnum;

Transferdata=[0,0,0,0,0,8334624,8362898,0,8287354,0,0,0,0,0,0,0,8326168,0,0,0,0,0,0,0,0;0,0,0,0,0,8343702,8371246,8311060,0,8301204,0,8340796,8311328,0,0,0,0,8323662,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,8314244,8299612,8304794,0,0,0,0,0,0,0,8364646,0,0,0,0,0,0;0,0,0,0,0,0,0,8348008,0,0,0,8346144,0,8326392,0,0,0,0,0,8341716,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,8307042,8282778,0,0,0,0,0,0,8315294,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,408676,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,314473,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,228889,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,176628,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,233738,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,251473,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,271522,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,313399,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,297528,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1889,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,265,265,265,265,265,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8326168,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8323662,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8364646,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8341716,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8315294,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1599,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,93019228,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1861129;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
data_name=['AP=1',' AR=',num2str(AR),'.mat'];%Icloudlet认为是system1，W3C认为是system2
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
for j=2:size(E)-1
    if Hel(j)==0;
        E(1,j)=1;
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


B=10.^6;
Transferdataq=zeros(size(Transferdata,1)+2,size(Transferdata,2)+2);
Transferdataq(2:end-1,2:end-1)=Transferdata;
Trantime=Transferdata/B;
Trantimeq=Transferdataq/B;

I=[1339000,1383000,1336000,1360000,1378000,1059000,1059000,1088000,1081000,1049000,1051000,1051000,1062000,1037000.00000000,72000,142000,1039000,1064000,1083000,1093000,1076000,139000,303000,386000,45000];
Iq=[0 I 0];
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
Assignrank=cell2mat(PCPcell);

clock=0;
clock_step=1;
Tmax=100000;
user_state=[];%第一行被系统接纳时间，第二行用户结束时间
Arrtimesign=Arrtime;
%结构体的声明
for ap=1:length(P)
    for vm=1:VMnum
        AP(ap).VM(vm).Taskrei=Iq(Assignrank);
        AP(ap).VM(vm).user_id=0;
        AP(ap).VM(vm).state=0;
    end
end
Can=1;%可以运行，就是有空闲的VM
while clock<Tmax
    Can=1;%可以运行，就是有空闲的VM
    while isempty(find(Arrtimesign))~=1&&Arrtimesign(min(find(Arrtimesign)))<clock+clock_step&&Can==1%到达时间小于clock且VM中有空闲，可以运行的标志为1
        user=min(find(Arrtimesign));
        sign=1;
        for ap=1:length(P)
            for vm=1:VMnum
                if AP(ap).VM(vm).state==0
                    AP(ap).VM(vm).state=2;%VM的状态设置为2，预备状态
                    AP(ap).VM(vm).user_id=user;%同一个user使用不同AP的相同编号的VM
                    user_state(1,user)=clock; %记下用户开始时间，这一时刻的结尾，下一个时刻的开始为计时点
                    Arrtimesign(user)=0;
                    sign=0;
                    break %跳出 vm=1:VMnum这一循环
                end
            end
            if sign==0
                break
            end%break两层for的方法
        end
        Can=0; %先赋值为零，后边如果有空闲的VM再改
        flag=1;
        for ap=1:length(P)
            for vm=1:VMnum
                if AP(1).VM(vm).state==0
                    Can=1;
                    flag=0;
                    break
                end
            end  %刷新Can的值
            if flag==0
                break
            end
        end  %各个任务的VM已经给分配好了
    end
    for ap=1:length(P)
        for vm=1:VMnum
            if AP(ap).VM(vm).state==1
                temprei=AP(ap).VM(vm).Taskrei;
                AP(ap).VM(vm).Taskrei(min(find(temprei)))=AP(ap).VM(vm).Taskrei(min(find(temprei)))-clock_step*P(ap);
                if AP(ap).VM(vm).Taskrei(min(find(temprei)))<=0
                    AP(ap).VM(vm).Taskrei(min(find(temprei)))=0;
                end
                if isempty(find(AP(ap).VM(vm).Taskrei))==1
                    user_id=AP(ap).VM(vm).user_id;
                    user_state(2,user_id)=clock;
                    AP(ap).VM(vm).Taskrei=Iq(Assignrank);
                    AP(ap).VM(vm).user_id=0;
                    AP(ap).VM(vm).state=0;
                    save([data_name]);
                end
            end
        end
    end
    for ap=1:length(P)
        for vm=1:VMnum
            if AP(ap).VM(vm).state==2;
                AP(ap).VM(vm).state=1;
            end
        end
    end
    clock=clock+clock_step;
    clock
end
end
% x=find(user_state(2,:));
% y=user_state(2,1:length(x))-user_state(1,1:length(x));
% plot(x,y)
