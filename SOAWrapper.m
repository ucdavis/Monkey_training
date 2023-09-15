clear
close all
warning('off')
cfg.sub='Vennie';
cfg.windowSize=1.4;
cfg.ScreenNumber=2;
cfg.t_waitfixation_fp=2;
cfg.t_waitfixation_sp=2;
cfg.t_fixation_fp=0.5;
cfg.t_keepfixation=0.6;
cfg.t_fixation_fp_sp=0.2;
cfg.t_fixation_sp=0.75;
cfg.numrep=1;
cfg.numrepsp=1;
cfg.ip_x=0;
cfg.ip_y=0;
cfg.fp_x=0;
cfg.fp_y=0;
cfg.fpr=0.2;
cfg.spr=0.2;
cfg.imgR=2;
cfg.imgPos=8;
cfg.reward=100;
cfg.t_trialend=1;
cfg.sp_x=[0];
cfg.sp_y=[0];
cfg.polar=true;
cfg.degree=deg2rad([0,45,90,135,180,225,270,315,360]);
cfg.radius=5;
cfg.randreward=true;
cfg.randper=0.8;
cfg.contrast=18;
% figure;
%                         set(gcf,'Position',[0 550 560 420]);
cfg.soa=[-600 -300 -100 -50 0 50 100 300 600];
%cfg.soa=[-1000 1000];

cfg.totalImage=50;
cfg.t_waitfixation_img=2;
cfg.t_fixation_img=0.5;
cfg.t_fixation_FTfp=0.5;
cfg.t_waitfixation_FTfp=2;
cfg.t_fixation_result=0.5;
cfg.t_fixation_sp=0.5;
cfg.randreward=true;
cfg.randper=0.2;
%VGSaccade;

