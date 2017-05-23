function [ gcase2,longest2] = case2(r,E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink )
%CASE2 此处显示有关此函数的摘要
%调用了：layerAssign函数
%              searchLongestPath函数
%   此处显示详细说明
%%%%%%%%%%%%%case2计算等待被忽略%%%%%%%%%%%%%%%%
dM=zeros(1,size(auxD,2));%计算资源前的等待时间理论值
longest2=zeros(1,length(T));
b=zeros(size(CULink));%论文中的贝塔，表示任务数和层数的比值
ly=layerAssign( D,auxD,auxpreSucc );%得到层数分泵图
for v=1:length(T)
        dE =zeros(size(auxD));%通信资源前的等待时间理论值
        %对于前v个最堵的链路中的每一个传输任务，求出dE( , )
        for i=1:v%T{1,i}=[2,3]
                trans_task=E(T{1,i}(1,1)).E(T{1,i}(1,2)).task;
                n_trans=zeros(size(auxD));       
                for j=1:length(trans_task)%trans_task{1,j}(1,1),,,trans_task{1,j}(1,2)
                        layer=[];
                        for k=1:length(trans_task)%trans_task{1,j}(1,1),,,trans_task{1,j}(1,2)
                                layer(1,end+1)=ly(2,trans_task{1,k}(1,1));%第二行表示所在的层数
                        end
                        layer=unique(layer);%去掉重复的层数
                        layer_num=length(layer);
                        b(T{1,i}(1,1),T{1,i}(1,2))=length(trans_task)/layer_num;%每个链路的任务数除以层数,应为每个任务的b同这个链路的b是一样的，不同的链路b值是不一样的
                        n_trans(trans_task{1,j}(1,1),trans_task{1,j}(1,2))=r*b(T{1,i}(1,1),T{1,i}(1,2));
                        %此传输任务的dE值
                        dE(trans_task{1,j}(1,1),trans_task{1,j}(1,2))=n_trans(trans_task{1,j}(1,1),trans_task{1,j}(1,2))*average_communicate_time(T{1,i}(1,1),T{1,i}(1,2));
                end    

        end
         %对于前v个最堵的链路，求出最长路径
         [ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc );
         longest2(v)=L(1);
end
gcase2=max(longest2);

end

