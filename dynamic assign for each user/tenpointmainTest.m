%WF1����
% preSucc={[],[1],[1],[1],[1],[2,4],[3,4],[2,4,5],[6,7,8],[9];
%         [2,3,4,5],[6,8],[7],[6,7,8],[8],[9],[9],[9],[10],[]};
%  I = [0,1339000,1383000,1336000,1378000,1037000,1059000,1088000,1755000,0];
% D=[0,1,1,1,1,0,0,0,0,0;
%    0,0,0,0,0,8334624,0,8873456,0,0;
%    0,0,0,0,0,0,8517569,0,0,0;
%    0,0,0,0,0,7511132,8340796,8324756,0,0;
%    0,0,0,0,0,0,0,7853276,0,0;
%    0,0,0,0,0,0,0,0,8326168,0;
%    0,0,0,0,0,0,0,0,8861129,0;
%    0,0,0,0,0,0,0,0,8315294,0;
%    0,0,0,0,0,0,0,0,0,1;
%    0,0,0,0,0,0,0,0,0,0];
%WF2����
preSucc={[],[1],[1],[1],[3,4],[2,3,4],[4],[5,6],[5,7],[8,9];
        [2,3,4],[6],[5,6],[5,6,7],[8,9],[8],[9],[9],[10],[10]};
 I = [0,1215000,1473000,1512000,1394000,1798000,1032000,1154000,1192000,0];
D=[0,1,1,1,0,0,0,0,0,0;
   0,0,0,0,0,7853564,0,0,0,0;
   0,0,0,0,7792472,8793454,0,0,0,0;
   0,0,0,0,8522662,8411597,8030566,0,0,0;
   0,0,0,0,0,0,0,7562431,7943122,0;
   0,0,0,0,0,0,0,7743154,0,0;
   0,0,0,0,0,0,0,0,8182919,0;
   0,0,0,0,0,0,0,0,0,1;
   0,0,0,0,0,0,0,0,0,1;
   0,0,0,0,0,0,0,0,0,0];
Scu=10^5;
K=10;
B=10^6;
Sslice=Scu/K;
ET=I/Sslice;
TT=D/B;
[ rank ] = pri(preSucc ,I,Scu,K,D,B );
%ǰ������rank������Ļ�����
% [PCP ] = searchPcp( preSucc,rank);%PCP�������ֻ��Ҫ�������������Ĳ���ѡ�����٣����Ĳ㼶��������
%�����ǲ���CU����Ҫ����
PCP={1,2,3,4,5,6,7,8,9,10;
        1,2,3,4,5,6,7,8,9,10};
% CULink=[1,1,0,0;
%         1,1,1,0;
%         0,1,1,1;
%         0,0,1,1;];%1��ʾ����CU֮�������ӣ�ͬһ��CUҲ���ǶԽ�����Ҳ����ʾΪ1����ʾ��ͨ
% CULink=[1,1,0,0,0,0;
%         1,1,1,0,0,0;
%         0,1,1,1,0,0;
%         0,0,1,1,1,0;
%         0,0,0,1,1,1;
%         0,0,0,0,1,1];
CULink=zeros(10,10)+1;
    
[ taskCU,CUtask,auxtask,auxpreSucc,auxD,TT ] = CUAssign( CULink,preSucc,PCP,I,Scu,K,D,B);
% taskCU={[1,1],[2,3],[3,2],[4,4],[5,1],[6,4],[7,3],[8,4],[9,4],[10,4],[11,2],[12,3];
%     [0,0,0,0],[0,0,0,133.9],[0,0,0,138.3],[0,0,0,133.6],[0,0,0,137.8],[0,0,0,373.8598],[0,0,0,252.7176],[0,0,0,270.1598],[0,0,0,549.3598],[0,0,0,549.3598],[0,0,0,145.6533],[0,0,0,153.5066]};
% CUtask={[1],[2],[3],[4];[1,5],[3,11],[2,7,12],[4,8,6,9,10]};
% auxtask=[11,12];
% auxpreSucc={[],[1],[1],[1],[1],[2,4],[3,4],[2,4,12],[6,7,8],[9],[5],[11];
%         [2,3,4,5],[6,8],[7],[6,7,8],[11],[9],[9],[9],[10],[],[12],[8]};
% auxD=[0,1,1,1,1,0,0,0,0,0,0,0;
%    0,0,0,0,0,8334624,0,8873456,0,0,0,0;
%    0,0,0,0,0,0,8517569,0,0,0,0,0;
%    0,0,0,0,0,7511132,8340796,8324756,0,0,0,0;
%    0,0,0,0,0,0,0,7853276,0,0,7853276,0;
%    0,0,0,0,0,0,0,0,8326168,0,0,0;
%    0,0,0,0,0,0,0,0,8861129,0,0,0;
%    0,0,0,0,0,0,0,0,8315294,0,0,0;
%    0,0,0,0,0,0,0,0,0,1,0,0;
%    0,0,0,0,0,0,0,0,0,0,0,0;
%    0,0,0,0,0,0,0,0,0,0,0,7853276;
%    0,0,0,0,0,0,0,7853276,0,0,0,0,];
%  I = [0,1339000,1383000,1336000,1378000,1037000,1059000,1088000,1755000,0,0,0];
%[ CU,channel,user,mean_makespan,a ] = mainten(taskCU,CUtask, CULink,auxpreSucc,PCP,I,Scu,K,auxD,B );