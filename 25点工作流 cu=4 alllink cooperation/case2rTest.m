arrateArray=0.004:0.004:0.08;
r=zeros(size(arrateArray));
for m=1:20

arrate=arrateArray(m);
 r(m)= case2r( arrate,E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc,CULink);
end