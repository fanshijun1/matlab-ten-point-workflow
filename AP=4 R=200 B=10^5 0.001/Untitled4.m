name=['AP=',num2str(3),' AR=',num2str(0.04),' ren=',num2str(500),'.mat'];
load(name)
x=zeros(1,500);
for i=1:500
    if isempty(VM2Task(i).resttask)~=1
        x(i)=VM2Task(i).resttask(1);
    end
end
y=zeros(1,27);
for i=1:27
    if length(find(x==i))~=0
        y(i)=length(find(x==i));
    end
end
z=1:1:27;
plot(z,y,'*');