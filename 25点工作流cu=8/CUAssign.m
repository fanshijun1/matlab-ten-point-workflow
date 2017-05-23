function [ taskCU,CUtask,auxtask,auxpreSucc,auxD,TT,I ] = CUAssign( CULink,preSucc,PCP,I,Scu,K,D,B)
%CUASSIGN �˴���ʾ�йش˺�����ժҪ
%taskCU ��taskΪ���������������±���һ�£�������TRT,ֱ�Ӱ�������������
%Ԫ�����飬��һ��1-by-2���󣬷ֱ�������ź�CU��
%             �ڶ���1-by-4���󣬷ֱ���TRT RRT EST EFT
%CUtask��CUΪ������CU�����±�һ�£�������RRT��ֱ�Ӱ�������������
%   �ڶ�����ÿ��CU����������±���ɵľ���
% auxtask���ڼ�¼����ڵ㣬auxpreSucc���ڼ�¼�µ�ǰ������ϵ
%����cu
%  TRT RRT EST EFT ��TRSF�� ��Щ��Ҫ����CU���������㣬���Բ��ܵ�������EFT��������û�еݹ���ã����Բ���Ҫ��ʼ���ָ��������������
%taskCUΪ���� ������ʾ����PCP�ŵ�һ�У�������CU,���ݱ�ʾEFT
%���ܵõ�һ�����TRSF����ʾ��ͬ�����TRT RRT EST EFT
%CULink��ʾ����CU֮����ͨ��1������ͨ��0
% p��ʾPCP������q��ʾ�ڵ���PCP���е�����
%   �˴���ʾ��ϸ˵��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��ʼ����������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CUflag=zeros(1,size(CULink,2));%��cu����ǣ�����1��ȫ���������ͳһ��0
Sslice=Scu/K;
ET=I/Sslice;

%��B��ֵ
B=zeros(size(CULink));
for n=1:size(CULink,1)
    for m=1:size(CULink,2)
        if(CULink(n,m)==1)
            B(n,m)=10^6;
        else
            B(n,m)=0;
        end
    end
end

%taskCU��������������ĳ�ʼ��
taskCU=cell(2,length(I));
for i=1:length(I)
    taskCU{1,i}=zeros(1,2);
    taskCU{1,i}(1,1)=i;
    taskCU{2,i}=zeros(1,4);
end

%CUtask�ĳ�ʼ��
CUtask=cell(2,size(CULink,1))
for i=1:size(CULink,1)
    CUtask{1,i}=i;
    CUtask{2,i}=[];
end 

auxtask=[];
TT=zeros(size(D));
auxpreSucc=preSucc;
auxD=D;
EFTcand=zeros(1,size(CULink,2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%������ʼ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%��ÿһ��PCP��ʼ������Ҫ����ʼ

for p=1:size(PCP,2)%p��ʾPCP��������PCPp������������һ��ѭ��,��ÿһ��PCP
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����EFT(p,n)%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for m=1:size(CULink,2)%��ÿһ��CUm
        if(CUflag(m)==0)
            
            for q=1:length(PCP{2,p})%��ÿһ���ڵ�
                taskCU{1,PCP{2,p}(1,q)}(1,2)=m;
                %�ȼ���TRT               
                pre=preSucc{1,PCP{2,p}(1,q)};%�ҵ�ǰ��,p���q�������ǰ��
                if(any(pre)==1)%ǰ������
                    TRTcand=zeros(1,length(pre));%TRTcand��ʾ����ǰ���������EFT+TT
                    for k=1:length(pre)%pre(k)�� PCP{2,p}(1,q)��TRT
                        
                        n=taskCU{1,pre(k)}(1,2);%n->m
                        if(n~=m&&B(n,m)==0&&D(pre(k),PCP{2,p}(1,q))>1)
                             linkPath=findLinkPath( CULink,n,m );
                            TT(pre(k),PCP{2,p}(1,q))=0; 
                            for i=1:(length(linkPath)-2)
                                TT(pre(k),PCP{2,p}(1,q))=TT(pre(k),PCP{2,p}(1,q))+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);                               
                            end                         
                        end
                        if(n~=m&&B(n,m)~=0)
                            TT(pre(k),PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q))/B(n,m);
                        end 
                        if(n==m)
                           TT(pre(k),PCP{2,p}(1,q))=0; 
                        end
                        
                        TRTcand(1,k)=taskCU{2,pre(k)}(1,4)+TT(pre(k),PCP{2,p}(1,q));
                    end
                    taskCU{2,PCP{2,p}(1,q)}(1,1)=max(TRTcand);%TRT�����������
                else
                    taskCU{2,PCP{2,p}(1,q)}(1,1)=0;%TRT������
                end
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%��������RRT����q���ڵ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               asd=CUtask{2,m};%��һ��CUm���е� ����PCP{2,p}(1,q)֮ǰ������ļ���
               %asd�з�����ڵ��EFT
               taskCU{2,PCP{2,p}(1,q)}(1,2)=0;
               if(q==1)    
                   if(any(asd)==1)
                       RRTcand=zeros(1,length(asd));%asd(j)
                       for j=1:length(asd)
                           if(asd(j)<size(D,1))%ȷ��asd(j)��������ڵ�
                            RRTcand(1,j)=taskCU{2,asd(j)}(1,4);
                           end
                       end 
                      taskCU{2,PCP{2,p}(1,q)}(1,2)=max(RRTcand);
                   end
                   %ͬһ��PCP��ǰһ����������ʱ��Ҳ��Ӱ��RRT��                    
               else
                    taskCU{2,PCP{2,p}(1,q)}(1,2) =taskCU{2,PCP{2,p}(1,q-1)}(1,4); 
               end
              
               
               
               
               %���q���ڵ�PCP{2,p}(1,q)��EST EFT
              taskCU{2,PCP{2,p}(1,q)}(1,3)=max(taskCU{2,PCP{2,p}(1,q)}(1,1),taskCU{2,PCP{2,p}(1,q)}(1,2));%EST=max(TRT,RRT)
              taskCU{2,PCP{2,p}(1,q)}(1,4)=ET(PCP{2,p}(1,q))+taskCU{2,PCP{2,p}(1,q)}(1,3);%��ÿһ��PCP{2,p}(1,q)�����EFT
            end%��ÿһ���ڵ������Ҳ�Ƕ�һ��PCP����
            
           
           EFTcand(1,m)=taskCU{2,PCP{2,p}(1,end)}(1,4)%EFTcand����PCP�����һ����������ʱ��
        end
    end%��ÿһ��CUm����
    %��������EFT����ȣ���ȡ��С����
     sortEFTcand=sort(EFTcand);
     sm=find(EFTcand==sortEFTcand(find(sortEFTcand,1,'first')));
    if length(sm)>1
        sm=sm(1);
    end
      
    
    
       EFTcand=zeros(1,size(CULink,2)); 
