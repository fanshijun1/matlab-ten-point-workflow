location={[1,1],[1,2],[1,3],[1,4],[1,5];
                [2,1],[2,2],[2,3],[0,0],[2,5];
                [3,1],[3,2],[0,0],[0,0],[3,5];
                [0,0],[4,2],[4,3],[4,4],[4,5];
                [5,1],[5,2],[5,3],[5,4],[5,5]};
        %将location中的每个区域编码，以便于调用findLinkPath，寻找各个区域的之间越过障碍区域的距离
 codelocation=zeros(5,5);
 %编码方式为[1,2]---1*5+2----7 障碍区域的编码为0
 %逆编码为   7%5=2  （7-2）/5=1
 for i=1:size(location,1)
         for j=1:size(location,2)
                 codelocation(i,j)=size(location,1)*location{i,j}(1,1)+location{i,j}(1,2);
         end
 end
 sizelink=max(max(codelocation));
 link=zeros(sizelink,sizelink);
 %linecode就是将codelocation中的非零元素变成一列
 linecode=[];
 for i=1:size(codelocation,1)
       linecode(end+1:end+size(codelocation,2))=codelocation(i,:);
 end
 linecode=linecode(find(linecode));
 for i=1:length(linecode)
         for j=1:length(linecode)
                 if(abs(linecode(i)-linecode(j))==1||abs(linecode(i)-linecode(j))==5)
                         link(linecode(i),linecode(j))=1;
                 end
         end
 end
center=[3,2];
order=containers.Map();

[order,distance ] = findOrder( location,codelocation,link,center);