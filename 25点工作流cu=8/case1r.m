function [ r ] = case1r( arrate,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask )
%CASE1R 此处显示有关此函数的摘要
%   此处显示详细说明
r1=2;
r2=4;
while(r1~=r2)
        dcase1=case1( r1,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask);
        r2=min(arrate*dcase1,500);
        dcase1=case1( r2,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask );
        r1=min(arrate*dcase1,500);
end
r=r1;
end

