%%%%%%%%%%%%%%%%%%%%��һ�׶Σ�PCP��ѡȡ�ͻ�վ�ķ���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [ user_state ] = Main_APequal1( Nap,AR,Arrtime)
Pap=100000;%����AP��ִ������
VMnum=10;
P=ones(1,Nap)*Pap/VMnum;

Transferdata=[0,0,0,0,0,8334624,8362898,0,8287354,0,0,0,0,0,0,0,8326168,0,0,0,0,0,0,0,0;0,0,0,0,0,8343702,8371246,8311060,0,8301204,0,8340796,8311328,0,0,0,0,8323662,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,8314244,8299612,8304794,0,0,0,0,0,0,0,8364646,0,0,0,0,0,0;0,0,0,0,0,0,0,8348008,0,0,0,8346144,0,8326392,0,0,0,0,0,8341716,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,8307042,8282778,0,0,0,0,0,0,8315294,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,408676,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,314473,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,228889,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,176628,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,233738,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,251473,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,271522,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,313399,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,297528,0,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1889,0,0,0,0,0,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,265,265,265,265,265,0,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8326168,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8323662,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8364646,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8341716,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8315294,0,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1599,0,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,93019228,0;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1861129;0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
data_name=['AP=1',' AR=',num2str(AR),'.mat'];%Icloudlet��Ϊ��system1��W3C��Ϊ��system2
%��������Ĺ�ϵD
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
for j=2:size(E)-1
    if Hel(j)==0;
        E(1,j)=1;
    end
end   %��entry��������ϵ
for i=2:size(E)-1
    if Heh(i)==0;
        E(i,size(E))=1;
    end
end   %��exit��������ϵ

K=cell(2,size(E,2));
for i=1:size(E,2)
    K{1,i}=(find(E(:,i)))';%ǰ�ڵ�,
    K{2,i}=find(E(i,:));%��ڵ㣬ǰ�����ڵ㶼����Ǻ����
end   %����ֱ��ǰ����������


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
end   %����ÿ������MeanExetime����������V��
Vq=[0 V 0];
[rank]=pri(K,Vq,Trantimeq);
ranksign=rank;
ranksign(1)=0; %�Ѿ�������Ϊȫ�ֵı�������ǰ��ĳ����У����Ƿ�sign
PCPcell={};
[PCPcell,ranksign] = SearchPCP(1,PCPcell,ranksign,K);
Assignrank=cell2mat(PCPcell);

clock=0;
clock_step=1;
Tmax=100000;
user_state=[];%��һ�б�ϵͳ����ʱ�䣬�ڶ����û�����ʱ��
Arrtimesign=Arrtime;
%�ṹ�������
for ap=1:length(P)
    for vm=1:VMnum
        AP(ap).VM(vm).Taskrei=Iq(Assignrank);
        AP(ap).VM(vm).user_id=0;
        AP(ap).VM(vm).state=0;
    end
end
Can=1;%�������У������п��е�VM
while clock<Tmax
    Can=1;%�������У������п��е�VM
    while isempty(find(Arrtimesign))~=1&&Arrtimesign(min(find(Arrtimesign)))<clock+clock_step&&Can==1%����ʱ��С��clock��VM���п��У��������еı�־Ϊ1
        user=min(find(Arrtimesign));
        sign=1;
        for ap=1:length(P)
            for vm=1:VMnum
                if AP(ap).VM(vm).state==0
                    AP(ap).VM(vm).state=2;%VM��״̬����Ϊ2��Ԥ��״̬
                    AP(ap).VM(vm).user_id=user;%ͬһ��userʹ�ò�ͬAP����ͬ��ŵ�VM
                    user_state(1,user)=clock; %�����û���ʼʱ�䣬��һʱ�̵Ľ�β����һ��ʱ�̵Ŀ�ʼΪ��ʱ��
                    Arrtimesign(user)=0;
                    sign=0;
                    break %���� vm=1:VMnum��һѭ��
                end
            end
            if sign==0
                break
            end%break����for�ķ���
        end
        Can=0; %�ȸ�ֵΪ�㣬�������п��е�VM�ٸ�
        flag=1;
        for ap=1:length(P)
            for vm=1:VMnum
                if AP(1).VM(vm).state==0
                    Can=1;
                    flag=0;
                    break
                end
            end  %ˢ��Can��ֵ
            if flag==0
                break
            end
        end  %���������VM�Ѿ����������
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
