function [ r ] = case2r( arrate, E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink)
%CASE2R �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
r1=1;
r2=2;
while(r1~=r2)
        dcase2=case2(r1,E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink );
        r2=min(arrate*dcase2,500);
        dcase2=case2(r2,E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink );
        r1=min(arrate*dcase2,500);
end
r=r1;

end

