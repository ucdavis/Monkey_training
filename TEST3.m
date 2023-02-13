fp_color=[128 0 0];
Screen('Preference', 'SkipSyncTests', 1);
screenNumber=1;
[window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
EyelinkInit(0);
Screen('FillRect',window,[128 128 128]);
t_checkpoint=Screen('Flip',window);
KbName('UnifyKeyNames');
failOpen = Eyelink('OpenFile', 'test');

% Query keycodes:
esc=KbName('ESCAPE');% quit the program
t_checkpoint2=Screen('Flip',window);
test='test';
eye_used=0;
i=1;
j=1;
%%
try
    while true
        status_record(i)=Eyelink('StartRecording');

        status_mess(i)=Eyelink('Message','testtesttest');
        evt=Eyelink('NewestFloatSample');
        x_eye=evt.gx(eye_used+1);
        y_eye=evt.gy(eye_used+1);
        status_conn(i)=Eyelink('Isconnected');
        WaitSecs(1);
        Eyelink('StopRecording');
        WaitSecs(1);
        i=i+1;
        [keyIsDown, ~, keyCode]=KbCheck;

        if keyCode(esc)
            Eyelink('StopRecording');

            Eyelink('CloseFile');
            Screen('CloseAll');
        end



    end
catch exception
    msgText = getReport(exception);


    save('allfile.mat')
    Screen('CloseAll');
    ListenChar(1);
    Eyelink('ShutDown');
    % Restores the mouse cursor.
    ShowCursor;
end


