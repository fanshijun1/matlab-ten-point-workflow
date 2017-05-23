name=['AP=',num2str(15),' AR=0.01','.mat'];
load(name)
real_num=length(find(user_state(2,:)));
for i=1:real_num
    WT_123=mean(user_state(1,1:real_num)-Arrtime(1,1:real_num));
end