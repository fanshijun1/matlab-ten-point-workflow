makespan=[];
clock_array=50000:50000:450000;

for i=1:length(clock_array)
    name=['AP=',num2str(3),' AR=',num2str(0.05),' ren=',num2str(200),' clock=',num2str(clock_array(i)),'.mat'];
    % name=['AP=',num2str(15),' AR=0.01',' ren=10''.mat'];
    load(name);
    %ע������load������ֻ��userstate���ǰ����е����ݶ�����д������
    % Arrtime=AT{round(0.01*1000)};%roundȡ��
    %         temp=find(Arrtime<=40000);
    temp=find(user_state(2,:));
    allmakespan=user_state(2,temp)-user_state(1,temp);
    makespan(end+1)=mean(allmakespan);
end
