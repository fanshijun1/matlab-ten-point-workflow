arrateArray=0.001:0.0002:0.02;
r=zeros(size(arrateArray));
for m=1:96

arrate=arrateArray(m);
 r(m)= case2r( arrate,E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc,CULink);
end
plot(arrateArray,20*r,'r');