% Update Log
% 11/28/2022: Add Multi-poistion block fixation task, edit v_fp_x and
% v_fp_y and numrep to have the task run in block (eg. 5 left and 5 right)
function FixTestV2(sub,windowSize,t_fixation_input,numrep,fp_x,fp_y,reward)

try
    % Add necessary libaries
    addpath('E:\work\git\cclab-matlab-tools');
    % Set pathway
    currDate = strrep(datestr(datetime("today")), ':', '_');
    path = strcat('E:\EyelinkData\',sub,'\',currDate,'\'); % where to keep the edf files

    % check if foloooder exists, if not, create it
    if isfolder(path)
        disp('Folder exisis')
    elseif not (isfolder(path))
        mkdir(path)
        disp('Folder created')
        disp(path)
    end
    %skip synctest
    Screen('Preference', 'SkipSyncTests', 1);


    % set parameters
    numpixel=[1920,1080]; %total number of pixels of the screen (in pixel)
    screenlen=68.63; %real length of the screen (in cm)
    screenheight=38.60; %real height of the screen (in cm)

    ppcm=numpixel(1)/screenlen; %Number of pixels per centimeter default is 40
    obs_dist = 78;   % viewing distance (cm)
    ppd=2*obs_dist*ppcm*tan(pi/360);   %Number of pixels per degree of visual angle
    %ppd= deg2pix(1, cfg);

    fp_color=[0 0 255]; % color of the fixation point
    fpr=round(ppd*0.5); %radius of fixation point
    v_x_fp=fp_x*ppd; % x position of the fixation points , round(-8*ppd), round(8*ppd)
    v_y_fp=fp_y*ppd; % y position of the fixation points , round(-8*ppd), round(8*ppd)
    window_fix=round(windowSize*ppd); % the size of the accepted window for fixation point
    Flash=false;
    t_blink_before=0.1;
    t_blink_after=0.1;
    t_waitforfixation=2; % wait time for subjuct to fix when fp is first presented
    t_fixation=t_fixation_input;% time required to hold fixation (s)
    %t_trialend=1;  % Inter trial interval
    t_trialend=0;
    %reward =250; % reward time (ms)

    %t1=0.2; % image loop time
    IRI = 1000; %interreward interval for multiple reward delivery


    % Use default screenNumber if none specified
    screenNumber = 1;


    % Switch KbName into unified mode: It will use the names of the OS-X
    % platform on all platforms in order to make this script portable:
    KbName('UnifyKeyNames');

    % Query keycodes:
    esc=KbName('ESCAPE');% quit the program
    space=KbName('space'); % juice reward
    left=KbName('LeftArrow');
    right=KbName('RightArrow');
    up=KbName('UpArrow'); % pause the program
    down=KbName('DownArrow'); % stop pause
    coolkey=KbName('return');

    %% STEP 0: INITIALIZE pump reward system
    cclabInitDIO("jA");

    %% STEP 1: INITIALIZE EYELINK CONNECTION; OPEN EDF FILE; GET EYELINK TRACKER VERSION

    % Initialize EyeLink connection (dummymode = 0) or run in "Dummy Mode" without an EyeLink connection (dummymode = 1);
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
    ListenChar(-1);

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
    % Open a grey background window
    [window, rect] = Screen('OpenWindow', screenNumber, [128 128 128]); % Open graphics window
    % Define center coord
    [center(1), center(2)] = RectCenter(rect);
    % Show on screen
    Screen('Flip', window);
    % Return width and height of the graphics window/screen in pixels
    [width, height] = Screen('WindowSize', window);








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
    el = EyelinkInitDefaults(window);
    % set calibration/validation/drift-check(or drift-correct) size as well as background and target colors.
    % It is important that this background colour is similar to that of the stimuli to prevent large luminance-based
    % pupil size changes (which can cause a drift in the eye movement data)
    el.calibrationtargetsize = 5;% Outer target size as percentage of the screen
    el.calibrationtargetwidth = 0;% Inner target size as percentage of the screen
    el.backgroundcolour = [128 128 128];% RGB grey
    el.calibrationtargetcolour = [0 0 1];% RGB black
    % set "Camera Setup" instructions text colour so it is different from background colour
    el.msgfontcolour = [0 0 1];% RGB black
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
    Eyelink('Command','calibration_area_proportion 0.5 0.5');
    % Hide mouse cursor
    % Start listening for keyboard input. Suppress keypresses to Matlab windows.
    ListenChar(-1);
    Eyelink('Command', 'clear_screen 0'); % Clear Host PC display from any previus drawing

    % Put EyeLink Host PC in Camera Setup mode for participant setup/calibration

    EyelinkDoTrackerSetup(el);


    % Wait for kb input
    KbWait;

    % Fill the screen and get flip interval
    Screen('Rect',window);
    %     slack=Screen('GetFlipInterval',window)/2;
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    % background on
    Screen('FillRect',window, el.backgroundcolour);
    % start of the trial
    t_start_trial=Screen('Flip',window);

    % init loop
    trial_success=1;
    % Define first state
    stage='trial_new_start';
    change=false;

    [A,B] = meshgrid(v_x_fp,v_y_fp);
    c=cat(2,A',B');
    allcomb=reshape(c,[],2);
    ramidx=randperm(size(allcomb,1));
    allcomb=allcomb(ramidx,:);
    numblock=size(allcomb,1);
    block_x=repelem(allcomb(:,1),numrep);
    block_y=repelem(allcomb(:,2),numrep);
    Eyelink('StartRecording');
    while trial_success>0
        switch(stage)
            case 'trial_new_start'
                % Random draw x and y of fp from the pool above, start a
                % new fixation point when subject refuses to look at the
                % fixation point
                %                 x_fp=v_x_fp(randperm(length(v_x_fp),1));
                %                 y_fp=v_y_fp(randperm(length(v_x_fp),1));
                if rem(trial_success,numrep*numblock)~=0
                    x_fp=block_x(rem(trial_success,numblock*numrep));
                    y_fp=block_y(rem(trial_success,numblock*numrep));
                else
                    x_fp=block_x(end);
                    y_fp=block_y(end);

                end
                disp('trialnewstart')
                stage='trial_start';

            case 'trial_start'
                % Eyelink message, start of trial
                Eyelink( 'Message', 'Trialstart');
                %Start recording
                %status(end+1) = Eyelink('IsConnected');
                %disp(status)
                %Eyelink('StartRecording');
                % Eyelink message, record trial number
                Eyelink('Command', 'record_status_message "TRIAL %d "', trial_success);
                disp('trialstart')

                % Matlab message, display trial number
                %disp('trial_start')




                %Clear screen on eyelink machine
                Eyelink('command','clear_screen %d', 0);

                % Set used eye to Left eye as default
                eye_used = el.LEFT_EYE;


                %START WAIT FOR FIXATION, get current time, start counting down
                t_start=GetSecs;


                % check if key is pressed in this stage
                checkkeys;
                % Move to stage, put on fixation point on the screen
                stage='put_on_fp';
            case 'put_on_fp'
                % Matlab message, display put_on_fp
                disp('put_on_fp')
                if change
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                    box1= round(x_eye-(window_fix/2));
                    box2=round(y_eye-(window_fix/2));
                    box3=round(x_eye+(window_fix/2));
                    box4=round(y_eye+(window_fix/2));
                elseif ~change
                    box1= round(center(1)+x_fp-(window_fix/2));
                    box2=round(center(2)-y_fp-(window_fix/2));
                    box3=round(center(1)+x_fp+(window_fix/2));
                    box4=round(center(2)-y_fp+(window_fix/2));
                end
                % Check recording status, stop display if error
                error=Eyelink('CheckRecording');
                if(error~=0)
                    
                    break;
                end

                % draw background, update time
                Screen('FillRect',window, el.backgroundcolour);
                Screen('DrawingFinished',window);
                Screen('Flip',window);

                % draw fixation point, update time
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                Screen('DrawingFinished',window);
                t_start_trial=Screen('Flip',window);
                % Eyelink message
                Eyelink('Message', 'PutOnFix');
                % draw box on eyelink machine, representing window of
                % accepted eye position
                Eyelink('command','clear_screen %d', 0);
                Eyelink('command','draw_box %d %d %d %d 15', box1, box2, box3,box4);

                % check if key is pressed
                checkkeys;
                % update stage
                stage='wait_for_fix';

            case 'wait_for_fix'
                % Matlab message
                disp('wait_for_fix')
                Eyelink('Message', 'WaitForFix');

                % get eye position
                evt=Eyelink('NewestFloatSample');
                x_eye=evt.gx(eye_used+1);
                y_eye=evt.gy(eye_used+1);

                % check whether eye is in the fixation window, if yes, set
                % stage to next wait for hold stage and update time;
                % if not, return to the trial start stage with previous
                % fixation point position
                if ((x_eye >=box1)&&(x_eye <= box3)&&(y_eye >= (box2))&&(box4))
                    stage='wait_for_hold';
                    t_start_trial=GetSecs;
                elseif GetSecs-t_start_trial>t_waitforfixation
                    stage='inter_trial_interval';
                end
                if Flash
                    % draw background, update time
                    Screen('FillRect',window, el.backgroundcolour);
                    Screen('Flip',window);
                    WaitSecs(t_blink_before);
                    % draw fixation point, update time
                    Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                    Screen('Flip',window);
                    WaitSecs(t_blink_after);
                end

                % check if key is pressed
                checkkeys;

            case 'wait_for_hold'
                % Matlab message
                disp('wait_for_hold')
                %Check recording status, stop display if error
                error=Eyelink('CheckRecording');
                if(error~=0)
                    break;
                end
                Eyelink('Message', 'WaitForHold');

                % check eye position
                evt=Eyelink('NewestFloatSample');
                x_eye=evt.gx(eye_used+1);
                y_eye=evt.gy(eye_used+1);
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= (box1))&&(x_eye <= (box3))&&(y_eye >= (box2))&&(y_eye <= (box4)))
                    stage='inter_trial_interval';
                    t_start_trial=GetSecs;
                elseif GetSecs-t_start_trial>t_fixation
                    stage='reward';
                end
                % check if key is pressed
                checkkeys;
            case 'reward'
                % display successful trial time
                %disp(num2str(t_start));
                % Matlab message
                fprintf('reward 2\n');
                disp(trial_success)
                % Give reward
                cclabReward(reward, 1, IRI);
                % Eyelink message, reward and reward amount
                Eyelink( 'Message', 'Reward %d', reward);
                % update time
                t_start_trial=GetSecs;
                trial_success=trial_success+1;
                if rem(trial_success,numrep*numblock)==0
                    ramidx=randperm(size(allcomb,1));
                    allcomb=allcomb(ramidx,:);
                    block_x=repelem(allcomb(:,1),numrep);
                    block_y=repelem(allcomb(:,2),numrep);
                end
                % Go to inter trial interval
                stage='inter_trial_interval';
            case 'inter_trial_interval'
                % Eyelink('StopRecording');
                Eyelink('Message', 'Inter-Trial-Interval');
