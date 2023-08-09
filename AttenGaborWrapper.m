 clear
close all 
cfg.gaborSize = 4;  % S
cfg.WaitTime=0.5;
warning('off')
cfg.sub='Vennie';
 cfg.windowSize=1.8;
 cfg.spwindowSize=3.5;
% cfg.windowSize=10;
% cfg.spwindowSize=10;
cfg.ScreenNumber=1;
cfg.t_waitfixation_fp=1;
cfg.t_waitfixation_sp=0.7;
cfg.t_fixation_fp=0.3;
cfg.t_fixation_sp=1;
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
cfg.degree=225;
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
%VGSaccade;

