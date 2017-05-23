%内容准备阶段
preSucc={[],[1],[1],[1],[1],[1],[2,3],[2,3],[3,5],[2,4],[3,4],[4],[3,5],[3,6],[5,6],[7,8,9,10,11,12,13,14,15],[16],[2,17],[3,17],[4,17],[5,17],[6,17],[18,19,20,21,22],[23],[24],[25],[26];
                [2,3,4,5,6],[7,8,10,18],[7,8,9,11,13,14,19],[10,11,12,20],[9,13,15,21],[14,15,22],[16],[16],[16],[16],[16],[16],[16],[16],[16],[17],[18,19,20,21,22],[23],[23],[23],[23],[23],[24],[25],[26],[27],[]};
I=[0,1339000,1383000,1336000,1360000,1378000,1059000,1059000,1088000,1081000,1049000,1051000,1051000,1062000,1037000,72000,142000,1039000,1064000,1083000,1093000,1076000,139000,303000,386000,45000,0];
Scu=10^5;
K=10;
D=[0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,8334624,8362898,0,8287354,0,0,0,0,0,0,0,8326168,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,8343702,8371246,8311060,0,8301204,0,8340796,8311328,0,0,0,0,8323662,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,8314244,8299612,8304794,0,0,0,0,0,0,0,8364646,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,8348008,0,0,0,8346144,0,8326392,0,0,0,0,0,8341716,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,8307042,8282778,0,0,0,0,0,0,8315294,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,408676,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,314473,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,228889,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,176628,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,233738,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,251473,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,271522,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,313399,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,297528,0,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1889,0,0,0,0,0,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,265,265,265,265,265,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8326168,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8323662,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8364646,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8341716,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,8315294,0,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1599,0,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,93019228,0,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1861129,0;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1;
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
B=10^7;
Sslice=Scu/K;
ET=I/Sslice;
TT=D/B;
[ rank ] = pri(preSucc ,I,Scu,K,D,B );
%前面是求rank所必需的基本量
[ PCP ] = searchPcp( preSucc,rank);%PCP这个函数只需要两个量，函数的参数选择尽量少，量的层级尽量基础
%接着是部署CU所需要的量；
% CULink=[1,1,0,0;
%         1,1,1,0;
%         0,1,1,1;
%         0,0,1,1];%1表示两个CU之间有链接，同一个CU也就是对角线上也都表示为1，表示连通
CULink=[1,1,1,1;
              1,1,1,1;
              1,1,1,1;
              1,1,1,1];
 [ taskCU,CUtask,auxtask,auxpreSucc,auxD,TT,I ] = CUAssign( CULink,preSucc,PCP,I,Scu,K,D,B);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
location={[1,1],[1,2],[1,3],[1,4],[1,5];
                [2,1],[2,2],[2,3],[0,0],[2,5];
                [3,1],[3,2],[0,0],[0,0],[3,5];
                [0,0],[4,2],[4,3],[4,4],[4,5];
                [5,1],[5,2],[5,3],[5,4],[5,5]};



userArrate=[0.014,0.020,0.006,0.004,0.008;
                   0.008,0.018,0.008,0.000,0.020;
                   0.012,0.012,0.000,0.000,0.010;
                   0.000,0.014,0.006,0.006,0.004;
                   0.008,0.012,0.018,0.010,0.020]
leapArrate=0.012*ones(5,5);

for i=1:size(userArrate,1)
        for j=1:size(userArrate,2)
                if(userArrate(i,j)==0)
                        leapArrate(i,j)=0;
                end
        end
end

 codelocation=zeros(5,5);
 %编码方式为[1,2]---1*5+2----7 障碍区域的编码为0
 %逆编码为   7%5=2  （7-2）/5=1
 for i=1:size(location,1)
         for j=1:size(location,2)
                 codelocation(i,j)=size(location,1)*location{i,j}(1,1)+location{i,j}(1,2);
         end
 end
transArrate=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;  % 1行
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0, 0,0,0,0,0, 0.002,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;       %6行
                     0,0,0,0,0, 0,0,0.006,0.002,0, 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;           %11行
                     0,0,0,0,0, 0,0,0,0,0, 0.002,0,0.004,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,  0,0,0,0.002,0.004,  0,0,0,0,0,  0,0,0,0,0.002, 0,0,0,0,0 , 0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;           %16行
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;            %21行
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0,0.002,0,0,  0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;            %26行
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  0,0, 0.004 ,0,0,  0,0,0, 0.002 ,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0.008,  0,0,0,0,0
                    ]
loadArrate=userArrate-leapArrate;
sysArrate=[0.012,0.012,0.012,0.008,0.012;
                  0.012,0.012,0.012,0.000,0.012;
                  0.012,0.012,0.000,0.000,0.012;
                  0.000,0.012,0.012,0.006,0.012;
                  0.008,0.012,0.012,0.012,0.012];

SUM=sum(sum(sysArrate));
userAssign=zeros(size(sysArrate,1),size(sysArrate,2));
for i=1:size(sysArrate,1)
        for j=1:size(sysArrate,2)
                userAssign(i,j)=floor(30000*sysArrate(i,j)/SUM);
        end
end
%  [ CU,channel,user,mean_makespan,temp_clock,temp_usernum,temp_makespan]  = mainregion(taskCU,CUtask, CULink,auxpreSucc,PCP,I,Scu,K,auxD,B ,0.006,756); 
span=zeros(size(sysArrate,1),size(sysArrate,2));
% for i=1:size(sysArrate,1)
%         for j=1:size(sysArrate,2)
%                 if(sysArrate(i,j)~=0)
%                     [ CU,channel,user,mean_makespan,temp_clock,temp_usernum,temp_makespan]  = mainregion(taskCU,CUtask, CULink,auxpreSucc,PCP,I,Scu,K,auxD,B ,sysArrate(i,j),userAssign(i,j)); 
%                     span(i,j)=mean_makespan;
%                 end
%         end
% end
%sum_span(i,j)表示区域【i，j】的均值*用户数，即是此区域的总的用户耗时
sum_span=zeros(size(sysArrate,1),size(sysArrate,2));
          span=[1167.9,1167.9,1167.9,1109.2,1167.9;
                     1167.9,1167.9,1167.9,        0,1167.9;
                     1167.9,1167.9,0        ,         0,1167.9;
                             0,1167.9,1167.9,1122.1,1167.9;
                     1109.2,1167.9,1167.9,1167.9,1167.9
                  ]
for i=1:size(sysArrate,1)
        for j=1:size(sysArrate,2)
               sum_span(i,j)= span(i,j)*userAssign(i,j);
        end
end
%end_span表示最终的均值
endSpan=sum(sum(sum_span))/30000;

         