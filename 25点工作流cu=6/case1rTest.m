arrateArray=0.004:0.004:0.02;
r=zeros(size(arrateArray));
for m=1:5

arrate=arrateArray(m);
 r(m)= case1r( arrate,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask);
end