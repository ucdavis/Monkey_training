table1=load('2all.mat','Results');
table2=load('3all.mat','Results');
table3=load('4all.mat','Results');
% Concatenate the variable with the corresponding variable from the other .mat files
Combined = vertcat(table1.Results, table2.Results,table3.Results);
x1=[-800 -600 -400 -200 0 200 400 600 800]/1000;

for i=1:9
    for j=1:4
y(i,j)=sum(Combined.choice==1&Combined.onsetImg==x1(i)&Combined.positionImg==(j-1)&Combined.TrialSuccess==1)/sum(Combined.onsetImg==x1(i)&Combined.positionImg ==(j-1)&Combined.TrialSuccess==1);
    end
end
figure;
for i=1:4
plot(-x1,y(:,i))
hold on
end
legend('NN','TT','NT','TN')
xlabel('Left choice probability')
