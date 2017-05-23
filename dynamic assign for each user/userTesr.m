id=1:1:1000;
makespan=zeros(1,1000);
for i=1:1000
        makespan(i)=user(i).makespan;
end
plot(id,makespan,'g');
hold on;