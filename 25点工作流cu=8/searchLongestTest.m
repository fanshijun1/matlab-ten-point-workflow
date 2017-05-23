dM=zeros(1,size(auxD,2));%计算资源前的等待时间理论值
dE =zeros(size(auxD));%通信资源前的等待时间理论值


[ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc );