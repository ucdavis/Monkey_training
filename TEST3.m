fp_color=[128 0 0];
Screen('Preference', 'SkipSyncTests', 1);
screenNumber=1;
[window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
EyelinkInit(0);
Screen('FillRect',window,[128 128 128]);
t_checkpoint=Screen('Flip',window);
KbName('UnifyKeyNames');

% Query keycodes:
esc=KbName('ESCAPE');% quit the program
t_checkpoint2=Screen('Flip',window);
test='test';
eye_used=0;
Eyelink('StartRecording');
i=1;
j=1;
%%
try
    while true
        switch(test)
            case '1'
                [keyIsDown, ~, keyCode]=KbCheck;

                if (keyIsDown==1 && keyCode(esc))
                    disp('term')
                    Eyelink('StopRecording');
                    ShowCursor;
                    Screen('CloseAll');
                    ListenChar(1);
                    fprintf('Aborted.\n');
                    Eyelink('CloseFile');
                    Eyelink('ShutDown');

                    break;
                end
                try

                    status = Eyelink('IsConnected');

                    if status~=1
                        errorConnectStage=test;
                        errorConnectStatus=status;
                        break;
                    end

                    error=Eyelink('CheckRecording');
                catch
                    status = Eyelink('IsConnected');

                    errorRecordingStage=test;
                    errorRecordingStatus=status;
                    break;
                end

            case 'test'
                i=i+1;

                Eyelink('command','clear_screen %d', 0);
                Eyelink('Command', 'record_status_message "TRIAL"');

                Eyelink('command','draw_box %d %d %d %d 15', 884, 464, 1036,616);
                WaitSecs(1);

                try

                    status = Eyelink('IsConnected');

                    if status~=1
                        errorConnectStage=test;
                        errorConnectStatus=status;
                        errorConnectLoop=i;
                        break;
                    end

                    error=Eyelink('CheckRecording');
                catch
                    status = Eyelink('IsConnected');

                    errorRecordingStage=test;
                    errorRecordingStatus=status;
                    errorRecordingLoop=i;

                    break;
                end
                [keyIsDown, ~, keyCode]=KbCheck;


                if (keyIsDown==1 && keyCode(esc))
                    disp('term')
                    Eyelink('StopRecording');
                    ShowCursor;
                    Screen('CloseAll');
                    ListenChar(1);
                    fprintf('Aborted.\n');
                    Eyelink('CloseFile');
                    Eyelink('ShutDown');

                    break;
                end

                test='test2';

            case 'test2'
                j=j+1;
                Eyelink('Message', 'test');
                Screen('FillRect',window,[128 128 128]);
                t_checkpoint=Screen('Flip',window);
                evt=Eyelink('NewestFloatSample');
                x_eye=evt.gx(eye_used+1);
                y_eye=evt.gy(eye_used+1);
                Eyelink('Message', 'test');
                try

                    status = Eyelink('IsConnected');

                    if status~=1
                        errorConnectStage=test;
                        errorConnectStatus=status;
                        errorConnectLoop=j;

                        break;
                    end

                    error=Eyelink('CheckRecording');
                catch
                    status = Eyelink('IsConnected');

                    errorRecordingStage=test;
                    errorRecordingStatus=status;
                    errorRecordingLoop=i;

                    break;
                end

                [keyIsDown, ~, keyCode]=KbCheck;


                if (keyIsDown==1 && keyCode(esc))
                    disp('term')
                    Eyelink('StopRecording');
                    ShowCursor;
                    Screen('CloseAll');
                    ListenChar(1);
                    fprintf('Aborted.\n');
                    Eyelink('CloseFile');
                    Eyelink('ShutDown');

                    break;
                end
                test='test';

        end


    end
catch
    disp('error2')
end

disp('break');
Screen('CloseAll');
%%

% fp_color=[128 0 0];
% Screen('Preference', 'SkipSyncTests', 1);
% screenNumber=2;
% [window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
% EyelinkInit(0);
% Screen('FillRect',window,[128 128 128]);
% t_checkpoint=Screen('Flip',window);
%  Eyelink('command','clear_screen %d', 0);
%
% Screen('FillRect',window,[128 128 128]);
% t_checkpoint2=Screen('Flip',window);
% Screen('CloseAll');
%%
stage='1';
while stage>0
    switch(stage)
        case '1'
            disp(stage)
            try

                status = Eyelink('IsConnected');

                        if status~=0
                            errorConnectStage=1;
                            errorConnectStatus=status;
                            errorConnectTrial=1;
                            break;
                        end

                error=Eyelink('CheckRecording');
            catch
                status = Eyelink('IsConnected');

                errorRecordingStage=2;
                errorRecordingStatus=status;
                errorRecordingTrial=2;
                break;
            end
            disp('yes')
            a=1;
            stage='2';
        case '2'
            disp(stage)
            
    end
end
%%

try
    disp(1)
    while true
        disp(2)
         error=Eyelink('CheckRecording');
            if(error~=0)
                disp(3)
                break;
            end
    end
    while true
        disp(4)
         error=Eyelink('CheckRecording');
            if(error~=0)
                disp(5)
                break;
            end
            disp(6)
    end
catch
    disp(7)
        disp(8)
end
