
try

    %fileName='/Users/mzirnsak/Desktop/flicker1.mat';oo



    addpath('E:\work\git\cclab-matlab-tools');
    addpath('E:\Eyelink_test_ground_Wenqing');



    %%%%    set  location
    currDate = strrep(datestr(datetime("today")), ':', '_');
    path = strcat('E:\EyelinkData\',cfg.sub,'\',currDate,'\'); % where to keep the edf files

    %%%%%%%%%%%%%%%%  load images
    %     imageDir = dir(dirName);
    %     fileNames = {imageDir(~[imageDir(:).isdir]).name};
    %     numImages = size(fileNames, 2);
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
    fpr=round(ppd*cfg.fpr); %radius of fixation point
    if ~cfg.polar
        v_x_fp=cfg.fp_x*ppd; % x position of the fixation points , round(-8*ppd), round(8*ppd)
        v_y_fp=cfg.fp_y*ppd; % y position of the fixation points , round(-8*ppd), round(8*ppd)
    elseif cfg.polar
        v_x_fp=cfg.radius*ppd*cos(cfg.degree); % x position of the fixation points , round(-8*ppd), round(8*ppd)
        v_y_fp=cfg.radius*ppd*sin(cfg.degree); % y position of the fixation points , round(-8*ppd), round(8*ppd)
    end

    window_fix=round(cfg.window_size*ppd); % the size of the accepted window for fixation point
    Flash=false;
    t_blink_before=0.1;
    t_blink_after=0.1;
    t_waitforfixation=2; % wait time for subjuct to fix when fp is first presented
    t_fixation=1;
    rewardAmount=250;
    %t_trialend=1;  % Inter trial interval
    %reward =250; % reward time (ms)

    %t1=0.2; % image loop time
    IRI = 1000; %interreward interval for multiple reward delivery

    % Use default screenNumber if none specified
    screenNumber = 1;



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
        %cleanup; % Abort experiment (see cleanup function below)
        return
    end
    edfFile = answer{1}; % Save file name to a variable
    % Print some text in Matlab's Command Window if file name is longer than 8 characters
    if length(edfFile) > 8
        fprintf('Filename needs to be no more than 8 characters long (letters, numbers and underscores only)\n');
        %cleanup; % Abort experiment (see cleanup function below)
        return
    end
    ListenChar(-1);

    % Open an EDF file and name it
    failOpen = Eyelink('OpenFile', edfFile);
    if failOpen ~= 0 % Abort if it fails to open
        fprintf('Cannot create EDF file %s', edfFile); % Print some text in Matlab's Command Window
        %cleanup; %see cleanup function below
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
    slack=Screen('GetFlipInterval',window)/2;
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    % background on
    Screen('FillRect',window, el.backgroundcolour);
    % start of the trial
    t_start_trial=Screen('Flip',window);
    % init loop
    trial_success=1;
    trial_attemp=1;
    trial_total=1;

    % Define first state
    stage='trial_new_start';
    change=false;
    if ~cfg.polar
        [A,B] = meshgrid(cfg.ip_x*ppd+v_x_fp,cfg.ip_y*ppd+v_y_fp);

        c=cat(2,A',B');
        allcomb=reshape(c,[],2);
        ramidx=randperm(size(allcomb,1));
        allcomb=allcomb(ramidx,:);
        numblock=size(allcomb,1);
    elseif cfg.polar
        allcomb=[cfg.ip_x*ppd+v_x_fp',cfg.ip_y*ppd+v_y_fp'];
        ramidx=randperm(size(allcomb,1));
        allcomb=allcomb(ramidx,:);
        numblock=size(allcomb,1);
    end
    block_x=repelem(allcomb(:,1),cfg.numrep);
    block_y=repelem(allcomb(:,2),cfg.numrep);
%     Eyelink('StartRecording');
    Results=table;



    eye_used = el.LEFT_EYE;

    i=1;
    while i>0
        reward=0;
        flag=0;
        Eyelink( 'Message', 'Trialstart');
        %Start recording
        Eyelink('Command', 'record_status_message ''TRIAL %d''', i);



        if rem(i,cfg.numrep*numblock)~=0
            x_fp=block_x(rem(i,numblock*cfg.numrep));
            y_fp=block_y(rem(i,numblock*cfg.numrep));
        else
            x_fp=block_x(end);
            y_fp=block_y(end);

        end
        box1= round(center(1)+x_fp-(window_fix/2));
        box2=round(center(2)-y_fp-(window_fix/2));
        box3=round(center(1)+x_fp+(window_fix/2));
        box4=round(center(2)-y_fp+(window_fix/2));
        %     Eyelink( 'Message', 'FPX %d', x_fp);
        %     Eyelink( 'Message', 'FPY %d', y_fp);



        disp('trial start')
        fix=0;




        %START WAIT FOR FIXATION
        t_start=GetSecs;
        %     x_eye=1000;
        %     y_eye=1000;

        while (fix==0 && ((GetSecs)-t_start)<t_waitforfixation)
if flag==0
                disp('fixon')
                flag=1;
Eyelink('StartRecording');

            end
            % Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end


            Screen('FillRect',window, el.backgroundcolour);
            Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
            Screen('DrawingFinished',window);
            Screen('Flip',window);

            Eyelink('command','draw_box %d %d %d %d 15', box1, box2, box3,box4);
            
            Eyelink('Message', 'Fixation1 On');

            [keyIsDown, secs, keyCode]=KbCheck;

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            evt=Eyelink('NewestFloatSample');
            x_eye=evt.gx(eye_used+1);
            y_eye=evt.gy(eye_used+1);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            if ((x_eye >= (center(1)+x_fp-(window_fix/2)))&&(x_eye <= (center(1)+x_fp+(window_fix/2)))&&(y_eye >= (center(2)-y_fp-(window_fix/2)))&&(y_eye <= (center(2)-y_fp+(window_fix/2))))
                fix=1;
                t_fix=GetSecs;
                disp('Fixation1 In');
                Eyelink('Message', 'Fixation1 In');
            else
                t_iti=GetSecs;
                if flag==1
                    disp('preiti')
                    flag=2;
                end
            end
        end
        %END WAIT FOR FIXATION



        %START FIXATION

        %     x_eye=1000;
        %     y_eye=1000;

        while (fix==1 && ((GetSecs)-t_fix)<cfg.t_fixation)

            %Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end

            [keyIsDown, secs, keyCode]=KbCheck;

            evt=Eyelink('NewestFloatSample');
            x_eye=evt.gx(eye_used+1);
            y_eye=evt.gy(eye_used+1);

            if ((x_eye >= (center(1)+x_fp-(window_fix/2)))&&(x_eye <= (center(1)+x_fp+(window_fix/2)))&&(y_eye >= (center(2)-y_fp-(window_fix/2)))&&(y_eye <= (center(2)-y_fp+(window_fix/2))))
                fix=1;
                flag=2;
            else
                fix=0;
                Screen('FillRect',window, el.backgroundcolour);
                Screen('DrawingFinished',window);
                % update time
                t_iti=Screen('Flip',window);
                flag=2;
            end


        end


        %END FIXATION

        %Present the fractal image



        if fix==1
            cclabReward(rewardAmount, 1, IRI);
            reward=1;
            disp('Juice');
            fix=0;
            Eyelink( 'Message', 'Reward %d', reward);
            Screen('FillRect',window,  el.backgroundcolour);
            Screen('DrawingFinished', window);
            t_iti=Screen('Flip', window);
            flag=2;
            if rem(i,cfg.numrep*numblock)==0
                ramidx=randperm(size(allcomb,1));
                allcomb=allcomb(ramidx,:);
                block_x=repelem(allcomb(:,1),cfg.numrep);
                block_y=repelem(allcomb(:,2),cfg.numrep);
            end
            i=i+1;
        end




        %START TRIAL END      inter-trial-interval
        while ((GetSecs)-t_iti)<cfg.t_trialend
            if flag==2
                Eyelink('command','clear_screen %d', 0);
                disp('iti')
                flag=3;
                Screen('FillRect',window,  el.backgroundcolour);
                Screen('DrawingFinished', window);
                Screen('Flip', window);
            end
            %Check recording status, stop display if error
            error=Eyelink('CheckRecording');
            if(error~=0)
                break;
            end
            [keyIsDown, secs, keyCode]=KbCheck;
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
                return
            end

        end
        %STOP TRIAL END

        Eyelink('Message', 'Trialend');

        %Stop recording


        %START PAUSE




Eyelink('StopRecording');


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
    Eyelink('StopRecording');

    ListenChar(1);
    fprintf('Done.\n');
    return;



catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    ListenChar(1);
    Eyelink('StopRecording');

    Eyelink('ShutDown');
    % Restores the mouse cursor.
    ShowCursor;

    psychrethrow(psychlasterror);
end %try..catch..