% Fill background grey
                Screen('FillRect',window, el.backgroundcolour);
                Screen('DrawingFinished',window);
                % update time
                Screen('Flip',window, t_start_trial);
                stage='inter_trial_interval_2';
            case 'inter_trial_interval_2'
                % Matlab message
                disp('inter_trial_interval')

                %START TRIAL END
                
                % wait until t_trialend has passed. Go to new trial with
                % new fixation point
                if GetSecs-t_start_trial>t_trialend
                    stage='trial_new_start';
                end


            case 'exp_end'
                %STOP TRIAL END
                % Eyelink message, Exp end
                Eyelink('Message', 'ExpEnd');

                %Stop recording, close file,clean up screen, show cursor, give back
                %keyboard control,  matlab message
                Eyelink('StopRecording');
                ShowCursor;
                Screen('CloseAll');
                ListenChar(1);
                fprintf('Aborted.\n');
                Eyelink('CloseFile');
                % download data file, shutdown eyelink
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
                    disp('file transfer')
                    %%% the eye files
                    system(['edf2asc', ' ', sprintf('%s%s',path, edfFile),'.edf -s -miss -1.0 -y']);
                    movefile(sprintf('%s.asc',edfFile), sprintf('%s%s.dat',path,edfFile));
                    disp('file finish')

                    %%% the event files
                    disp('file transfer')

                    system(['edf2asc', ' ', sprintf('%s%s',path, edfFile),'.edf -e -y']);
                    disp('file finish')

                catch
                    fprintf('Problem receiving data file ''%s''\n', edfFile );
                    %%% the eye files
                    system(['edf2asc', ' ', sprintf('%s%s',path, edfFile),'.edf -s -miss -1.0 -y']);
                    movefile(sprintf('%s.asc',edfFile), sprintf('%s%s.dat',path,edfFile));
                    %%% the event files
                    system(['edf2asc', ' ', sprintf('%s%s',path, edfFile),'.edf -e -y']);

                end
                Eyelink('ShutDown');
                return ;
                % when check keys, if up is pressed, go to pause state
            case 'pause'
                % fill grey screen, check for other key pressed
                Screen('FillRect',window, el.backgroundcolour);
                Screen('DrawingFinished',window);
                Screen('Flip',window);
                checkkeys;
                %if down key is pressed, return to trial start stage
                if (keyCode(down)==1)
                    stage='trial_start';
                end


        end
    end




catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    ListenChar(1);
    Eyelink('ShutDown');
    % Restores the mouse cursor.
    ShowCursor;

    psychrethrow(psychlasterror);
end
end