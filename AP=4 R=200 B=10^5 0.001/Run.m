clear;

ren_array=[500];
clear;

ren_array=[200];
AP_array=[4];

load('AT50');
AP_loca=randi([0,1000],3,2);
% AP_loca=[710,119;755,498;276,960;680,340;655,585;162,224];
% AP_loca=[1,599;1,559*2;1,559*3;1,559*4;1,559*5;1,559*6];
% AP_loca=[752,547;255,138;506,149;699,257;891,841;960,254];

AP_loca=[180,0;360,0;540,0;720,0];
% AP_loca=[182,136;264,870;145,580];
AR_array=[0.001];

for ap_temp=1:length(AP_array)
    for arakg=1:length(AR_array)
        Nap=AP_array(ap_temp);
        AR=AR_array(arakg);
        Arrtime=AT{round(AR*1000)};
%         Arrtime=[1 2 3 4 5];
%         Arrtime=1;
        for renakg=1:length(ren_array)
            B_eff=zeros(Nap,Nap);
            distance_ap=zeros(Nap,Nap);
%             for i=1:Nap
%                 for j=1:Nap
%                     distance=sqrt((AP_loca(i,1)-AP_loca(j,1))^2+(AP_loca(i,2)-AP_loca(j,2))^2);
%                     distance_ap(i,j)=distance;
%                     if distance>800
%                         B_eff(i,j)=0;
%                     end
%                     if distance<=800&&distance>600
%                         B_eff(i,j)=0;
%                     end
%                     if distance<=600&&distance>400
%                         B_eff(i,j)=1;
%                     end
%                     if distance<=400&&distance>200
%                         B_eff(i,j)=1;
%                     end
%                     if distance<=200&&distance>0
%                         B_eff(i,j)=1;
%                     end
%                 end
%             end
%             for i=1:Nap
%                 for j=1:Nap
%                     if B_eff(i,j)~=0
%                         B_eff_sign(i,j)=1;
%                     end
%                 end
%             end
%             temp=sum(B_eff_sign);
%             order=zeros(1,Nap);
%            	for i=1:Nap
%                 [~,y]=max(temp);
%                 order(i)=y;
%                 temp(y)=min(temp)-1;
%             end
%             order=[3 5 2 1 6 4];
%             AP_loca=AP_loca(order,:);
            user_state=Main(Nap,AR,Arrtime,ren_array(renakg),AP_loca);
        end
    end
end

