function [ gcase2,longest2] = case2(r,E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink )
%CASE2 �˴���ʾ�йش˺�����ժҪ
%�����ˣ�layerAssign����
%              searchLongestPath����
%   �˴���ʾ��ϸ˵��
%%%%%%%%%%%%%case2����ȴ�������%%%%%%%%%%%%%%%%
dM=zeros(1,size(auxD,2));%������Դǰ�ĵȴ�ʱ������ֵ
longest2=zeros(1,length(T));
b=zeros(size(CULink));%�����еı�������ʾ�������Ͳ����ı�ֵ
ly=layerAssign( D,auxD,auxpreSucc );%�õ������ֱ�ͼ
for v=1:length(T)
        dE =zeros(size(auxD));%ͨ����Դǰ�ĵȴ�ʱ������ֵ
        %����ǰv����µ���·�е�ÿһ�������������dE( , )
        for i=1:v%T{1,i}=[2,3]
                trans_task=E(T{1,i}(1,1)).E(T{1,i}(1,2)).task;
                n_trans=zeros(size(auxD));       
                for j=1:length(trans_task)%trans_task{1,j}(1,1),,,trans_task{1,j}(1,2)
                        layer=[];
                        for k=1:length(trans_task)%trans_task{1,j}(1,1),,,trans_task{1,j}(1,2)
                                layer(1,end+1)=ly(2,trans_task{1,k}(1,1));%�ڶ��б�ʾ���ڵĲ���
                        end
                        layer=unique(layer);%ȥ���ظ��Ĳ���
                        layer_num=length(layer);
                        b(T{1,i}(1,1),T{1,i}(1,2))=length(trans_task)/layer_num;%ÿ����·�����������Բ���,ӦΪÿ�������bͬ�����·��b��һ���ģ���ͬ����·bֵ�ǲ�һ����
                        n_trans(trans_task{1,j}(1,1),trans_task{1,j}(1,2))=r*b(T{1,i}(1,1),T{1,i}(1,2));
                        %�˴��������dEֵ
                        dE(trans_task{1,j}(1,1),trans_task{1,j}(1,2))=n_trans(trans_task{1,j}(1,1),trans_task{1,j}(1,2))*average_communicate_time(T{1,i}(1,1),T{1,i}(1,2));
                end    

        end
         %����ǰv����µ���·������·��
         [ L,flag] = searchLongestPath( dM,dE,I,Scu,K,D,auxD,B,auxpreSucc );
         longest2(v)=L(1);
end
gcase2=max(longest2);

end

