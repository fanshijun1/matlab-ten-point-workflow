function [  Map,TSF,Assignrank,Iq,Transferdataq] = AssignPCP( PCPcell,K,Exetimeq,rank,P,Transferdataq,B,Nap,B_eff,Iq)
%ASSIGNPCP �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
Assignrank=cell2mat(PCPcell);
% ��ɵ�����task��Ϊһ��PCP
if Nap>length(PCPcell)
    PCPcelltemp=cell(1,length(Assignrank));
    for i=1:length(Assignrank)
        PCPcelltemp{i}=Assignrank(i);
    end
    PCPcell=PCPcelltemp;
end
Assignrank=cell2mat(PCPcell);
Assignrank=[1 Assignrank length(rank)];%�����һ������,�������һ������

Map=zeros(size(rank,2),size(P,2));% ������Դ�ķ���,������Ϊ��λ���ڲ����������RRT��Ҳ������������EFT����ͬʱ���������AP��ѡ��
Map(1,:)=zeros;
Map(end,:)=zeros;  %exit,entry ���г�ʼ��
TSF=zeros(length(rank),3); %�ֱ���������TRT��EST��EFT
AP_flag=zeros(1,length(P));%Ϊ���������䣬�������AP�ı�־
for i=1:length(PCPcell)
    PCP=PCPcell{i};
    if any(Map(2,:))==0
        [~,Nowr]=max(P);
        AP_flag(Nowr)=1;
        if all(AP_flag)==1
            AP_flag=zeros(1,length(P));
        end
        for j=1:length(PCP)
            Nowin=find(PCP(j)==Assignrank);
            TSF(Nowin,1)=TSF(Nowin-1,3);
            TSF(Nowin,2)=TSF(Nowin-1,3);
            TSF(Nowin,3)=TSF(Nowin,2)+Exetimeq(Nowr,PCP(j));
            Map(Nowin,Nowr)=TSF(Nowin,3);
        end
        
    else   temp=zeros(1,length(P));%���벻ͬ��AP��ʱ��end�ڵ��EFT�������½��бȽ�
        for r=1:length(P)
            tempEFT=zeros(1,length(PCP));%ÿ���ڵ��EFT
            for j=1:length(PCP)
                pre=K{1,PCP(j)};
                premax=zeros(1,length(pre));%ÿ��ǰ���ڵ��TRT�����ڽ��бȽ�
                for k=1:length(pre)
                    c=find(pre(k)==Assignrank);%���ǰ����Assignrank�е�λ��
                    if isempty(find(pre(k)==PCP))==0 %�����PCP֮��
                        premax(k)=tempEFT(j-1);
                    else if find(Map(c,:))==r
                            premax(k)=TSF(c,3);
                        else
                            if isempty(find(Map(c,:)))~=1
                                premax(k)=TSF(c,3)+Transferdataq(pre(k),PCP(j))/(B*B_eff(find(Map(c,:)),r));
                            else
                                premax(k)=TSF(c,3);
                            end
                        end
                    end
                end
                tempTRT=max(premax);
                
                if j==1
                    tempRRT=max(Map(:,r));
                else tempRRT=tempEFT(j-1);
                end
                tempEST=max(tempRRT,tempTRT);
                tempEFT(j)=tempEST+Exetimeq(r,PCP(j));
            end
            temp(r)=tempEFT(end);
        end
        reap=find(AP_flag==0);
        [~,seler_of_reap]=min(temp(reap));
        seler=reap(seler_of_reap);
        
        AP_flag(seler)=1;
        if all(AP_flag)==1
            AP_flag=zeros(1,length(P));
        end
        
        if temp(seler)==inf
            for j=1:length(PCP)
                pre=K{1,PCP(j)};
                premax1=zeros(1,length(pre));%ÿ��ǰ���ڵ��TRT�����ڽ��бȽ�
                for k=1:length(pre)
                    c=find(pre(k)==Assignrank);%���ǰ����Assignrank�е�λ��
                    if isempty(find(pre(k)==PCP))==0 %�����PCP֮��
                        premax1(k)=TSF(c,3);
                    else if find(Map(c,:))==seler
                            premax1(k)=TSF(c,3);
                        else
                            if isempty(find(Map(c,:)))~=1
                                from=find(Map(c,:));
                                to=seler;
                                if B_eff(find(Map(c,:)),seler)==0
                                    ap_temp=from;
                                    while isempty(find(ap_temp(:,end)==to))==1
                                        ap_temptemp=[];
                                        for i1=1:length(ap_temp(:,end))
                                            for j1=1:length(find(B_eff(ap_temp(i1,end),:)))
                                                suc_ap=find(B_eff(ap_temp(i1,end),:));
                                                if isempty(ap_temptemp)==1
                                                    ap_temptemp=[ap_temp(i1,:) suc_ap(j1)];
                                                else
                                                    ap_temptemp(end+1,:)=[ap_temp(i1,:) suc_ap(j1)];
                                                end
                                            end
                                        end
                                        ap_temp=ap_temptemp;
                                    end
                                    
                                    choice_ap=ap_temp(min(find(ap_temp(:,end)==to)),:);
                                    time_between_ap=0;
                                    for i1=1:length(choice_ap)-1
                                        time_between_ap=time_between_ap+Transferdataq(pre(k),PCP(j))/(B*B_eff(choice_ap(i1),choice_ap(i1+1)));
                                    end
                                    for i1=2:length(choice_ap)
                                        if i1~=length(choice_ap)
                                            if i1==2
                                                Transferdataq(end+1,:)=zeros(1,size(Transferdataq,2));
                                                Transferdataq(:,end+1)=zeros(1,size(Transferdataq,1));
                                                Transferdataq(pre(k),end)=Transferdataq(pre(k),PCP(j));
                                                r_temp=zeros(1,size(Map,2));
                                                r_temp(choice_ap(i1))=max(Map(c,:))+Transferdataq(pre(k),PCP(j))/(B*B_eff(choice_ap(i1-1),choice_ap(i1)));
                                            else
                                                Transferdataq(end+1,:)=zeros(1,size(Transferdataq,2));
                                                Transferdataq(:,end+1)=zeros(1,size(Transferdataq,1));
                                                Transferdataq(end-1,end)=Transferdataq(pre(k),PCP(j));
                                                r_temp=zeros(1,size(Map,2));
                                                r_temp(choice_ap(i1))=max(Map(end,:))+Transferdataq(pre(k),PCP(j))/(B*B_eff(choice_ap(i1-1),choice_ap(i1)));
                                            end
                                            Map(end+1,:)=r_temp;
                                            Assignrank(end+1)=Assignrank(end)+1;
                                            Iq(end+1)=0;
                                        else
                                            Transferdataq(end,PCP(j))=Transferdataq(pre(k),PCP(j));
                                        end
                                        
                                    end
                                    
                                    premax1(k)=TSF(c,3)+time_between_ap;
                                    Transferdataq(pre(k),PCP(j))=0;
                                    
                                    
                                else premax1(k)=TSF(c,3)+Transferdataq(pre(k),PCP(j))/(B*B_eff(from,to));
                                end
                            end
                        end
                    end
                end
                Putin=find(PCP(j)==Assignrank);
                TSF(Putin,1)=max(premax1);
                RRT=max(Map(1:length(rank),seler));
                TSF(Putin,2)=max(RRT,TSF(Putin,1));
                TSF(Putin,3)=TSF(Putin,2)+Exetimeq(seler,PCP(j));
                Map(Putin,seler)=TSF(Putin,3);
            end
        else
            for j=1:length(PCP)
                pre=K{1,PCP(j)};
                premax1=zeros(1,length(pre));%ÿ��ǰ���ڵ��TRT�����ڽ��бȽ�
                for k=1:length(pre)
                    c=find(pre(k)==Assignrank);%���ǰ����Assignrank�е�λ��
                    if isempty(find(pre(k)==PCP))==0 %�����PCP֮��
                        premax1(k)=TSF(c,3);
                    else if find(Map(c,:))==seler
                            premax1(k)=TSF(c,3);
                        else
                            if isempty(find(Map(c,:)))~=1
                                premax1(k)=TSF(c,3)+Transferdataq(pre(k),PCP(j))/(B*B_eff(find(Map(c,:)),seler));
                            else premax1(k)=TSF(c,3);
                            end
                        end
                    end
                end
                Putin=find(PCP(j)==Assignrank);
                TSF(Putin,1)=max(premax1);
                RRT=max(Map(:,seler));
                TSF(Putin,2)=max(RRT,TSF(Putin,1));
                TSF(Putin,3)=TSF(Putin,2)+Exetimeq(seler,PCP(j));
                Map(Putin,seler)=TSF(Putin,3);
                
            end
        end
    end
end
end

