
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 调用的函数有
% case1 case2:返回两种情形下的延迟
% case1r case2r：解出两种清形下的系统用户数r
% searchLongestPath:：寻找出最长路径值
% layerAssign：寻找出每个节点的后驱所在的层数
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arrateArray=0.001:0.001:0.05;
longest1=cell(0,0);
longest2=cell(0,0);
dcase1=zeros(1,length(arrateArray));%第一种情形下的延迟
dcase2=zeros(1,length(arrateArray));%第二种情形下的延迟
d=zeros(1,length(arrateArray));%加权后的总延迟

for m=1:length(arrateArray);


%%%%%%%%%%%数据准备部分USENUM,dM,dE,average_compute_time,average_communication_time,predlevel,T,E%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arrate=arrateArray(m);%表示每秒到达0.02个人，故拉姆达实际为arrate
% arrnum=1/arrate;arrnum是错的，表示每个任务到达的间隔时间


USERNUM=500;
auxET=I/(Scu/K);%加上虚拟节点的计算时间
for i=1:size(auxD,1)
        for j=1:size(auxD,2)
                if(auxD(i,j)==1)
                        auxD(i,j)=0;
                end
        end
end
auxTT=auxD/B;%加上虚拟节点的传输时间




%前驱度的计算，即是论文中的a阿尔法。
sum=0;
for i=1:size(auxD,2)
    sum=sum+length(auxpreSucc{1,i});
end
predlevel=sum/size(auxD,2);

average_compute_time=cell(0,0);%每个CU平均处理时间，就是论文中的d/K 
average_communicate_time=zeros(size(CULink));%就是论文中的d传输均值
communicate_num=zeros(size(CULink));

%CU平均处理时间的第一行
for i=1:size(CULink,1)
        average_compute_time{1,i}=i;
        average_compute_time{2,i}=0;
end

%CU平均处理时间的第二行
for i=1:size(CULink,1)
        num=0;%实节点计数器
        for j=1:length(CUtask{2,i})
                %如果是实节点
                if(I(CUtask{2,i}(1,j))>0)
                        average_compute_time{2,i}=average_compute_time{2,i}+I(CUtask{2,i}(1,j));
                        num=num+1;                     
                end
        end
       average_compute_time{2,i}=average_compute_time{2,i}/(num*Scu);%就是论文中的d/K 
end

%计算传输总量和数量
for i=2:length(I)-1%对每一个节点算到每一个后驱节点的传输量，终结点不需要传输
        succ=auxpreSucc{2,i};
        for j=1:length(succ)%i节点->auxpreSucc{2,i}(1,j)即是succ(j)
                if(taskCU{1,i}(1,2)~=taskCU{1,succ(j)}(1,2))
               average_communicate_time(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))=average_communicate_time(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))+auxD(i,succ(j));
               communicate_num(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))= communicate_num(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))+1;
                end
        end
        succ=[];
end

%进行相除
for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                if(communicate_num(i,j)>0&&i~=j)
                average_communicate_time(i,j)=average_communicate_time(i,j)/(communicate_num(i,j)*B);%就是论文中的d传输均值
                end
        end
end

%集合T的计算
%以四个CU为例T={[1,2],[2,1],[2,3],[3,2],[3,4],[4,3]
 %                            
% T=cell(0,0);
% for i=1:size(CULink,1)
%      if(i~=1)
%             T{1,end+1}=[i,i-1];
%     end
% 
%     if(i~=4)
%             T{1,end+1}=[i,i+1];
%     end
% 
% end
 
%集合E的计算 

for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                E(i).E(j).task=cell(0,0);
                E(i).E(j).sum=0;%放置传输量
        end
end
for i=2:size(auxD,2)-1%首尾节点不考虑
      succ=auxpreSucc{2,i};
      for j=1:length(succ)
            E(taskCU{1,i}(1,2)).E(taskCU{1,succ(j)}(1,2)).task{1,end+1}=[i,succ(j)];
      end
end
%计算E(i).E(j).sum
V=zeros(size(CULink));
for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                if(i~=j)
                        for k=1:length(E(i).E(j).task)
                                E(i).E(j).sum=E(i).E(j).sum+auxD(E(i).E(j).task{1,k}(1,1),E(i).E(j).task{1,k}(1,2));
                        end
                        V(i,j)=E(i).E(j).sum;
                end
        end
end

%T中所存的是以通信任务量排序的信道;[x(1),y(1)]防止V中有相等的元素时，只加第一个点
T=cell(0,0);
while(any(any(V))==1)
                [x,y]=find(V==max(max(V)));%找到V中最大值的二维位置
                T{1,end+1}=[x(1),y(1)];
                V(x(1),y(1))=0;                
end


%%%%%%%%%%%%%总的最长路径%%%%%%%%%%%%%%%%%
cs1r(m)=case1r( arrate,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink ,CUtask );
[dcase1(m),longest1{m}]= case1( cs1r(m),average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask);
cs2r(m)=case2r( arrate,E, T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink);
[dcase2(m),longest2{m}]=case2(cs2r(m),E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink );


act=mean(auxET(find(auxET)))/10;%平均计算时间 average communicate time
% att=mean(auxTT(find(auxTT)))%平均传输时间 average transport time
trans_sum=0;
trans_num=0;
for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                if(i~=j)
                        trans_sum=trans_sum+E(i).E(j).sum;
                        trans_num=trans_num+length(E(i).E(j).task);
                end
        end
end
att=trans_sum/(trans_num*B);
% att=0.5526;
n1=act/(act+att);
n2=att/(act+att);
d(m)=n1*dcase1(m)+n2*dcase2(m);
end
plot(arrateArray,d,'r');
hold on;