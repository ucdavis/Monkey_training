function SOA_test

try
    %setupDIO;
 %setupDIO;
    addpath('E:\work\git\cclab-matlab-tools');
    path='E:\Eyelink_test_ground_Wenqing\Data';
    Screen('Preference', 'SkipSyncTests', 1);
    %fileName='/Users/mzirnsak/Desktop/flicker1.mat';
    %addpath('/home/cclab/work/Psycho_RandomWalk');
    Screen('Preference', 'SkipSyncTests', 1);

    x_res=1920;
    y_res=1080;
    j=0;

    ppcm=40; %Number of pixels per centimeter
    obs_dist = 30;   % viewing distance (cm)
    %ppd=50; %Number of pixels per degree of visual angle
    ppd=2*obs_dist*ppcm*tan(pi/360);

    fp_color=[0 0 255];

    single_pos=0;
    pos=1;

    v_x_fp=[0 round(-10*ppd),round(10*ppd)];
    v_y_fp=[0, 0,0];
    off_time=[-0.12  -0.08, -0.04, 0,0.04,0.08 -0.12];

    fpr=round(ppd*0.5); %radius of fixation point

    window_fix=round(5*ppd);

    t_waitforfixation=1.0;
    t_waitforchoice=1.0;
    t_fixation0=0.4;
    t_choice0=0.4;
    t_trialend=1.0;



    t1=0.200;

    %mon_width   = 48;           % horizontal dimension of viewable screen (cm)
    %mon_height  = 26.5;           % vertical dimension of viewable screem (cm)

    screenNumber = [];

    % Switch KbName into unified mode: It will use the names of the OS-X
    % platform on all platforms in order to make this script portable:
    KbName('UnifyKeyNames');

    % Query keycodes:
    esc=KbName('ESCAPE');
    space=KbName('space');
    left=KbName('LeftArrow');
    right=KbName('RightArrow');
    up=KbName('UpArrow');
    down=KbName('DownArrow');
    coolkey=KbName('return');

    [success] = cclabInitReward("j")

    % EDF file: 1-8 characters plus .edf extension
