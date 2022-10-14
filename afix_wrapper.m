% initializations - per "rig"
cfg_screen_number = 0;
cfg.screen_rect = [1280 750 1680 1050];
cfg.screen_visible_mm = [80, 60];
cfg.screen_distance_mm = 200;
cfg.reward_type = 'n';
cfg.reward_size = 500;
cfg.reward_gap = 250;

% initializations - experimental parameters
cfg.background_color=[128, 128, 128];
cfg.fixation_color = [0, 0, 255];
cfg.output_folder='/Users/dan/Documents/MATLAB';
cfg.fixpt_diameter_deg = 0.5;
cfg.max_acquisition_time = 5.0;
cfg.fixation_time = 1.0;
cfg.intertrial_time = 1.0;
cfg.fixpt_pos_deg = [0, 0];


% computed after initializations

% screen resolution, in pixels
cfg.screen_resolution = [screen_rect(3)-screen_rect(1), screen_rect(4)-screen_rect(2)];

% used for unit conversions between pixels & degrees
cfg.ppdX = cfg.screen_resolution(1)/atan(0.5*cfg.screen_visible_mm(1)/cfg.screen_distance_mm)*pi/180;
cfg.ppdY = cfg.screen_resolution(2)/atan(0.5*cfg.screen_visible_mm(2)/cfg.screen_distance_mm)*pi/180;

% use this to draw a fixpt (with CenterRectAtPoint)
cfg.fixpt_rect = [0, 0, cfg.ppdX*cfg.fixpt_diameter, cfg.ppdY*cfg.fixpt_diameter];

% Use this to define a rect (using CenterRectAtPoint) to use with
% IsInRect() when testing eye position
cfg.fixation_window_rect = [0, 0, cfg.fixpt_diameter_deg * ppdX, cfg.fixpt_diameter_deg * ppdY];


afix(cfg);
