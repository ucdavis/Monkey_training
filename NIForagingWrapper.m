clear
close all
warning('off')
cfg.sub='Vennie';
cfg.windowSize=1.4;
cfg.probConditions=[0.2 0.4 0.8 1];
cfg.blockSize=50;
cfg.ScreenNumber=1;
cfg.t_fixation_result=0.3;
cfg.t_waitfixation_fp=2;
cfg.t_fixation_img=0.3;
cfg.t_waitfixation_FTfp=2;
cfg.t_waitfixation_img=2;
cfg.t_waitfixation_sp=2;
cfg.t_fixation_fp=0.3;
cfg.t_fixation_FTfp=0.3;
cfg.t_keepfixation=0.3;
cfg.t_fixation_fp_sp=0.2;
cfg.t_fixation_sp=0.3;
cfg.numrep=1;
cfg.numrepsp=1;
cfg.ip_x=0;
cfg.ip_y=0;
cfg.fp_x=0;
cfg.fp_y=0;
cfg.fpr=0.2;
cfg.spr=0.2;
cfg.reward=100;
cfg.t_trialend=1;
cfg.sp_x=[0];
cfg.sp_y=[0];
cfg.radius=10;
cfg.totalImage=2128;
cfg.imgR=1.5;
cfg.imgPos=8;
%VGSaccade;

