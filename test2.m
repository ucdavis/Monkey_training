[window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
 Screen('FillRect',window, [128 128 128]);
                Screen('DrawingFinished',window);
                Screen('Flip',window);
