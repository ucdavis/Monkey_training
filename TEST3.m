    [window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
   
Screen('Rect',window);

Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1), center(2), center(1), center(2)],5);
                Screen('FillOval',window,fp_color, [center(1)+1, center(2)-1, center(1)+1, center(2)-1],5);
                                Screen('DrawingFinished',window);


%                 Screen('DrawingFinished',window);
                t_start_trial=Screen('Flip',window);
                                    a1=t_start_trial;
%                                     Eyelink('command','clear_screen %d', 0);
%                 Eyelink('command','draw_box %d %d %d %d 15', box1, box2, box3,box4);
        checkkeys;

                            status= Eyelink('IsConnected');
                            

                                    Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)+1, center(2)-1, center(1)+1, center(2)-1],5);
                                Screen('DrawingFinished',window);


                t_start_trial=Screen('Flip',window);
                a2=t_start_trial;
                Screen('CloseAll');