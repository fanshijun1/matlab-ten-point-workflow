dM=zeros(1,size(auxD,2));%������Դǰ�ĵȴ�ʱ������ֵ
dE =zeros(size(auxD));%ͨ����Դǰ�ĵȴ�ʱ������ֵ


[ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc );