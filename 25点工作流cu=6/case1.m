function [ gcase1 ,longest1] = case1( r,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask)
%CASE1 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%������searchLongestPath����

%%%%%%%%%%%

dE =zeros(size(auxD));%ͨ����Դǰ�ĵȴ�ʱ������ֵ
longest1=zeros(1,size(CULink,2));
n_comput=zeros(1,size(CULink,2));
for i=1:size(CULink,1)  %�����������������ĳ��CU��Ȼ���ÿ��CU���·��
        dM=zeros(1,size(auxD,2));%������Դǰ�ĵȴ�ʱ������ֵ
        n_comput(i)=r;%n_comput���п��ޣ�����ֱ����r��Ϊ�˶Գƶ��ѡ�
        %��dM
        for j=1:length(CUtask{2,i})
                if(I(CUtask{2,i}(1,j))~=0)%�����������ڵ㣬������˽ڵ�ĵȴ�ʱ�䡣                       
                        dM(CUtask{2,i}(1,j))=n_comput(i)*average_compute_time{2,i}(1,1);%�Ƿ�Ӧ����length(CUtask)��ˣ�ֵ��˼����ʵ������£����Ƿ��¸���ȷ��Ԥ����
                end
        end
        %ӵ���ڵ�i��CUʱ���·��
        [ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc );
        longest1(i)=L(1);
end
gcase1=max(longest1);
end

