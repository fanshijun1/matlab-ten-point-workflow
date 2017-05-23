name=['AP=',num2str(3),' AR=0.01','.mat'];
load(name)
Trantimeq_new=Trantimeq;
for i=1:Nap
    temp=Assignrank(find(Map(:,i)))';
    for j=1:length(temp)
        for k=1:length(temp)
            Trantimeq_new(temp(j),temp(k))=0;
        end
    end
end
user_temp=zeros(length(I)+2,length(I)+2);
for i=1:length(find(user_state(2,:)))
    user_temp=User_trantime{i}+user_temp;
end
user_real=user_temp/length(find(user_state(2,:)))-Trantimeq_new;

Map(1,find(Map(2,:)))=1;%任务1默认分配给了AP1
Map(length(I)+2,find(Map(length(I)+1,:)))=1;%末尾任务分配给了Assignrank中上一个任务分配给了AP
Task_AP=cell(1,Nap);
for i=1:Nap
    Task_AP{1,i}=Assignrank(find(Map(:,i)));%各个AP分配到的task
end
for i=1:length(Task_AP)
    j=length(Task_AP{i});
    while j~=1
          if Transferdataq(Task_AP{i}(j-1),Task_AP{i}(j))==0
              E(Task_AP{i}(j-1),Task_AP{i}(j))=1;
          end
          j=j-1;
    end
end
K=cell(2,size(E,2));
for i=1:size(E,2)
    K{1,i}=(find(E(:,i)))';%前节点,
    K{2,i}=find(E(i,:));%后节点，前后驱节点都变成是横向的
end   %计算直接前驱后驱任务
[rank_new]=pri(K,Vq,user_temp/length(find(user_state(2,:))));
maxpath=[1];
i=1;
while i~=length(I)+2
    hou=K{2,i};
    hourank=rank_new(hou);
    temp=[];
    for j=1:length(hourank)
        temp(end+1)=hourank(j)+Trantimeq_new(i,hou(j));
    end
    [~,y]=max(temp);
    maxpath(end+1)=hou(y);
    i=hou(y);
end