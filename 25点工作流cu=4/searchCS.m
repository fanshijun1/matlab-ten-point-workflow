function [ CS ] = searchCS( y,preSucc,rank, flag)
%SEARCHCS �˴���ʾ�йش˺�����ժҪ
%����y�ڵ��ֱ��ǰ��������˵ĺ���(������δ����ǵĵ������rankֵ�Ľڵ�)
%   �˴���ʾ��ϸ˵��
if(flag(y)==1)
    temp=[];
    CScand=[];%��ʾǰ��������ǣ��Լ�û�б���ǵļ���
    succ=preSucc{2,y};%succ��ʾ��̼���
    if(length(succ)~=0)%��̲���
        for i=1:length(succ)%iָ��succ��Ԫ�أ���succ(i)
            if(flag(succ(i))==0)%���û�б����
                pre=preSucc{1,succ(i)};
                if(all(flag(pre))==1)%ǰ���������
                    CScand(end+1)=succ(i);
                else
                    CS=-1;
                end
            else
                continue;
            end
        end
    else
        CS=-1;
    end
    
       
    temprank=zeros(1,length(rank));
    temprank(CScand) = rank(CScand);
    if(any(temprank)==1)%temprankԪ��ȫΪ��
         CS=find(temprank==max(temprank));%a���rank���±�,find a = CS(i).��temprankȫΪ�㣬����1��ʮ������
    else CS=-1;
    end
    
else
    CS=-1;
end

