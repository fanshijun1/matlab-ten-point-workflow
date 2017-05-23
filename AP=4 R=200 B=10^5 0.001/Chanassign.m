function [ Channel ] = Chanassign( Channum,P,LPqu )
%CHANASSIGN 此处显示有关此函数的摘要
%   此处显示详细说明
Channel=cell(length(P),length(P));
for i=1:length(P)
    for j=1:length(P)
        if LPqu(i,j)>0
            temp1=[];
            iout=find(LPqu(i,:));
            if isempty(iout)
            else
            for s=1:length(iout)
                chang=size(temp1,1);
                temp1(chang+1,1)=i;
                temp1(chang+1,2)=iout(s);
            end
            end
            jout=find(LPqu(j,:));
            if isempty(jout)
            else
            for s=1:length(jout)
                chang=size(temp1,1);
                temp1(chang+1,1)=j;
                temp1(chang+1,2)=jout(s);
            end
            end
            iin=(find(LPqu(:,i)))';
            if isempty(iin)
            else
            for s=1:length(iin)
                chang=size(temp1,1);
                temp1(chang+1,1)=iin(s);
                temp1(chang+1,2)=i;
            end
            end
            jin=(find(LPqu(:,j)))';
            if isempty(jin)
            else
            for s=1:length(jin)
                chang=size(temp1,1);
                temp1(chang+1,1)=jin(s);
                temp1(chang+1,2)=j;
            end
            end
            temp=unique(temp1,'rows');
            Cnum=floor(Channum/length(temp));
            temp2=1;
            cho=ismember(temp,[i j],'rows');
            cho=find(cho');
            temp(cho,:)=[];%去除本身，得到干扰集
            while Cnum~=0&&temp2~=Channum+1
                  temp3=[];%放入干扰集中所有的信道标号
                  for k=1:size(temp,1)
                      from=temp(k,1);
                      to=temp(k,2);
                      temp3(end+1:end+length(Channel{from,to}))=Channel{from,to};
                  end
%                 temp3=[];
%                 a=find(LPqu(i,:));
%                 for k=1:length(a)
%                     temp3(end+1:end+length(Channel{i,a(k)}))=Channel{i,a(k)};
%                 end
%                 b=(find(LPqu(:,j)))';
%                 for k=1:length(b)
%                     temp3(end+1:end+length(Channel{b(k),j}))=Channel{b(k),j};
%                 end
%                 temp3(end+1:end+length(Channel{j,i}))=Channel{j,i};
                if isempty(find(temp3==temp2))
                Channel{i,j}(end+1)=temp2;
                Cnum=Cnum-1;
                end
                temp2=temp2+1;
            end
        end
    end
end
%因为是向下取整，有些信道没有分配，对于这些没有分配的信道，我们将它安顺讯分配
    Channel_count=[];
    for i=1:length(P)
        for j=1:length(P)
            Channel_count(end+1:end+length(Channel{i,j}))=Channel{i,j};
        end
    end
    Channelrest=1:1:Channum;
    for i=1:length(Channel_count)
        temp=find(Channelrest==Channel_count(i));
        Channelrest(temp)=[];
    end
    while isempty(Channelrest)~=1
        flag=0;
        for i=1:length(P)
            for j=1:length(P)
                if isempty(Channel{i,j})~=1
                    Channel{i,j}(end+1)=Channelrest(1);
                    Channelrest(1)=[];
                    if isempty(Channelrest)==1
                        flag=1;
                        break
                    end
                end
            end
            if flag==1
                break
            end
        end
    end
end

