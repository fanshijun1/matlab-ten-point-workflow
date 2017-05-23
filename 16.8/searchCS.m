function [ CS ] = searchCS( y,preSucc,rank, flag)
%SEARCHCS 此处显示有关此函数的摘要
%返回y节点的直接前驱被标记了的后驱(后驱是未被标记的当中最大rank值的节点)
%   此处显示详细说明
if(flag(y)==1)
    temp=[];
    CScand=[];%表示前驱都被标记，自己没有被标记的集合
    succ=preSucc{2,y};%succ表示后继集合
    if(length(succ)~=0)%后继不空
        for i=1:length(succ)%i指向succ的元素，是succ(i)
            if(flag(succ(i))==0)%后继没有被标记
                pre=preSucc{1,succ(i)};
                if(all(flag(pre))==1)%前驱都被标记
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
    if(any(temprank)==1)%temprank元素全为零
         CS=find(temprank==max(temprank));%a最高rank的下标,find a = CS(i).若temprank全为零，返回1到十个数字
    else CS=-1;
    end
    
else
    CS=-1;
end

