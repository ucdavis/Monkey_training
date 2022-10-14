function [] = afix(cfg)
%afix Summary of this function goes here
%   Detailed explanation goes here

    % Open window
    [wp, wrect] = Screen('OpenWindow', cfg.screen_number, cfg.background_color, cfg.screen_rect);
    drawScreen(cfg, wp, []);

    %  kb stuff
    ListenChar(2); % disable kb input at matlab command window
    KbName('UnifyKeyNames');

    % Initialize eye tracker
    EyelinkInit(cfg.eyelink_dummymode);
    if (cfg.eyelink_dummymode == 0)
        fprintf('do eye tracker stuff here');
    end

    % juicer
    cclabInitReward(cfg.reward_type);

    [center_x_pix, center_y_pix] = RectCenter(wrect);

    fixpt_pos_pix = deg2pix(cfg.fixpt_pos_deg, cfg) + [center_x_pix, center_y_pix];
    
    bQuit = 0;
    state = "START";
    tStateStart = -1;
    while ~bQuit && state ~= "DONE"
    
        % Check kb each time 
        [keyIsDown, ~, keyCode] = KbCheck();
        
        % TODO kb handling
        if keyIsDown && keyCode(KbName('q'))
            state = "DONE";
        end

        % TODO eye tracker
        [ex, ey] = getEyePos(cfg, wp);
    
        tNow = GetSecs;
        switch(state)
            case "START"
                mylogger(cfg, "enter START\n");
                tStateStart = drawScreen(cfg, wp, fixpt_pos_pix);
                state = "WAIT_FOR_ACQ";
            case "WAIT_FOR_ACQ"
                if tNow - tStateStart > cfg.max_acquisition_time
                    mylogger(cfg, "WAIT_FOR_ACQ: FAIL\n");
                    tStateStart = drawScreen(cfg, wp, []);
                    state = "WAIT_ITI";
                elseif IsInRect(ex, ey, CenterRectOnPoint(cfg.fixation_window_rect, fixpt_pos_pix(1), fixpt_pos_pix(2)))
                    mylogger(cfg, "WAIT_FOR_ACQ: ACQ TARGET\n");
                    tStateStart = tNow;
                    state = "WAIT_FIX";
                end
            case "WAIT_FIX"
                if ~IsInRect(ex, ey, CenterRectOnPoint(cfg.fixation_window_rect, fixpt_pos_pix(1), fixpt_pos_pix(2)))
                    mylogger(cfg, "WAIT_FOR_FIX: FAIL\n");
                    tStateStart = drawScreen(cfg, wp, []);
                    state = "WAIT_ITI";
                elseif tNow - tStateStart > cfg.fixation_time
                    mylogger(cfg, "WAIT_FOR_FIX: success\n");
                    tStateStart = tNow;
                    state = "REWARD";
                end
            case "WAIT_ITI"
                if tNow-tStateStart > cfg.intertrial_time
                    tStateStart = tNow;
                    state = "START";
                end
            case "REWARD"
                cclabReward(cfg.reward_size, cfg.reward_number, cfg.reward_gap);
                tStateStart = tNow;
                state = "START";
            case "DONE"
                bQuit = true;
            otherwise
                error("Unhandled state %s\n", state);
        end                                 
    end

    ListenChar(0);
    sca;
end

function [ex, ey] = getEyePos(cfg, wp)
    if (cfg.eyelink_dummymode == 1)
        [ex, ey] = GetMouse(wp);
    else
        error('todo: getEyePos for real');
%         evt=Eyelink('NewestFloatSample');
%         x_eye=evt.gx(eye_used+1);
%         y_eye=evt.gy(eye_used+1);
    end
end

function [tflip] = drawScreen(cfg, wp, fixpt_xy)
    Screen('FillRect', wp, cfg.background_color);
    if ~isempty(fixpt_xy)
        Screen('FillOval', wp, cfg.fixation_color, CenterRectOnPoint(cfg.fixpt_rect, fixpt_xy(1), fixpt_xy(2)))
    end
    tflip = Screen('Flip', wp);
end
    
function [] = mylogger(cfg, str)
    if cfg.verbose
        fprintf(str);
    end
end
