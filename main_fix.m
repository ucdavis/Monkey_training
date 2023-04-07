clear
close all
cfg.sub='Vennie'; %sub name
cfg.window_size=4; % window size of accepting fixation
cfg.t_fixation=1; % time for holding fixation
cfg.numrep=1; % number of repeated trial for each condition
cfg.ip_x=0;
cfg.ip_y=0;
cfg.fp_x=[-5,0,5]; % x position of fp
cfg.fp_y=[-5,0,5]; % y position of fp
cfg.reward =250; % reward amount
cfg.fpr=0.2; % fp radius
cfg.t_trialend=1; % iti length
cfg.polar=false;
cfg.degree=deg2rad([0]);
cfg.radius=10;
cfg.randreward=true;
cfg.randper=0.8;
%FixTestV3(cfg);
%FixTestV3;