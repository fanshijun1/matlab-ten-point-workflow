clear;

ren_array=[10 100 500];
AP_array=[3];
load('AT50');
AR_array=[0.008 0.016 0.024 0.032 0.04];
for ap_temp=1:length(AP_array)
    for arakg=1:length(AR_array)
        Nap=AP_array(ap_temp);
        AR=AR_array(arakg);
        Arrtime=AT{round(AR*1000)};
        %         Arrtime=[1 2 3 4 5 6 7 8 9 10 11];
        for renakg=1:length(ren_array)
            user_state=Main(Nap,AR,Arrtime,ren_array(renakg));
        end
    end
end