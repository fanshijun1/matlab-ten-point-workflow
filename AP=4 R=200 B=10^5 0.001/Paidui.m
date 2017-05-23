Nap=3;
AR=0.04;
load('AT50');
Arrtime=AT{AR*1000};
ren=500;
Pap=100000;%单个AP的执行能力
VMnum=1;
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
Task_map_ap=cell(1,Nap);
for i=1:Nap
    Task_map_ap{i}=Assignrank(find(Map(:,i)));
end



iarray=1:10;
recorde=zeros(length(iarray),Nap);

for i=1:length(iarray)
    queue_num=zeros(1,length(I)+1);
    queue_num(1)=iarray(i);
    while length(find(queue_num))~=length(I)+2
        temp1=[];
        temp=find(queue_num);
        for j=1:length(temp)
            temp1(end+1:end+length(K{2,temp(j)}))=K{2,temp(j)};
        end
        temp1=unique(temp1);
        temp2=[];
        for j=1:length(temp1)
            temp3=K{1,temp1(j)};
            if all(queue_num(temp3))==1
                queue_num(temp1(j))=max(queue_num(temp3));
            end
        end
    end
    for j=1:Nap
        recorde(iarray(i),j)=sum(queue_num(Task_map_ap{j}));
    end
end
all=sum(recorde,2);
plot(iarray,recorde(:,1),'d-r')
hold on
plot(iarray,recorde(:,2),'^-b')
hold on
plot(iarray,recorde(:,3),'v-g')
hold on
plot(iarray,all,'o-y')
hold on
legend('AP1','AP2','AP3','all')