%     edfFile0=input('EDF file name:','s');
%     edfFile=strcat(edfFile0,'.edf');
% 


    dummymode = 0;

    % Optional: Set IP address of eyelink tracker computer to connect to.
    % Call this before initializing an EyeLink connection if you want to use a non-default IP address for the Host PC.
    %Eyelink('SetAddress', '10.10.10.240');

    EyelinkInit(dummymode); % Initialize EyeLink connection
    status = Eyelink('IsConnected');
    if status < 1 % If EyeLink not connected
        dummymode = 1;
    end
    % Open dialog box for EyeLink Data file name entry. File name up to 8 characters
    prompt = {'Enter EDF file name (up to 8 characters)'};
    dlg_title = 'Create EDF file';
    def = {'demo'}; % Create a default edf file name
    answer = inputdlg(prompt, dlg_title, 1, def); % Prompt for new EDF file name
    % Print some text in Matlab's Command Window if a file name has not been entered
    if  isempty(answer)
        fprintf('Session cancelled by user\n')
        cleanup; % Abort experiment (see cleanup function below)
        return
    end
    edfFile = answer{1}; % Save file name to a variable
    % Print some text in Matlab's Command Window if file name is longer than 8 characters
    if length(edfFile) > 8
        fprintf('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)\n');
        cleanup; % Abort experiment (see cleanup function below)
        return
    end

    % Open an EDF file and name it
    failOpen = Eyelink('OpenFile', edfFile);
    if failOpen ~= 0 % Abort if it fails to open
        fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
        cleanup; %see cleanup function below
        return
    end

    % Get EyeLink tracker and software version
    % <ver> returns 0 if not connected
    % <versionstring> returns 'EYELINK I', 'EYELINK II x.xx', 'EYELINK CL x.xx' where 'x.xx' is the software version
    ELsoftwareVersion = 0; % Default EyeLink version in dummy mode
    [ver, versionstring] = Eyelink('GetTrackerVersion');
    if dummymode == 0 % If connected to EyeLink
        % Extract software version number.
        [r1 vnumcell] = regexp(versionstring,'.*?(\d)\.\d*?','Match','Tokens'); % Extract EL version before decimal point
        ELsoftwareVersion = str2double(vnumcell{1}{1}); % Returns 1 for EyeLink I, 2 for EyeLink II, 3/4 for EyeLink 1K, 5 for EyeLink 1KPlus, 6 for Portable Duo
        % Print some text in Matlab's Command Window
        fprintf('Running experiment on %s version %d\n', versionstring, ver );
    end
    % Add a line of text in the EDF file to identify the current experimemt name and session. This is optional.
    % If your text starts with "RECORDED BY " it will be available in DataViewer's Inspector window by clicking
    % the EDF session node in the top panel and looking for the "Recorded By:" field in the bottom panel of the Inspector.
    preambleText = sprintf('RECORDED BY Psychtoolbox demo %s session name: %s', mfilename, edfFile);
    Eyelink('Command', 'add_file_preamble_text "%s"', preambleText);


    % This script calls Psychtoolbox commands available only in OpenGL-based
    % versions of the Psychtoolbox. (So far, the OS X Psychtoolbox is the
    % only OpenGL-base Psychtoolbox.)  The Psychtoolbox command AssertPsychOpenGL will issue
    % an error message if someone tries to execute this script on a computer without
    % an OpenGL Psychtoolbox
    AssertOpenGL;

    %% STEP 2: OPEN GRAPHICS WINDOW

    % Open experiment graphics on the specified screen
    if isempty(screenNumber)
        screenNumber = max(Screen('Screens')); % Use default screen if none specified
    end

    [w, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
    [center(1), center(2)] = RectCenter(rect);
    Screen('Flip', w);
    % Return width and height of the graphics window/screen in pixels
    [width, height] = Screen('WindowSize', w);
    
    %     % Find the color values which correspond to white and black.  Though on OS
    %     % X we currently only support true color and thus, for scalar color
    %     % arguments,
    %     % black is always 0 and white 255, this rule is not true on other platforms will
    %     % not remain true on OS X after we add other color depth modes.
    %     white=WhiteIndex(screenNumber);
    %     black=BlackIndex(screenNumber);
    %     gray=(white+black)/2;
    %     if round(gray)==white
    %         gray=black;
    %     end
    %     inc=white-gray;



    %     % Open a double buffered fullscreen window and draw a gray background
    %     % to front and back buffers:
    %     [w, rect]=Screen('OpenWindow',screenNumber, 0,[],[],2,[],4);
    %     [center(1), center(2)] = RectCenter(rect);
    %     [width, height]=Screen('WindowSize', screenNumber);
    %
    %
    %     % do eyelink stuff
    %     el=EyelinkInitDefaults(w);

    %% STEP 3: SELECT AVAILABLE SAMPLE/EVENT DATA
    % See EyeLinkProgrammers Guide manual > Useful EyeLink Commands > File Data Control & Link Data Control

    % Select which events are saved in the EDF file. Include everything just in case
    Eyelink('Command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    % Select which events are available online for gaze-contingent experiments. Include everything just in case
    Eyelink('Command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,BUTTON,FIXUPDATE,INPUT');
    % Select which sample data is saved in EDF file or available online. Include everything just in case
    if ELsoftwareVersion > 3  % Check tracker version and include 'HTARGET' to save head target sticker data for supported eye trackers
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,HTARGET,GAZERES,BUTTON,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,HTARGET,STATUS,INPUT');
    else
        Eyelink('Command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,RAW,AREA,GAZERES,BUTTON,STATUS,INPUT');
        Eyelink('Command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT');
    end

    Eyelink('Command','screen_phys_coords = -240.0 132.5 240.0 -132.5 '); % this is the size of the default screen Dell 2005FPW
    % distance in mm from the center of the screen to [left top right bottom]
    % edge of screen
    Eyelink('Command', 'screen_distance = 300') %  Need to get from experimenter distance from center of eye to the center of the screen
    % we need to measure this and get the proper number


    %% STEP 4: SET CALIBRATION SCREEN COLOURS; PROVIDE WINDOW SIZE TO EYELINK HOST & DATAVIEWER; SET CALIBRATION PARAMETERS; CALIBRATE

    % Provide EyeLink with some defaults, which are returned in the structure "el".
    el = EyelinkInitDefaults(w);
    % set calibration/validation/drift-check(or drift-correct) size as well as background and target colors.
    % It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
    % pupil size changes (which can cause a drift in the eye movement data)
    el.calibrationtargetsize = 2;% Outer target size as percentage of the screen
    el.calibrationtargetwidth = 0.7;% Inner target size as percentage of the screen
    el.backgroundcolour = [128 128 128];% RGB grey
    el.calibrationtargetcolour = [0 0 0];% RGB black
    % set "Camera Setup" instructions text colour so it is different from background colour
    el.msgfontcolour = [0 0 0];% RGB black
    % You must call this function to apply the changes made to the el structure above
    EyelinkUpdateDefaults(el);

    % Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width-1, height-1);
    % Set number of calibration/validation dots and spread: horizontal-only(H) or horizontal-vertical(HV) as H3, HV3, HV5, HV9 or HV13
    Eyelink('Command', 'calibration_type = HV5'); % horizontal-vertical 9-points
    % Allow a supported EyeLink Host PC button box to accept calibration or drift-check/correction targets via button 5
    Eyelink('Command', 'button_function 5 "accept_target_fixation"');
    % Hide mouse cursor
    % Start listening for keyboard input. Suppress keypresses to Matlab windows.
    ListenChar(-1);
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing

    % Put EyeLink Host PC in Camera Setup mode for participant setup/calibration
    EyelinkDoTrackerSetup(el);




    % Calibrate the eye tracker
    % setup the proper calibration foreground and background colors
    % el.backgroundcolour = 0;
    % el.foregroundcolour = 255;
    % EyelinkDoTrackerSetup(el,'c');

    % Validate the eye tracker calibration
    %EyelinkDoTrackerSetup(el,'v');

    
    KbWait;

    Screen('Rect',w);
    slack=Screen('GetFlipInterval', w)/2;

    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

    Screen('FillRect',w, el.backgroundcolour);
    t_start_trial=Screen('Flip', w);
    color=el.backgroundcolour;
    step=10;

    pause=0;
    cool=0;

    i=1;

    eye_used = el.LEFT_EYE;




    %     x_eye=1000;
    %     y_eye=1000;

    while i>0 && j<10
        Eyelink( 'Message', 'Trialstart');
        %Start recording
        Eyelink('StartRecording');
        Eyelink('Command', 'record_status_message ''TRIAL %d''', i);

        t_fixation=t_fixation0+rand(1)*0.1;
        t_choice=t_choice0+rand(1)*0.1;

        Eyelink( 'Message', 'Fixation_time %ld', round(t_fixation0*1000) );
        Eyelink( 'Message', 'ChoiceFixation_time %ld', round( t_choice0*1000 ));


        x_fp=v_x_fp(1);
        y_fp=v_y_fp(1);

        %     Eyelink( 'Message', 'FPX %d', x_fp);
        %     Eyelink( 'Message', 'FPY %d', y_fp);

        offtime=off_time(randi(7));    % Onset difference between left and right
        Eyelink('Message','OnsetDif %d', offtime*1000);


        Eyelink('command','clear_screen %d', 0);
        Eyelink('command','draw_box %d %d %d %d 15', round(center(1)+x_fp-(window_fix/2)), round(center(2)-y_fp-(window_fix/2)), round(center(1)+x_fp+(window_fix/2)),round(center(2)-y_fp+(window_fix/2)));


        fix=0;
        choice=0;
        reward=0;





        %START WAIT FOR FIXATION
        t_start=GetSecs;

        Eyelink('Message', 'Waitfix');

        while (fix==0 && ((GetSecs)-t_start)<t_waitforfixation),

            % Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end


            Screen('FillRect',w, el.backgroundcolour);
            Screen('DrawingFinished', w);
            t_start_trial=Screen('Flip', w, t_start_trial + t1 - slack);

            Screen('FillRect',w, el.backgroundcolour);
            Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp]);
            Screen('DrawingFinished', w);
            t_start_trial=Screen('Flip', w, t_start_trial + t1 - slack);

            evt=Eyelink('NewestFloatSample');
            x_eye=evt.gx(eye_used+1);
            y_eye=evt.gy(eye_used+1);

            if ((x_eye >= (center(1)+x_fp-(window_fix/2)))&&(x_eye <= (center(1)+x_fp+(window_fix/2)))&&(y_eye >= (center(2)-y_fp-(window_fix/2)))&&(y_eye <= (center(2)-y_fp+(window_fix/2))))
                fix=1;
            end


            [keyIsDown, secs, keyCode]=KbCheck;
