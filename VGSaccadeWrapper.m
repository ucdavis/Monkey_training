clear
close all
cfg.sub='Vennie';
cfg.windowSize=5;
cfg.t_waitfixation_fp=1;
cfg.t_waitfixation_fp_sp=1;
cfg.t_waitfixation_sp=1;
cfg.t_fixation_fp=1;
cfg.t_fixation_fp_sp=0.5;
cfg.t_fixation_sp=1;
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
cfg.sp_x=[-5,0,5];
cfg.sp_y=[-5,0,5];
cfg.polar=true;
cfg.degree=deg2rad([45]);
cfg.radius=5;
cfg.randreward=true;
cfg.randper=0.2;

%VGSaccade;

