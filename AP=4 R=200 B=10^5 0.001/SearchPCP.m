function [PCPcell,ranksign] = SearchPCP(y,PCPcell,ranksign,K)
%ASSGNPCP �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
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
                   a=temp1(z);% ˢ��y�Ĺؼ���������a
            end
% [~,z]=max(ranksign(K{2,y}));
% a=K{2,y}(1,z);%y�Ĺؼ���������a ��ʼ��,ֻ����һ��
while max(ranksign(K{2,y}))~=0&&any(ranksign(K{1,a}))==0
      PCP=[];
      yc=y;
      while max(ranksign(K{2,yc}))~=0&&any(ranksign(K{1,a}))==0%yc�к���&&�����Ĺؼ������ǰ�������񶼷����
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
                   a=temp1(z);% ˢ��y�Ĺؼ���������a
            end
          
      end
      
      PCPcell{end+1}=PCP;
      for i=1:length(PCP)
          [PCPcell,ranksign]=SearchPCP(PCP(i),PCPcell,ranksign,K);
      end
%       [~,z]=max(ranksign(K{2,y}));
%       a=K{2,y}(z);%���ֵ��������ĺ�����ȡrank�������Ϊa
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
                   a=temp1(z);% ˢ��y�Ĺؼ���������a
            end
end
end