
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ���õĺ�����
% case1 case2:�������������µ��ӳ�
% case1r case2r��������������µ�ϵͳ�û���r
% searchLongestPath:��Ѱ�ҳ��·��ֵ
% layerAssign��Ѱ�ҳ�ÿ���ڵ�ĺ������ڵĲ���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arrateArray=0.001:0.001:0.05;
longest1=cell(0,0);
longest2=cell(0,0);
dcase1=zeros(1,length(arrateArray));%��һ�������µ��ӳ�
dcase2=zeros(1,length(arrateArray));%�ڶ��������µ��ӳ�
d=zeros(1,length(arrateArray));%��Ȩ������ӳ�

for m=1:length(arrateArray);


%%%%%%%%%%%����׼������USENUM,dM,dE,average_compute_time,average_communication_time,predlevel,T,E%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
arrate=arrateArray(m);%��ʾÿ�뵽��0.02���ˣ�����ķ��ʵ��Ϊarrate
% arrnum=1/arrate;arrnum�Ǵ�ģ���ʾÿ�����񵽴�ļ��ʱ��


USERNUM=500;
auxET=I/(Scu/K);%��������ڵ�ļ���ʱ��
for i=1:size(auxD,1)
        for j=1:size(auxD,2)
                if(auxD(i,j)==1)
                        auxD(i,j)=0;
                end
        end
end
auxTT=auxD/B;%��������ڵ�Ĵ���ʱ��




%ǰ���ȵļ��㣬���������е�a��������
sum=0;
for i=1:size(auxD,2)
    sum=sum+length(auxpreSucc{1,i});
end
predlevel=sum/size(auxD,2);

average_compute_time=cell(0,0);%ÿ��CUƽ������ʱ�䣬���������е�d/K 
average_communicate_time=zeros(size(CULink));%���������е�d�����ֵ
communicate_num=zeros(size(CULink));

%CUƽ������ʱ��ĵ�һ��
for i=1:size(CULink,1)
        average_compute_time{1,i}=i;
        average_compute_time{2,i}=0;
end

%CUƽ������ʱ��ĵڶ���
for i=1:size(CULink,1)
        num=0;%ʵ�ڵ������
        for j=1:length(CUtask{2,i})
                %�����ʵ�ڵ�
                if(I(CUtask{2,i}(1,j))>0)
                        average_compute_time{2,i}=average_compute_time{2,i}+I(CUtask{2,i}(1,j));
                        num=num+1;                     
                end
        end
       average_compute_time{2,i}=average_compute_time{2,i}/(num*Scu);%���������е�d/K 
end

%���㴫������������
for i=2:length(I)-1%��ÿһ���ڵ��㵽ÿһ�������ڵ�Ĵ��������ս�㲻��Ҫ����
        succ=auxpreSucc{2,i};
        for j=1:length(succ)%i�ڵ�->auxpreSucc{2,i}(1,j)����succ(j)
                if(taskCU{1,i}(1,2)~=taskCU{1,succ(j)}(1,2))
               average_communicate_time(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))=average_communicate_time(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))+auxD(i,succ(j));
               communicate_num(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))= communicate_num(taskCU{1,i}(1,2),taskCU{1,succ(j)}(1,2))+1;
                end
        end
        succ=[];
end

%�������
for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                if(communicate_num(i,j)>0&&i~=j)
                average_communicate_time(i,j)=average_communicate_time(i,j)/(communicate_num(i,j)*B);%���������е�d�����ֵ
                end
        end
end

%����T�ļ���
%���ĸ�CUΪ��T={[1,2],[2,1],[2,3],[3,2],[3,4],[4,3]
 %                            
% T=cell(0,0);
% for i=1:size(CULink,1)
%      if(i~=1)
%             T{1,end+1}=[i,i-1];
%     end
% 
%     if(i~=4)
%             T{1,end+1}=[i,i+1];
%     end
% 
% end
 
%����E�ļ��� 

for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                E(i).E(j).task=cell(0,0);
                E(i).E(j).sum=0;%���ô�����
        end
end
for i=2:size(auxD,2)-1%��β�ڵ㲻����
      succ=auxpreSucc{2,i};
      for j=1:length(succ)
            E(taskCU{1,i}(1,2)).E(taskCU{1,succ(j)}(1,2)).task{1,end+1}=[i,succ(j)];
      end
end
%����E(i).E(j).sum
V=zeros(size(CULink));
for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                if(i~=j)
                        for k=1:length(E(i).E(j).task)
                                E(i).E(j).sum=E(i).E(j).sum+auxD(E(i).E(j).task{1,k}(1,1),E(i).E(j).task{1,k}(1,2));
                        end
                        V(i,j)=E(i).E(j).sum;
                end
        end
end

%T�����������ͨ��������������ŵ�;[x(1),y(1)]��ֹV������ȵ�Ԫ��ʱ��ֻ�ӵ�һ����
T=cell(0,0);
while(any(any(V))==1)
                [x,y]=find(V==max(max(V)));%�ҵ�V�����ֵ�Ķ�άλ��
                T{1,end+1}=[x(1),y(1)];
                V(x(1),y(1))=0;                
end


%%%%%%%%%%%%%�ܵ��·��%%%%%%%%%%%%%%%%%
cs1r(m)=case1r( arrate,average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink ,CUtask );
[dcase1(m),longest1{m}]= case1( cs1r(m),average_compute_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink,CUtask);
cs2r(m)=case2r( arrate,E, T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink);
[dcase2(m),longest2{m}]=case2(cs2r(m),E,T,average_communicate_time,I,Scu,K,D,auxD,B,auxpreSucc ,CULink );


act=mean(auxET(find(auxET)))/10;%ƽ������ʱ�� average communicate time
% att=mean(auxTT(find(auxTT)))%ƽ������ʱ�� average transport time
trans_sum=0;
trans_num=0;
for i=1:size(CULink,1)
        for j=1:size(CULink,2)
                if(i~=j)
                        trans_sum=trans_sum+E(i).E(j).sum;
                        trans_num=trans_num+length(E(i).E(j).task);
                end
        end
end
att=trans_sum/(trans_num*B);
% att=0.5526;
n1=act/(act+att);
n2=att/(act+att);
d(m)=n1*dcase1(m)+n2*dcase2(m);
end
plot(arrateArray,d,'r');
hold on;