%             if keyIsDown==1
%                 [x_eye,y_eye,pause,cool]=checkkeys(keyIsDown,keyCode,pause,cool,x_eye,y_eye,center,x_fp,y_fp);
%             end


        end
        %END WAIT FOR FIXATION



        %START FIXATION
        t_start=GetSecs;

        Eyelink('Message', 'Fixation In');

        while (fix==1 && ((GetSecs)-t_start)<t_fixation),

            %Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end

            evt=Eyelink('NewestFloatSample');
            x_eye=evt.gx(eye_used+1);
            y_eye=evt.gy(eye_used+1);

            if not((x_eye >= (center(1)+x_fp-(window_fix/2)))&&(x_eye <= (center(1)+x_fp+(window_fix/2)))&&(y_eye >= (center(2)-y_fp-(window_fix/2)))&&(y_eye <= (center(2)-y_fp+(window_fix/2))))
                fix=0;
            end

            Screen('FillRect',w, el.backgroundcolour);
            Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp]);
            Screen('DrawingFinished', w);
            t_start_trial=Screen('Flip', w, t_start_trial + t1 - slack);

            [keyIsDown, secs, keyCode]=KbCheck;
%             if keyIsDown==1
%                 [x_eye,y_eye,pause,cool]=checkkeys(keyIsDown,keyCode,pause,cool,x_eye,y_eye,center,x_fp,y_fp);
%             end
        end
        %END FIXATION

        %Choose between two targets
        if(fix==1)

            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end

            x_fp1=v_x_fp(2);
            y_fp1=v_y_fp(2);

            x_fp2=v_x_fp(3);
            y_fp2=v_y_fp(3);

            Eyelink('command','draw_box %d %d %d %d 15', round(center(1)+x_fp1-(window_fix/2)), round(center(2)-y_fp1-(window_fix/2)), round(center(1)+x_fp1+(window_fix/2)),round(center(2)-y_fp1+(window_fix/2)));
            Eyelink('command','draw_box %d %d %d %d 15', round(center(1)+x_fp2-(window_fix/2)), round(center(2)-y_fp2-(window_fix/2)), round(center(1)+x_fp2+(window_fix/2)),round(center(2)-y_fp2+(window_fix/2)));


            if (offtime<0)
                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp2, center(2)-fpr-y_fp2, center(1)+fpr+x_fp2, center(2)+fpr-y_fp2]);
                Screen('DrawingFinished', w);
                t_start_trial=Screen('Flip', w);
                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp1, center(2)-fpr-y_fp1, center(1)+fpr+x_fp1, center(2)+fpr-y_fp1]);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp2, center(2)-fpr-y_fp2, center(1)+fpr+x_fp2, center(2)+fpr-y_fp2]);
                t_start_trial=Screen('Flip', w, t_start_trial + abs(offtime) - slack);

            elseif (offtime==0)
                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp1, center(2)-fpr-y_fp1, center(1)+fpr+x_fp1, center(2)+fpr-y_fp1]);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp2, center(2)-fpr-y_fp2, center(1)+fpr+x_fp2, center(2)+fpr-y_fp2]);

                Screen('DrawingFinished', w);
                t_start_trial=Screen('Flip', w);

            elseif (offtime>0)
                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp1, center(2)-fpr-y_fp1, center(1)+fpr+x_fp1, center(2)+fpr-y_fp1]);
                Screen('DrawingFinished', w);
                t_start_trial=Screen('Flip', w);
                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp1, center(2)-fpr-y_fp1, center(1)+fpr+x_fp1, center(2)+fpr-y_fp1]);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp2, center(2)-fpr-y_fp2, center(1)+fpr+x_fp2, center(2)+fpr-y_fp2]);
                t_start_trial=Screen('Flip', w, t_start_trial + abs(offtime) - slack);
            end
            t_start=GetSecs;
            Eyelink('Message', 'Loctarget');


            while (choice==0 && ((GetSecs)-t_start)< t_waitforchoice)

                %Check recording status, stop display if error
                error=Eyelink('CheckRecording');
                if(error~=0)
                    break;
                end

                evt=Eyelink('NewestFloatSample');
                x_eye=evt.gx(eye_used+1);
                y_eye=evt.gy(eye_used+1);



                if ((x_eye >= (center(1)+x_fp1-(window_fix/2)))&&(x_eye <= (center(1)+x_fp1+(window_fix/2)))&&(y_eye >= (center(2)-y_fp1-(window_fix/2)))&&(y_eye <= (center(2)-y_fp1+(window_fix/2))))
                    choice=1;
                end
                if   ((x_eye >= (center(1)+x_fp2-(window_fix/2)))&&(x_eye <= (center(1)+x_fp2+(window_fix/2)))&&(y_eye >= (center(2)-y_fp2-(window_fix/2)))&&(y_eye <= (center(2)-y_fp2+(window_fix/2))))
                    choice=2;
                end
            end


            disp('Choice');
            j=j+1;
            Eyelink('Message', 'Choice %d',choice);

            if choice ==1
                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp1, center(2)-fpr-y_fp1, center(1)+fpr+x_fp1, center(2)+fpr-y_fp1]);
                Screen('DrawingFinished', w);
                t_start_trial=Screen('Flip', w);
            elseif choice ==2

                Screen('FillRect',w, el.backgroundcolour);
                Screen('FillOval',w,fp_color, [center(1)-fpr+x_fp2, center(2)-fpr-y_fp2, center(1)+fpr+x_fp2, center(2)+fpr-y_fp2]);
                Screen('DrawingFinished', w);
                t_start_trial=Screen('Flip', w);
            end

            t_start=GetSecs;
            choice2 =choice;
            while (choice~=0 && choice2 ==choice &&((GetSecs)-t_start)<t_choice),


                evt=Eyelink('NewestFloatSample');
                x_eye=evt.gx(eye_used+1);
                y_eye=evt.gy(eye_used+1);

                choice2=0;
                if ((x_eye >= (center(1)+x_fp1-(window_fix/2)))&&(x_eye <= (center(1)+x_fp1+(window_fix/2)))&&(y_eye >= (center(2)-y_fp1-(window_fix/2)))&&(y_eye <= (center(2)-y_fp1+(window_fix/2))))
                    choice2=1;
                end
                if   ((x_eye >= (center(1)+x_fp2-(window_fix/2)))&&(x_eye <= (center(1)+x_fp2+(window_fix/2)))&&(y_eye >= (center(2)-y_fp2-(window_fix/2)))&&(y_eye <= (center(2)-y_fp2+(window_fix/2))))
                    choice2=2;
                end

                [keyIsDown, secs, keyCode]=KbCheck;
