clear
close all
warning('off')
cfg.sub='Vennie';
cfg.windowSize=4;
cfg.ScreenNumber=2;
cfg.t_waitfixation_fp=1;
cfg.t_waitfixation_sp=1;
cfg.t_fixation_fp=1;
cfg.t_fixation_fp_sp=0.3;
cfg.t_fixation_sp=0.5;
cfg.numrep=1;
cfg.numrepsp=1;
cfg.ip_x=0;
cfg.ip_y=0;
cfg.fp_x=0;
cfg.fp_y=0;
cfg.fpr=0.2;
cfg.spr=0.2;
cfg.reward=208;
cfg.t_trialend=1;
cfg.sp_x=[0];
cfg.sp_y=[0];
cfg.polar=true;
cfg.degree=deg2rad([0,45,90,135,180,225,270,315,360]);
cfg.radius=5;
cfg.randreward=true;
cfg.randper=0.8;


%VGSaccade;

