makespan=[];
clock_array=50000:50000:450000;

for i=1:length(clock_array)
    name=['AP=',num2str(3),' AR=',num2str(0.05),' ren=',num2str(200),' clock=',num2str(clock_array(i)),'.mat'];
    % name=['AP=',num2str(15),' AR=0.01',' ren=10''.mat'];
    load(name);
    %注：这里load出来后不只是userstate，是把所有的数据都重新写出来了
    % Arrtime=AT{round(0.01*1000)};%round取整
    %         temp=find(Arrtime<=40000);
    temp=find(user_state(2,:));
    allmakespan=user_state(2,temp)-user_state(1,temp);
    makespan(end+1)=mean(allmakespan);
end
