
function [indifferencePointTT,indifferencePointNN,indifferencePointTN,indifferencePointNT]=SOAafter(Results)
% table1=load('1all.mat','Results');
% table2=load('2all.mat','Results');
% table3=load('3all.mat','Results');
%Concatenate the variable with the corresponding variable from the other .mat files
% Combined = vertcat(table1.Results, table2.Results);
% table=load('1all.mat','Results');

% Combined=table.Results;
Combined=Results;

%%
 %x1=[-1000 -800 -600 -400 -200 0 200 400 600 800 1000]/1000;
 x1=[-600 -300 -100 -50 0 50 100 300 600]/1000;
for i=1:size(x1,2)
    for j=1:4
y(i,j)=sum(Combined.choice==1&Combined.onsetImg==x1(i)&Combined.positionImg==(j-1)&Combined.TrialSuccess==1)/sum(Combined.onsetImg==x1(i)&Combined.positionImg ==(j-1)&Combined.TrialSuccess==1);
    end
end
figure;
for i=1:4
plot(x1,y(:,i))
hold on
end
legend('NN','TT','NT','TN')
ylabel('Left choice probability')
xlabel('SOA Time diff')
% ReactionTime=Results.choiceTime(Results.TrialSuccess==1)-Results.PutOnImg(Results.TrialSuccess==1);
ReactionTime=Combined.choiceTime-Combined.PutOnImg1;

for i=1:size(x1,2)
    for j=1:4
LReaction(i,j)=mean(ReactionTime(Combined.choice==1&Combined.onsetImg==x1(i)&Combined.positionImg==(j-1)&Combined.TrialSuccess==1));
RReaction(i,j)=mean(ReactionTime(Combined.choice==2&Combined.onsetImg==x1(i)&Combined.positionImg==(j-1)&Combined.TrialSuccess==1));
AReaction(i,j)=mean(ReactionTime(Combined.onsetImg==x1(i)&Combined.positionImg==(j-1)&Combined.TrialSuccess==1));
    end
end
ymax=max([max(LReaction),max(RReaction),max(AReaction)]);
ymin=min([min(LReaction),min(RReaction),min(AReaction)]);
filename1 = 'figure1.jpg';
saveas(gcf, filename1, 'jpg');

figure;
for i=1:4
plot(x1,LReaction(:,i))
hold on
end
legend('NN','TT','NT','TN')
title('left choice')
xlabel('SOA time diff')
ylabel('Reaction time in s')
ylim([ymin ymax])
xlim([x1(1) x1(end)])
filename2 = 'figure2.jpg';
saveas(gcf, filename2, 'jpg');

figure;
for i=1:4
plot(x1,RReaction(:,i))
hold on
end
legend('NN','TT','NT','TN')
title('right choice')
xlabel('SOA time diff')
ylabel('Reaction time in s')
ylim([ymin ymax])
xlim([x1(1) x1(end)])
filename3 = 'figure3.jpg';
saveas(gcf, filename3, 'jpg');

figure;
for i=1:4
plot(x1,AReaction(:,i))
hold on
end
legend('NN','TT','NT','TN')
title('All choice')
xlabel('SOA time diff')
ylabel('Reaction time in s')
ylim([ymin ymax])
xlim([x1(1) x1(end)])
filename4 = 'figure4.jpg';
saveas(gcf, filename4, 'jpg');

X=Combined.onsetImg((Combined.choice==1|Combined.choice==2)&Combined.positionImg==0);
Y=Combined.choice((Combined.choice==1|Combined.choice==2)&Combined.positionImg==0);
X1=Combined.onsetImg((Combined.choice==1|Combined.choice==2)&Combined.positionImg==1);
Y1=Combined.choice((Combined.choice==1|Combined.choice==2)&Combined.positionImg==1);
X2=Combined.onsetImg((Combined.choice==1|Combined.choice==2)&Combined.positionImg==2);
Y2=Combined.choice((Combined.choice==1|Combined.choice==2)&Combined.positionImg==2);
X3=Combined.onsetImg((Combined.choice==1|Combined.choice==2)&Combined.positionImg==3);
Y3=Combined.choice((Combined.choice==1|Combined.choice==2)&Combined.positionImg==3);
syms x
%x1=[-600 -300 -100 -50 0 50 100 300 600]/1000;
 %x1=[-1000 -800 -600 -400 -200 0 200 400 600 800 1000]/1000;

for i=1:size(x1,2)
    for j=1:4
y(i,j)=sum(Combined.choice==1&Combined.onsetImg==x1(i)&Combined.positionImg==(j-1)&Combined.TrialSuccess==1)/sum(Combined.onsetImg==x1(i)&Combined.positionImg ==(j-1)&Combined.TrialSuccess==1);
    end
end
[B,dev,stats]=mnrfit(X,Y,'Model','ordinal');
figure;
ezplot(1/(1+exp(-B(1)+B(2)*x)),x1)
hold on
% plot(x1,1-y(:,1),'ro-','MarkerFaceColor','r')
% hold on
% legend('NN-fit','NN-real')
f1=1/(1+exp(-B(1)+B(2)*x));
indifferencePointNN = solve(f1 == 0.5,x);
scatter(double(subs(indifferencePointNN)),0.5, 'filled');

[B,dev,stats]=mnrfit(X1,Y1,'Model','ordinal');

ezplot(1/(1+exp(-B(1)+B(2)*x)),x1)
hold on
% plot(x1,1-y(:,1),'ro-','MarkerFaceColor','r')
% hold on
% legend('NN-fit','NN-real')
legend('NN-fit','','TT-fit')
f1=1/(1+exp(-B(1)+B(2)*x));
indifferencePointTT = solve(f1 == 0.5,x);
scatter(double(subs(indifferencePointTT)),0.5, 'filled');
filename5 = 'figure5.jpg';
saveas(gcf, filename5, 'jpg');


[B,dev,stats]=mnrfit(X2,Y2,'Model','ordinal');
figure;
ezplot(1/(1+exp(-B(1)+B(2)*x)),x1)
hold on
% plot(x1,1-y(:,1),'ro-','MarkerFaceColor','r')
% hold on
% legend('NN-fit','NN-real')
f1=1/(1+exp(-B(1)+B(2)*x));
indifferencePointNT = solve(f1 == 0.5,x);
scatter(double(subs(indifferencePointNT)),0.5, 'filled');

[B,dev,stats]=mnrfit(X3,Y3,'Model','ordinal');

ezplot(1/(1+exp(-B(1)+B(2)*x)),x1)
hold on
% plot(x1,1-y(:,1),'ro-','MarkerFaceColor','r')
% hold on
% legend('NN-fit','NN-real')
legend('NT-fit','','TN-fit')
f1=1/(1+exp(-B(1)+B(2)*x));
indifferencePointTN = solve(f1 == 0.5,x);
scatter(double(subs(indifferencePointTN)),0.5, 'filled');

filename6 = 'figure6.jpg';
saveas(gcf, filename6, 'jpg');

end