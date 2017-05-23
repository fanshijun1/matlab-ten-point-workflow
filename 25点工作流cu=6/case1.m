function [ gcase1 ,longest1] = case1( r,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask)
%CASE1 此处显示有关此函数的摘要
%   此处显示详细说明
%调用了searchLongestPath函数

%%%%%%%%%%%

dE =zeros(size(auxD));%通信资源前的等待时间理论值
longest1=zeros(1,size(CULink,2));
n_comput=zeros(1,size(CULink,2));
for i=1:size(CULink,1)  %假设所有任务堵在了某个CU，然后对每个CU算最长路径
        dM=zeros(1,size(auxD,2));%计算资源前的等待时间理论值
        n_comput(i)=r;%n_comput可有可无，可以直接用r，为了对称而已。
        %算dM
        for j=1:length(CUtask{2,i})
                if(I(CUtask{2,i}(1,j))~=0)%如果不是虚拟节点，则求出此节点的等待时间。                       
                        dM(CUtask{2,i}(1,j))=n_comput(i)*average_compute_time{2,i}(1,1);%是否应该与length(CUtask)相乘，值得思考和实验测试下，看是否导致更精确的预测结果
                end
        end
        %拥堵在第i个CU时的最长路径
        [ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc );
        longest1(i)=L(1);
end
gcase1=max(longest1);
end

