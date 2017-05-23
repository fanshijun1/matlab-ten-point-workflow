function [PCPcell,ranksign] = SearchPCP(y,PCPcell,ranksign,K)
%ASSGNPCP 此处显示有关此函数的摘要
%   此处显示详细说明
            temp=K{2,y};
            temp1=[];
            for i=1:length(temp)
                if any(ranksign(K{1,temp(i)}))==0&&ranksign(temp(i))~=0
                   temp1(end+1)=temp(i);
                end
            end
            if isempty(temp1)==1
                [~,z]=max(ranksign(K{2,y}));
                a=K{2,y}(z);
            else  [~,z]=max(ranksign(temp1));
                   a=temp1(z);% 刷新y的关键后驱任务a
            end
% [~,z]=max(ranksign(K{2,y}));
% a=K{2,y}(1,z);%y的关键后驱任务a 初始化,只运行一遍
while max(ranksign(K{2,y}))~=0&&any(ranksign(K{1,a}))==0
      PCP=[];
      yc=y;
      while max(ranksign(K{2,yc}))~=0&&any(ranksign(K{1,a}))==0%yc有后驱&&后驱的关键任务的前驱的任务都分配过
            PCP(end+1)=a;
            ranksign(a)=0;
            yc=a;
            temp=K{2,yc};
            temp1=[];
            for i=1:length(temp)
                if any(ranksign(K{1,temp(i)}))==0&&ranksign(temp(i))~=0
                   temp1(end+1)=temp(i);
                end
            end
            if isempty(temp1)==1
                [~,z]=max(ranksign(K{2,yc}));
                a=K{2,yc}(z);
            else  [~,z]=max(ranksign(temp1));
                   a=temp1(z);% 刷新y的关键后驱任务a
            end
          
      end
      
      PCPcell{end+1}=PCP;
      for i=1:length(PCP)
          [PCPcell,ranksign]=SearchPCP(PCP(i),PCPcell,ranksign,K);
      end
%       [~,z]=max(ranksign(K{2,y}));
%       a=K{2,y}(z);%最大值所在任务的后驱中取rank最大，任务为a
            temp=K{2,y};
            temp1=[];
            for i=1:length(temp)
                if any(ranksign(K{1,temp(i)}))==0&&ranksign(temp(i))~=0
                   temp1(end+1)=temp(i);
                end
            end
            if isempty(temp1)==1
                [~,z]=max(ranksign(K{2,y}));
                a=K{2,y}(z);
            else  [~,z]=max(ranksign(temp1));
                   a=temp1(z);% 刷新y的关键后驱任务a
            end
end
end