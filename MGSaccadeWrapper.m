clear
close all
warning('off')
cfg.sub='Vennie';
% Window size for center fixation
 cfg.windowSize=4;
 %Window size for saccade point fixation
 cfg.spwindowSize=6;
% Change the number to 1/2 if the psychotoolbox screen is not on the main
% screen
cfg.ScreenNumber=1;
% Wait time for subject to fix on fixation point
cfg.t_waitfixation_fp=2;
% Wait time for subject to fix on saccade point
cfg.t_waitfixation_sp=2;
% Time required to fix for fixation point
cfg.t_fixation_fp=0.5;
% Time required to hold fix for fixation point when both point are shown
cfg.t_fixation_fp_sp=0.3;
% Time required to hold fix for fixation point after saccade point is off
cfg.t_keepfixation=0.5;
% Time required to fix on saccade point
cfg.t_fixation_sp=0.3;
cfg.numrep=1;
cfg.numrepsp=1;
% Add on position parameter
cfg.ip_x=0;
cfg.ip_y=0;
% Place of fixation point
cfg.fp_x=0;
cfg.fp_y=0;
% fixation point radius
cfg.fpr=0.2;
% Saccade point radius
cfg.spr=0.2;
% Reward size
cfg.reward=240;
% ITI duration
cfg.t_trialend=1;
% If non-polar, coordinates of saccade point
cfg.sp_x=[0];
cfg.sp_y=[0];
% Polar or Cartesian coordinates
cfg.polar=true;
% Degree preset
cfg.degree=deg2rad(0:45:315);
cfg.degree2=deg2rad(0:90:270);
cfg.degree3=deg2rad(0:180:180);
% Eccentricity of saccade point
cfg.radius=7;% saccade distance from center (in X * ppd)
% Random double reward
cfg.randreward=true;
% Chance of double reward
cfg.randper=0.8;
% Contrast of saccade point after it disappears, set t
cfg.contrast=0;
cfg.contrasttarget=1000;
figure;
                        set(gcf,'Position',[0 550 560 420]);
cfg.soa=[-800 -600 -400 -200 0 200 400 600 800];
cfg.Skip=true;
cfg.SkipTrialNum=10;
cfg.prob=[0.25 0.5 0.75 1];
%VGSaccade;

