clear
close all
warning('off')
cfg.sub='Vennie';
 cfg.windowSize=4;
 cfg.spwindowSize=6;
% cfg.windowSize=10;
% cfg.spwindowSize=10;
cfg.ScreenNumber=1;
cfg.t_waitfixation_fp=10;
cfg.t_waitfixation_sp=10;
cfg.t_fixation_fp=0.5;
cfg.t_fixation_fp_sp=0.3;
cfg.t_keepfixation=0.3;
cfg.t_fixation_sp=0.3;
cfg.numrep=1;
cfg.numrepsp=1;
cfg.ip_x=0;
cfg.ip_y=0;
cfg.fp_x=0;
cfg.fp_y=0;
cfg.fpr=0.2;
cfg.spr=0.2;
cfg.reward=200;
cfg.t_trialend=1;
cfg.sp_x=[0];
cfg.sp_y=[0];
cfg.polar=true;
cfg.degree=deg2rad(0:45:315);
cfg.degree2=deg2rad(0:90:270);
cfg.degree3=deg2rad(0:180:180);

cfg.radius=7;% saccade distance from center (in X * ppd)
cfg.randreward=true;
cfg.randper=0.8;
cfg.contrast=0;
cfg.contrasttarget=1000;
figure;
                        set(gcf,'Position',[0 550 560 420]);
cfg.soa=[-800 -600 -400 -200 0 200 400 600 800];
cfg.Skip=true;
cfg.SkipTrialNum=10;
cfg.prob=[0.25 0.5 0.75 1];
%VGSaccade;

