function [order ,distance ] = findOrder(location,codelocation,link,center )
%FINDORDER �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
distance=zeros(5,5);
for i=1:size(location,1)
        for j=1:size(location,2)
               
               distance(i,j)=length(findLinkPath(link,codelocation(center(1),center(2)),codelocation(i,j)));
        end
end



order=containers.Map();
end

