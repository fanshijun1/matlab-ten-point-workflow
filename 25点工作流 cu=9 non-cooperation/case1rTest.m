arrateArray=0.001:0.001:0.05;
r=zeros(1,size(arrateArray,2));
for m=1:length(arrateArray)

arrate=arrateArray(m);
 r(m)= case1r( arrate,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask);
end
plot(arrateArray,r,'r')