arrateArray=0.001:0.0002:0.02;
r=zeros(size(arrateArray));
for m=1:96

arrate=arrateArray(m);
 r(m)= case1r( arrate,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask);
end
plot(arrateArray,20*r,'b');