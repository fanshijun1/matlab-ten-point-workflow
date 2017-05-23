% cmmock=0;
% arrate=0.045;
% a=[];
% b=[];
% step=10/9;
% whmmmme(cmmock<100)
%   mmf(rem(cmmock*arrate,1)==0)
%    
%         a(1,end+1)=cmmock*arrate
%         cmmock=cmmock+step;
% %     end
% a=[];
% next_pommnt=1
% b=cemmmm(0,0);
% b{1,end+1}=[1,2]
% b{1,end+1}=[3,4]
% a=b{1,next_pommnt}
% a=[4,3,5];
% a(:,2)=[];
% b={[1,5],[3,2];[4,5],[6,7,8]};
% b{2,1}(1,2)==a(1,2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% mm=1;
% if(mm>0&&mm<=9)
%      mm=10;
% elseif (mm==10)
%                mm=12;
% else 
%                        mm=3;
% %       
%         
% end
%%%%%%%%%%%%%%plot函数%%%%%%%%%%%
% a=0:0.2*pi:2*pi;
% y1=sin(a);
% y2=cos(a);
% plot(a,y1);
% hold on;
% plot(a,y2,'--*r');
%%%%%%%%%%%%%%%%
% a=[1,2,3];
% b=[2,4,5];
% c=[6,7,3]
% plot(a,b,'r');
% hold on ;
% plot(a,c,'g');
%%%%%%%%%%%%%%%%%%%
% make=[];
% clock=1;
% temp_clock=[];
% for i=1:10
%         make(clock)=clock*clock;
%         temp_clock(clock)=clock;
%         clock=clock+1;
% end
% plot(temp_clock,make,'g');
%%%%%%%%%%%%
% a=[3,4,6,3,5]
% b=mean(a)
% b={[1,2],[2,4],[4,2],[1,2]};
% c=[1,2];
% d=ismember(b{1,1},c)
% any(ismember(b{1,1},c)==1)%判断是否含有某矩阵
%%%%%%%%%%%%
% a=[1,2,3,4;
%         4,3,8,7];
% b=[3,4];
% aaa=[1,2,3;
%         4,5,0;
%         0,0,0]
% c=aaa(find(aaa))
% b=mean(aaa(find(aaa)))
% e=max(max(aaa))
% [x,y]=find(aaa==max(max(aaa)))
% d=[x,y]
% V=[3,4,5;
%        2,5,0;
%        7,0,0];
%  
% T=cell(0,0);
% while(any(any(V))==1)
%                 [x,y]=find(V==max(max(V)));%找到V中最大值的二维位置
%                 T{1,end+1}=[x(1),y(1)];
%                 V(x(1),y(1))=0;                
% end
f(x)=x-2;
q(x)=2*x+1;
x=solve('f(x)-q(x)','x')