%%%%%%%%%%%%%%%%%%%%%%%%%%Ϊ�����PCP��������ڵ��TRSF%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    for q=1:length(PCP{2,p})%��ÿһ���ڵ�
        taskCU{1,PCP{2,p}(1,q)}(1,2)=sm;     
        %�ȼ���TRT               
        pre=preSucc{1,PCP{2,p}(1,q)};%�ҵ�ǰ��,p���q�������ǰ��
        if(any(pre)==1)%ǰ������
            TRTcand=zeros(1,length(pre));%TRTcand��ʾ����ǰ���������EFT+TT
            for k=1:length(pre)%pre(k)�� PCP{2,p}(1,q)��TRT
                n=taskCU{1,pre(k)}(1,2);%n->sm
                if(n~=sm&&B(n,sm)==0&&D(pre(k),PCP{2,p}(1,q))>1)
                    linkPath=findLinkPath( CULink,n,sm );
                    TT(pre(k),PCP{2,p}(1,q))=0; 
                    for i=1:length(linkPath)-2
                        TT(pre(k),PCP{2,p}(1,q))=TT(pre(k),PCP{2,p}(1,q))+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);                               
                    end                         
                end
                if(n~=sm&&B(n,sm)~=0)
                    TT(pre(k),PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q))/B(n,sm);
                end 
                if(n==sm)
                       TT(pre(k),PCP{2,p}(1,q))=0; 
                end
                TRTcand(1,k)=taskCU{2,pre(k)}(1,4)+TT(pre(k),PCP{2,p}(1,q));%���ʱ��Ӵ���ʱ��
            end
            taskCU{2,PCP{2,p}(1,q)}(1,1)=max(TRTcand);%TRT�����������
        else
            taskCU{2,PCP{2,p}(1,q)}(1,1)=0;%TRT������
        end
        %��ʼ����RRT
      asd=CUtask{2,sm};%��һ��CUm���е� ����PCP{2,p}(1,q)֮ǰ������ļ���
               %asd�з�����ڵ��EFT
               taskCU{2,PCP{2,p}(1,q)}(1,2)=0;
               if(q==1)    
                   if(any(asd)==1)
                       RRTcand=zeros(1,length(asd));%asd(j)
                       for j=1:length(asd)
                           if(asd(j)<size(D,1))%ȷ��asd(j)��������ڵ�
                            RRTcand(1,j)=taskCU{2,asd(j)}(1,4);
                           end
                       end 
                      taskCU{2,PCP{2,p}(1,q)}(1,2)=max(RRTcand);
                   end
                   %ͬһ��PCP��ǰһ����������ʱ��Ҳ��Ӱ��RRT��                    
               else
                    taskCU{2,PCP{2,p}(1,q)}(1,2) =taskCU{2,PCP{2,p}(1,q-1)}(1,4); 
               end



       %���q���ڵ�PCP{2,p}(1,q)��EST EFT
      taskCU{2,PCP{2,p}(1,q)}(1,3)=max(taskCU{2,PCP{2,p}(1,q)}(1,1),taskCU{2,PCP{2,p}(1,q)}(1,2));%EST=max(TRT,RRT)
      taskCU{2,PCP{2,p}(1,q)}(1,4)=ET(PCP{2,p}(1,q))+taskCU{2,PCP{2,p}(1,q)}(1,3);%��ÿһ��PCP{2,p}(1,q)�����EFT
    end%��ÿһ���ڵ������Ҳ�Ƕ�һ��PCP����
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%����ڵ�����¼���%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for q=1:length(PCP{2,p})%��ÿһ���ڵ�                 
        pre=preSucc{1,PCP{2,p}(1,q)};%�ҵ�ǰ��,p���q�������ǰ��
        if(any(pre)==1)%ǰ������
            for k=1:length(pre)%pre(k)�� PCP{2,p}(1,q)��TRT
                n=taskCU{1,pre(k)}(1,2);%n->sm
                linkPath=findLinkPath( CULink,n,sm );
                if(B(n,sm)==0&&D(pre(k),PCP{2,p}(1,q))>1)%B(n,sm)==0��ʾ�������ڵĽڵ�
                    
                    sub=length(linkPath)-2%sub��ʾ��Ҫ���������ڵ�ĸ���
                    for i=1:sub
                        I(end+1)=0;
                        auxtask(end+1)=length(I);
                         %�ı�ǰ������ϵ�Լ�auxD
                       if(i==1)
                           auxpreSucc{2,pre(k)}(1,find(auxpreSucc{2,pre(k)}==PCP{2,p}(1,q)))=length(I);%pre(k)�ĺ�����Ϊlength��I��
                           auxpreSucc{1,length(I)}=pre(k);
                           auxpreSucc{2,length(I)}=length(I)+1;
                           auxpreSucc{1,PCP{2,p}(1,q)}(1,find(auxpreSucc{1,PCP{2,p}(1,q)}==pre(k)))=length(I);%PCP{2,p}(1,q)��ǰ����Ϊ����ڵ�
                           if(i==1&&sub==1)
                           auxpreSucc{2,length(I)}=PCP{2,p}(1,q);
                           end
                           auxD(pre(k),end+1)=D(pre(k),PCP{2,p}(1,q));
                           auxD(end+1,pre(k))=D(pre(k),PCP{2,p}(1,q));
                           if(sub==1)
                           auxD(end,PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q));
                           auxD(PCP{2,p}(1,q),end)=D(pre(k),PCP{2,p}(1,q));
                           end
                       end
                       if(i>1&&i<sub)
                            auxpreSucc{1,length(I)}=length(I)-1;
                            auxpreSucc{2,length(I)}=length(I)+1;
                            auxD(end+1,end)=D(pre(k),PCP{2,p}(1,q));
                            auxD(end-1,end+1)=D(pre(k),PCP{2,p}(1,q));
                       end
                        if(i==sub&&sub~=1)
                            auxpreSucc{2,length(I)-1}=length(I);
                            auxpreSucc{1,length(I)}=length(I)-1;
                            auxpreSucc{2,length(I)}=PCP{2,p}(1,q);
                            auxpreSucc{1,PCP{2,p}(1,q)}(1,find(auxpreSucc{1,PCP{2,p}(1,q)}==length(I)-sub+1))=length(I);%i=1ʱ��ֵ��������ע���Ǽ�2
                            
                            auxD(end+1,PCP{2,p}(1,q))=D(pre(k),PCP{2,p}(1,q));
                            auxD(end-1,end+1)=D(pre(k),PCP{2,p}(1,q));
                            auxD(end,end-1)=D(pre(k),PCP{2,p}(1,q));
                            auxD(PCP{2,p}(1,q),end)=D(pre(k),PCP{2,p}(1,q));
                        end
                        %���Ӹ���taskCUif(n<sm)
                        if(n<=sm)
                        CUtask{2,min(n,sm)+i}(1,end+1)=length(I);%length(I)�ڵ�
                        taskCU{1,end+1}=[length(I),min(n,sm)+i];
                        else%�����4->1,��32�ڵ���䵽3CU��33�ڵ���䵽2CU
                                CUtask{2,max(n,sm)-i}(1,end+1)=length(I);%length(I)�ڵ�
                                taskCU{1,end+1}=[length(I),max(n,sm)-i];
                        end
                       if(i==1)                                  
                           taskCU{2,length(I)}(1,4)= taskCU{2,pre(k)}(1,4)+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);%���length(I)�����ʱ��
                           %����������Ҫ����Դ׼��
                           taskCU{2,length(I)}(1,3)=taskCU{2,length(I)}(1,4);
                           taskCU{2,length(I)}(1,1)=taskCU{2,pre(k)}(1,4);
                       else
                           taskCU{2,end}(1,4)=taskCU{2,end-1}(1,4)+D(pre(k),PCP{2,p}(1,q))/B(i,i+1);
                           taskCU{2,end}(1,3)=taskCU{2,end}(1,4);
                           taskCU{2,end}(1,1)=taskCU{2,end-1}(1,4);
                       end
                       
                    end
                end
            end
        end 
    end            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    CUtask{2,sm}(end+1:end+length(PCP{2,p}))=PCP{2,p};
    CUflag(1,sm)=1;
     if(all(CUflag)==1)
        CUflag=zeros(1,size(CULink,2));
     end
end    