%                 if keyIsDown==1
%                     [x_eye,y_eye,pause,cool]=checkkeys(keyIsDown,keyCode,pause,cool,x_eye,y_eye,center,x_fp,y_fp);
%                 end

            end

            Screen('FillRect',w, el.backgroundcolour);
            Screen('DrawingFinished', w);
            t_start_trial=Screen('Flip', w);


            if ( choice2==choice &&  choice~=0 & fix==1)
                %                giveJuice;
                reward=1;
            end

        end
        fix=0;
        choice=0;
        Eyelink( 'Message', 'Reward %d', reward);
        Eyelink( 'Message', 'Cool%d', cool);
        Eyelink('command','clear_screen %d', 0);


        Screen('FillRect',w, el.backgroundcolour);
        Screen('DrawingFinished', w);
        t_start_trial=Screen('Flip', w);
        %START TRIAL END
        while ((GetSecs)-t_start)<t_trialend,
            %Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end

            [keyIsDown, secs, keyCode]=KbCheck;
%             if keyIsDown==1
%                 [x_eye,y_eye,pause,cool]=checkkeys(keyIsDown,keyCode,pause,cool,x_eye,y_eye,center,x_fp,y_fp);
%             end


            if (keyIsDown==1 && keyCode(esc))
                % Abort:
                ShowCursor;
                Screen('CloseAll');
                ListenChar(1);
                fprintf('Aborted.\n');
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                % download data file
                cd(path)
                try
                    fprintf('Receiving data file ''%s''\n', edfFile );
                    status=Eyelink('ReceiveFile');
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2==exist(edfFile, 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                    end
                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFile );
                end
                Eyelink('ShutDown');
                return ;
            end;
        end
        %STOP TRIAL END

        Eyelink('Message', 'Trialend');

        %Stop recording
        Eyelink('StopRecording');


        %START PAUSE

        if (pause==1)
            Screen('FillRect',w, black);
            Screen('DrawingFinished', w);
            Screen('Flip', w);
        end
        while (pause>0),

            %Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end

            [keyIsDown, secs, keyCode]=KbCheck;
%             if keyIsDown==1
%                 [x_eye,y_eye,pause,cool]=checkkeys(keyIsDown,keyCode,pause,cool,x_eye,y_eye,center,x_fp,y_fp);
%             end



            if (keyIsDown==1 && keyCode(esc))
                ShowCursor;
                Screen('CloseAll');
                ListenChar(1);
                fprintf('Aborted.\n');
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                % download data file
                cd(path)
                try
                    fprintf('Receiving data file ''%s''\n', edfFile );
                    status=Eyelink('ReceiveFile');
                    if status > 0
                        fprintf('ReceiveFile status %d\n', status);
                    end
                    if 2==exist(edfFile, 'file')
                        fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
                    end
                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFile );
                end
                Eyelink('ShutDown');
                return ;
            end;
        end
        %END PAUSE

        i=i+1;

    end


    Eyelink('CloseFile');
    % download data file
    cd(path)
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
    end
    Eyelink('ShutDown');

    ShowCursor;
    Screen('CloseAll');
    ListenChar(1);
    fprintf('Done.\n');
    return;



catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    ListenChar(1);
    Eyelink('ShutDown');
    % Restores the mouse cursor.
    ShowCursor;

    psychrethrow(psychlasterror);
end %try..catch..

