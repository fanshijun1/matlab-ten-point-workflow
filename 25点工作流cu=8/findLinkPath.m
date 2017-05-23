function [ linkPath] = findLinkPath( CULink,startcu,endcu )
%FINDLINKPATH 此处显示有关此函数的摘要
%函数功能：输入CU分布的CULink矩阵，以及起点和终点，找到最短的路径，并以一行矩阵的形式输出
%一般不会遇到长度相等的多条链路，使用广度优先算法。参考算法（第四版）374页
%   此处显示详细说明
linkPath=[];%最后的返回一维矩阵
marked=zeros(1,size(CULink,2));%标记那些邻接点没有被检查的
edgeTo=zeros(1,size(CULink,2));
adj=cell(0,0);
for i=1:size(CULink,1)
        CULink(i,i)=0;
end
for i=1:size(CULink,1)
        adj{1,i}=find(CULink(i,:));
end
queue=[];%标记过的后继没有被检查过的节点
point=1;

marked(startcu)=1;
queue(1)=startcu;
while(any(queue)==1)
        v=queue(point);
        queue(point)=0;
        point=point+1;
        for i=1:length(adj{1,v})
                if(marked(adj{1,v}(1,i))==0)
                        edgeTo(adj{1,v}(1,i))=v;
                        marked(adj{1,v}(1,i))=1;
                        queue(end+1)=adj{1,v}(1,i);
                end
        end
end
inversePath=[];
x=endcu;
while(x~=startcu)
        inversePath(end+1)=x;
        x=edgeTo(x);
end
inversePath(end+1)=startcu;
for i=1:length(inversePath)
        linkPath(end+1)=inversePath(end+1-i);
end


end

