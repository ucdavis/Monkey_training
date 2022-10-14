function [] = afix(cfg)
%afix Summary of this function goes here
%   Detailed explanation goes here

    % Open window
    [wp, wrect] = Screen('OpenWindow', cfg.screen_number, cfg.background_color, cfg.screen_rect);
    [x0, y0]  = RectCenter(wrect);
    drawScreen(cfg, wp, 0);

    %  kb stuff
    ListenChar(2);  disable kb input at matlab command window
    KbName('UnifyKeyNames');

    % Initialize eye tracker
% TODO
bQuit = 1;
state = 'START';
tStateStart = -1;
while ~bQuit && state ~= 'DONE'
    
    % Check kb each time 
    [keyIsDown, ~, keyCode] = KbCheck();
    
    % TODO kb handling
    
    % TODO eye tracker
    %[ex, ey] = cclabGetEyePos();

    tNow = GetSecs;
    switch(state)
        case 'START'
            tStateStart = drawScreen(cfg, wp, 1);
            state = 'WAIT_FOR_ACQ';
        case 'WAIT_FOR_ACQ'
            if tNow - tStateStart > cfg.max_acquisition_time
                tStateStart = drawScreen(cfg, wp, 0);
                state = 'WAIT_ITI';
            elseif IsInRect(ex, ey, CenterRectOnPoint(cfg.fixation_window_rect, fixX, fixY))
                tStateStart = tNow;
                state = 'WAIT_FIX';
            end
        case 'WAIT_FIX'
            if ~IsInRect(ex, ey, CenterRectOnPoint(cfg.fixation_window_rect, fixX, fixY))
                tStateStart = drawScreen(cfg, wp, 0);
                state = 'WAIT_ITI';
            elseif tNow - tStateStart > cfg.fixation_time
                tStateStart = tNow;
                state = 'REWARD';
            end
        case 'WAIT_ITI'
            if tNow-tStateStart > cfg.intertrial_time
                tStateStart = tNow;
                state = 'START';
            end
    end
                
                    
end

end


function [tflip] = drawScreen(cfg, wp, fixpt_xy)
    Screen('FillRect', wp, cfg.background_color);
    if ~isempty(fixpt_xy)
        Screen('FillOval', wp, cfg.fixation_color, CenterRectOnPoint(cfg.fixpt_rect, fixpt_xy(1), fixpt_xy(2)))
    end
    tflip = Screen('Flip', wp);
end
    
