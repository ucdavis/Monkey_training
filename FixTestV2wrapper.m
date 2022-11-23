addpath('E:\work\git\Monkey_training')
% initializations - per "rig"
cfg.screen_number = 0;

% mac
% cfg.screen_rect = [1280 750 1680 1050];
% linux, 
cfg.screen_rect = [0 0 1920 1080];

% this is probably linked to the screen rect, but not now
cfg.screen_visible_mm = [700, 400];
cfg.screen_distance_mm = 780;

% Juicer
cfg.reward_type = 'n';
cfg.reward_size = 500;
cfg.reward_number = 1;
cfg.reward_gap = 250;

% eye tracker config (TODO)
cfg.eyelink_dummymode = 1;


% initializations - experimental parameters
cfg.background_color=[128, 128, 128];
cfg.fixation_color = [0, 0, 255];
cfg.output_folder='/Users/dan/Documents/MATLAB';
cfg.fixpt_diameter_deg = 0.5;
cfg.max_acquisition_time = 5.0;
cfg.fixation_time = 1.0;
cfg.intertrial_time = 1.0;
cfg.fixpt_pos_deg = [0, 0];

% other
cfg.verbose = 1;


% computed after initializations

% screen resolution, in pixels
cfg.screen_resolution = [cfg.screen_rect(3)-cfg.screen_rect(1), cfg.screen_rect(4)-cfg.screen_rect(2)];

% used for unit conversions between pixels & degrees
cfg.ppdX = cfg.screen_resolution(1)/atan(0.5*cfg.screen_visible_mm(1)/cfg.screen_distance_mm)*pi/180;
cfg.ppdY = cfg.screen_resolution(2)/atan(0.5*cfg.screen_visible_mm(2)/cfg.screen_distance_mm)*pi/180;

% use this to draw a fixpt (with CenterRectAtPoint)
cfg.fixpt_rect = [0, 0, cfg.ppdX*cfg.fixpt_diameter_deg, cfg.ppdY*cfg.fixpt_diameter_deg];

% Use this to define a rect (using CenterRectAtPoint) to use with
% IsInRect() when testing eye position
cfg.fixation_window_rect = [0, 0, cfg.fixpt_diameter_deg * cfg.ppdX, cfg.fixpt_diameter_deg * cfg.ppdY];


deg2pix([1 1],cfg);