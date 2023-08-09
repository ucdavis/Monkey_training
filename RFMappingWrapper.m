clear
close all
warning('off')
%sub name
cfg.sub='Vennie';
% fixation point accept window size
cfg.windowSize=1.5;
cfg.ScreenNumber=1;
% Time allowed sub to start fix on fp
cfg.t_waitfixation_fp=2;
cfg.t_waitfixation_sp=2;
% Time required sub to fix on fp
cfg.t_fixation_fp=0.5;
cfg.t_keepfixation=0.6;
cfg.t_fixation_fp_sp=0.2;
cfg.t_fixation_sp=0.75;
cfg.numrep=1;
cfg.numrepsp=1;
cfg.ip_x=0;
cfg.ip_y=0;
% fixation point position
cfg.fp_x=0;
cfg.fp_y=0;
% fixation point raius
cfg.fpr=0.2;
cfg.imgR=3;
cfg.imgPos=5;
cfg.reward=150;
cfg.t_trialend=1;

cfg.polar=true;
cfg.degree=deg2rad([0,45,90,135,180,225,270,315,360]);
cfg.radius=1.2;
cfg.randreward=true;
cfg.randper=0.8;
cfg.contrast=18;

cfg.totalImage=50;
cfg.t_waitfixation_img=2;
cfg.t_fixation_img=0.5;
cfg.t_fixation_FTfp=0.5;
cfg.t_waitfixation_FTfp=2;
cfg.t_fixation_result=0.5;
cfg.t_fixation_sp=0.5;
cfg.randreward=true;
cfg.randper=0.2;
% Size of presented square size
cfg.squareSize=2.5;
%Number of square horizontally and vertically
 cfg.squareWidthDeg = 6;
    cfg.squareHeightDeg = 4;
cfg.t_hold_fixation_fp=0.5;
cfg.popout=true;
cfg.Natural=true;
cfg.setLocation=true;
cfg.LocationX=4;
cfg.LocationY=2;