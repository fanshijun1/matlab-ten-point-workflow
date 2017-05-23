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

CULink=[1,1,1,1;
              1,1,1,1;
              1,1,1,1;
              1,1,1,1];
 [ taskCU,CUtask,auxtask,auxpreSucc,auxD,TT,I ] = CUAssign( CULink,preSucc,PCP,I,Scu,K,D,B);
[ CU,channel,user,mean_makespan,a ] = main(taskCU,CUtask, CULink,auxpreSucc,PCP,I,Scu,K,auxD,B );
