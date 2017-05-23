function [ linkPath] = findLinkPath( CULink,startcu,endcu )
%FINDLINKPATH �˴���ʾ�йش˺�����ժҪ
%�������ܣ�����CU�ֲ���CULink�����Լ������յ㣬�ҵ���̵�·��������һ�о������ʽ���
%һ�㲻������������ȵĶ�����·��ʹ�ù�������㷨���ο��㷨�����İ棩374ҳ
%   �˴���ʾ��ϸ˵��
linkPath=[];%���ķ���һά����
marked=zeros(1,size(CULink,2));%�����Щ�ڽӵ�û�б�����
edgeTo=zeros(1,size(CULink,2));
adj=cell(0,0);
for i=1:size(CULink,1)
        CULink(i,i)=0;
end
for i=1:size(CULink,1)
        adj{1,i}=find(CULink(i,:));
end
queue=[];%��ǹ��ĺ��û�б������Ľڵ�
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

