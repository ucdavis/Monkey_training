Screen('Preference', 'SkipSyncTests', 1);
    [window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
Screen('FillRect',window, [128 128 128]);
            Screen('FillOval',window,[0 255 255], [center(1)+x_fp, center(2)-y_fp, center(1)+x_fp, center(2)-y_fp],5);
            Screen('DrawingFinished',window);
            t_start_trial=Screen('Flip',window);