
% Update Log
% 11/28/2022: Add Multi-poistion block fixation task, edit v_fp_x and
% v_fp_y and numrep to have the task run in block (eg. 5 left and 5 right)
% function VGSaccade(cfg)
% persistent flag

try
    % Add necessary libaries
    %     addpath('E:\work\git\cclab-matlab-tools');
    %     addpath('E:\Eyelink_test_ground_Wenqing');

    % Set pathway
    datetime.setDefaultFormats('defaultdate','MM-dd-yyyy')


    currDate = string(datetime("today"));
    path = strcat('D:\EyelinkData\','SalientMap\',cfg.sub,'\',currDate,'\'); % where to keep the edf files
        theImageLocation='D:\Wenqing\Foraging\';

    % check if folder exists, if not, create it
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

    fp_color=[0 0 255 1000]; % color of the fixation point
    fpr=round(ppd*cfg.fpr); % radius of fixation point
    x_fp=cfg.fp_x*ppd; % x position of the fixation points

    y_fp=cfg.fp_y*ppd; % y position of the fixation points
    % check whether using polar coordinates or cartesian


    window_fix=round(cfg.windowSize*ppd); % the size of the accepted window for fixation point
    Flash=false; % whether the point is flahsing in the wait for fix stage
    t_blink_before=0.1; % time set for blinking
    t_blink_after=0.1; % time set for blinking



    %t1=0.2; % image loop time
    IRI = 1000; %interreward interval for multiple reward delivery


    % Use default screenNumber if none specified
    screenNumber = cfg.ScreenNumber;


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
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');











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
    el.calibrationtargetsize = 0.5;% Outer target size as percentage of the screen
    el.calibrationtargetwidth = 0;% Inner target size as percentage of the screen
    el.backgroundcolour = [200 200 200];% RGB blackgrey
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
    slack=Screen('GetFlipInterval',window)/2;

    % Fill the screen and get flip interval
    %     slack=Screen('GetFlipInterval',window)/2;
    RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));
    % background on
    Screen('FillRect',window, el.backgroundcolour);
    % start of the trial
    t_checkpoint=Screen('Flip',window);

    % init loop and trial number
    trial_success=1;
    trial_attemp=1;
    trial_total=1;
    % Define first state
    stage='trial_new_start';
    % disable change of fixation window
    change=false;



    % init result table
    Results=table;
    eye_used = el.LEFT_EYE;
    ErrorTime=0;
    ErrorStage=0;
    ErrorTrial=0;
    % Define the size of the squares in degrees
    squareWidthDeg = 6;
    squareHeightDeg = 4;
    for i=1:squareWidthDeg
        for j=1:squareHeightDeg
            squares{i,j}=[(2*i-1)*width/squareWidthDeg/2-cfg.squareSize*ppd (2*j-1)*height/squareHeightDeg/2-cfg.squareSize*ppd (2*i-1)*width/squareWidthDeg/2+cfg.squareSize*ppd (2*j-1)*height/squareHeightDeg/2+cfg.squareSize*ppd];
        end
    end
    SquareOrderX=[];
    SquareOrderY=[];
    files=dir('D:\Wenqing\Foraging\Texture\Image*.bmp');


    % squares=[width/squareWidthDeg-cfg.squareSize*ppd height/squareHeightDeg-cfg.squareSize*ppd width/squareWidthDeg+cfg.squareSize*ppd height/squareHeightDeg+cfg.squareSize*ppd;
    %     3*width/squareWidthDeg-cfg.squareSize*ppd height/squareHeightDeg-cfg.squareSize*ppd 3*width/squareWidthDeg+cfg.squareSize*ppd height/squareHeightDeg+cfg.squareSize*ppd
    %     3*width/squareWidthDeg-cfg.squareSize*ppd 3*height/squareHeightDeg-cfg.squareSize*ppd 3*width/squareWidthDeg+cfg.squareSize*ppd 3*height/squareHeightDeg+cfg.squareSize*ppd
    %     5*width/squareWidthDeg-cfg.squareSize*ppd 3*height/squareHeightDeg-cfg.squareSize*ppd 5*width/squareWidthDeg+cfg.squareSize*ppd 3*height/squareHeightDeg+cfg.squareSize*ppd
    %     5*width/squareWidthDeg-cfg.squareSize*ppd height/squareHeightDeg-cfg.squareSize*ppd 5*width/squareWidthDeg+cfg.squareSize*ppd height/squareHeightDeg+cfg.squareSize*ppd
    %     width/squareWidthDeg-cfg.squareSize*ppd 3*height/squareHeightDeg-cfg.squareSize*ppd width/squareWidthDeg+cfg.squareSize*ppd 3*height/squareHeightDeg+cfg.squareSize*ppd];
    %     % keep looping or set the number of successful trial wanted
    while trial_success>0
        switch(stage)
            case 'trial_new_start'

                WaitSecs(0.1);
                Eyelink('StartRecording');
                disp('trial_start');

                if mod(trial_success-1,24)==0
                    % Define the ranges for i and j
                    iRange = 1:6;
                    jRange = 1:4;

                    % Create a cell array to store the combinations
                    combinations = cell(numel(iRange)*numel(jRange), 2);

                    % Iterate over each combination of i and j and store it in the cell array
                    k = 1;
                    for i = iRange
                        for j = jRange
                            combinations{k, 1} = i;
                            combinations{k, 2} = j;
                            k = k + 1;
                        end
                    end

                    % Randomize the order of the combinations
                    randomOrder = randperm(size(combinations, 1));
                    randomCombinations = combinations(randomOrder, :);

                    % Display the randomized combinations
                    for k = 1:size(randomCombinations, 1)
                        i = randomCombinations{k, 1};
                        j = randomCombinations{k, 2};
                        SquareOrderX=[SquareOrderX i];
                        SquareOrderY=[SquareOrderY j];


                    end
                end

                stage='put_on_fp';
            case 'put_on_fp'
                % check if fixation window is adjusted
                if change
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                    box1= round(x_eye-(window_fix/2));
                    box2=round(y_eye-(window_fix/2));
                    box3=round(x_eye+(window_fix/2));
                    box4=round(y_eye+(window_fix/2));
                    % set fixation window
                elseif ~change
                    box1= round(center(1)+x_fp-(window_fix/2));
                    box2=round(center(2)-y_fp-(window_fix/2));
                    box3=round(center(1)+x_fp+(window_fix/2));
                    box4=round(center(2)-y_fp+(window_fix/2));


                end
                %Check recording status, stop display if error


                %                 % draw background
                %                 Screen('FillRect',window, el.backgroundcolour);
                %                 Screen('DrawingFinished',window);
                %                 Screen('Flip',window);

                % draw fixation point, update time
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                t_checkpoint=Screen('Flip',window);

                disp('put on fp')
                % draw box on eyelink machine, representing window of
                % accepted eye position
                Eyelink('command','clear_screen %d', 0);
                Eyelink('command','draw_box %d %d %d %d 15', box1, box2, box3,box4);

                % check if key is pressed
                checkkeys;

                % update stage
                stage='wait_for_fix_fp';

            case 'wait_for_fix_fp'



                % get eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');

                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end

                % check whether eye is in the fixation window, if yes, set
                % stage to next wait for hold stage and update time;
                % if not, return to the trial start stage with previous
                % fixation point position
                if ((x_eye >=box1)&&(x_eye <= box3)&&(y_eye >= (box2))&&(y_eye <=box4))
                    t_checkpoint=GetSecs;
                    Results.FixOnFP(trial_total)=GetSecs;
                    % Eyelink Matlab Message, fix in fp
                    disp('wait hold fp')
                    stage='wait_for_hold_fp';

                elseif GetSecs-t_checkpoint>=cfg.t_waitfixation_fp
                    stage='inter_trial_interval';
                end
                % make the dots flash if wanted
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

            case 'wait_for_hold_fp'




                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');

                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= (box1))&&(x_eye <= (box3))&&(y_eye >= (box2))&&(y_eye <= (box4)))
                    t_checkpoint=GetSecs;

                    stage='inter_trial_interval';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_fp
                    % Eyelink matlab message, Hold comp fp
                    Results.HoldCompFP(trial_total)=GetSecs;
                    %                     Eyelink('Message','HoldCompFPWOSP %d',trial_total);
                    %                     fprintf('Hold Comp FP without SP %d',trial_total)
                    stage='put_on_image';
                end
                % check if key is pressed
                checkkeys;
            case 'put_on_image'
                disp('put on image')
                                Results.img(trial_total)=randi([1,size(files,1)]);

                trial_attemp=trial_attemp+1;
                Results.TrialAttemp(trial_total)=1;



                % draw fixation point, update time

                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillRect', window, [0 255 255], cell2mat(squares(SquareOrderX(trial_success),SquareOrderY(trial_success))));
              if cfg.setLocation 
                  SquareOrderX(trial_success)=cfg.LocationX;
                                    SquareOrderY(trial_success)=cfg.LocationY;

                if cfg.popout && cfg.Natural
                    %popout one natural else texture
                    imgRect=cell2mat(squares(SquareOrderX(trial_success),SquareOrderY(trial_success)));
                    theImage1 = imread(strcat(theImageLocation,'Natural\',files(Results.img(trial_total)).name));

                    theImage2 = imread(strcat(theImageLocation,'Texture\',files(Results.img(trial_total)).name));


                    imageTexture1 = Screen('MakeTexture', window, theImage1);
                    imageTexture2 = Screen('MakeTexture', window, theImage2);
                    for i=1:6
                        for j=1:4
                            tempRect=cell2mat(squares(i,j));
                            Screen('DrawTexture', window, imageTexture2, [], tempRect, 0);
                        end
                    end

                    Screen('DrawTexture', window, imageTexture1, [], imgRect, 0);


                    Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                    t_checkpoint=Screen('Flip',window);
                elseif cfg.popout && cfg.Texture
                    imgRect=cell2mat(squares(SquareOrderX(trial_success),SquareOrderY(trial_success)));
                    theImage1 = imread(strcat(theImageLocation,'Natural\',files(Results.img(trial_total)).name));

                    theImage2 = imread(strcat(theImageLocation,'Texture\',files(Results.img(trial_total)).name));


                    imageTexture1 = Screen('MakeTexture', window, theImage1);
                    imageTexture2 = Screen('MakeTexture', window, theImage2);
                    for i=1:6
                        for j=1:4
                            tempRect=cell2mat(squares(i,j));
                            Screen('DrawTexture', window, imageTexture1, [], tempRect, 0);
                        end
                    end

                    Screen('DrawTexture', window, imageTexture2, [], imgRect, 0);


                    Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                    t_checkpoint=Screen('Flip',window);
                
              elseif cfg.onebyone & mod(trial_success)==1
                  imgRect=cell2mat(squares(SquareOrderX(trial_success),SquareOrderY(trial_success)));
                    theImage1 = imread(strcat(theImageLocation,'Natural\',files(Results.img(trial_total)).name));

                    theImage2 = imread(strcat(theImageLocation,'Texture\',files(Results.img(trial_total)).name));


                    imageTexture1 = Screen('MakeTexture', window, theImage1);
                    imageTexture2 = Screen('MakeTexture', window, theImage2);
                    for i=1:6
                        for j=1:4
                            tempRect=cell2mat(squares(i,j));
                            Screen('DrawTexture', window, imageTexture2, [], tempRect, 0);
                        end
                    end

                    Screen('FillRect', window, el.backgroundcolour,imgRect);


                    Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                    t_checkpoint=Screen('Flip',window);
                elseif  cfg.onebyone & mod(trial_success)==0
                     imgRect=cell2mat(squares(SquareOrderX(trial_success),SquareOrderY(trial_success)));
                    theImage1 = imread(strcat(theImageLocation,'Natural\',files(Results.img(trial_total)).name));

                    theImage2 = imread(strcat(theImageLocation,'Texture\',files(Results.img(trial_total)).name));


                    imageTexture1 = Screen('MakeTexture', window, theImage1);
                    imageTexture2 = Screen('MakeTexture', window, theImage2);
                    

                            Screen('DrawTexture', window, imageTexture2, [], imgRect, 0);


                    Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                    t_checkpoint=Screen('Flip',window);
                end
              end

                Results.PutOnImg1(trial_total)=t_checkpoint;
                Results.Xpos(trial_total)=SquareOrderX(trial_success);
                Results.Ypos(trial_total)=SquareOrderY(trial_success);

                % check key press
                checkkeys;
                stage='HoldFP';

            case 'HoldFP'

                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');

                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= (box1))&&(x_eye <= (box3))&&(y_eye >= (box2))&&(y_eye <= (box4)))
                    t_checkpoint=GetSecs;

                    stage='inter_trial_interval';
                elseif GetSecs-t_checkpoint>=cfg.t_hold_fixation_fp
                    % Eyelink matlab message, Hold comp fp
                    Results.HoldCompFP(trial_total)=GetSecs;
                    %                     Eyelink('Message','HoldCompFPWOSP %d',trial_total);
                    %                     fprintf('Hold Comp FP without SP %d',trial_total)
                    stage='HoldImgOff';
                end
                % check if key is pressed
                checkkeys;

            case 'HoldImgOff'
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                t_checkpoint=Screen('Flip',window);
                stage='KeepHoldImgOff';

            case 'KeepHoldImgOff'
                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');

                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= (box1))&&(x_eye <= (box3))&&(y_eye >= (box2))&&(y_eye <= (box4)))
                    t_checkpoint=GetSecs;

                    stage='inter_trial_interval';
                elseif GetSecs-t_checkpoint>=cfg.t_hold_fixation_fp
                    % Eyelink matlab message, Hold comp fp
                    Results.HoldCompFP(trial_total)=GetSecs;
                    %                     Eyelink('Message','HoldCompFPWOSP %d',trial_total);
                    %                     fprintf('Hold Comp FP without SP %d',trial_total)
                    stage='reward';
                end
                % check if key is pressed
                checkkeys;

            case 'reward'
                if cfg.randreward
                    if rand>=cfg.randper
                        cclabReward(cfg.reward*1.5, 1, IRI);
                        % Eyelink matlab message, reward and reward amount
                        Eyelink( 'Message', 'Reward %d,trial %d', cfg.reward*1.5,trial_total);
                        fprintf('reward amount %d,trial %d \n',cfg.reward*1.5,trial_total)
                        Results.RewardAmount(trial_total)=cfg.reward*2;
                        Results.RewardTime(trial_total)=GetSecs;


                    else
                        cclabReward(cfg.reward, 1, IRI);

                        % Eyelink matlab message, reward and reward amount
                        Eyelink( 'Message', 'Reward %d, trial %d', cfg.reward,trial_total);
                        Results.RewardAmount(trial_total)=cfg.reward;
                        fprintf('reward amount %d,trial %d \n',cfg.reward,trial_total)
                        Results.RewardTime(trial_total)=GetSecs;



                    end
                else
                    % matlab message reward and number of success trial
                    % Give reward, if random reward is enabled and random
                    % number is above threshold, give doble reward
                    cclabReward(cfg.reward, 1, IRI);
                    Eyelink( 'Message', 'Reward %d,trial %d', cfg.reward,trial_total);
                    Results.RewardAmount(trial_total)=cfg.reward;
                    fprintf('reward amount %d,trial %d \n',cfg.reward,trial_total);
                    fprintf('Success trial %d \n',trial_total);

                    Results.RewardTime(trial_total)=GetSecs;
                end



                % update time and success trial count
                t_checkpoint=GetSecs;
                trial_success=trial_success+1;
                Results.Reward(trial_total)=1;
                Results.TrialSuccess(trial_total)=1;
                % Go to inter trial interval
                stage='inter_trial_interval';
            case 'inter_trial_interval'


                % Fill background grey
                Screen('FillRect',window, el.backgroundcolour);
                % update time
                t_checkpoint=Screen('Flip',window);
                Results.ITI(trial_total)=t_checkpoint;
                % Eyelink matlab message, iti
                fprintf('iti %d \n',trial_total);
                Eyelink('Message', 'Inter-Trial-Interval %d',trial_total);
                % update total trial count, save results
                trial_total=trial_total+1;
                WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
                Eyelink('StopRecording');
                Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode

                Screen('Close');

                % wait for iti
                WaitSecs(cfg.t_trialend);

                stage='trial_new_start';


            case 'ForcedTrial_fp'
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                t_checkpoint=Screen('Flip',window);
                % check if key is pressed

                checkkeys;
                Results.FTFPON(trial_total)=t_checkpoint;
                % update stage
                checkkeys;

                stage='ForcedTrial_waitfix';
            case 'ForcedTrial_waitfix'

                % get eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');

                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                if ((x_eye >=box1)&&(x_eye <= box3)&&(y_eye >= (box2))&&(y_eye <=box4))
                    t_checkpoint=GetSecs;
                    Results.FixOnFTFP(trial_total)=GetSecs;
                    % Eyelink Matlab Message, fix in fp

                    stage='ForcedTrial_holdFP';

                elseif GetSecs-t_checkpoint>=cfg.t_waitfixation_FTfp
                    stage='ForcedTrial_fp';
                end
                checkkeys;

            case 'ForcedTrial_holdFP'
                % check eye position

                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');

                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= (box1))&&(x_eye <= (box3))&&(y_eye >= (box2))&&(y_eye <= (box4)))
                    t_checkpoint=GetSecs;

                    stage='ForcedTrial_fp';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_FTfp
                    % Eyelink matlab message, Hold comp fp
                    Results.HoldCompFTFP(trial_total)=GetSecs;
                    %                     Eyelink('Message','HoldCompFPWOSP %d',trial_total);
                    %                     fprintf('Hold Comp FP without SP %d',trial_total)
                    stage='ForcedTrial_put_on_image';
                end
                checkkeys;

            case 'ForcedTrial_put_on_image'

                if Results.choice(trial_total)==1
                    if Results.positionImg(trial_total)==0 || Results.positionImg(trial_total)==2
                        Screen('DrawTexture', window, imageTexture1, [], leftRect, 0);
                    else
                        Screen('DrawTexture', window, imageTexture2, [], leftRect, 0);
                    end
                else
                    if Results.positionImg(trial_total)==1 || Results.positionImg(trial_total)==2
                        Screen('DrawTexture', window, imageTexture2, [], rightRect, 0);
                    else
                        Screen('DrawTexture', window, imageTexture1, [], rightRect, 0);
                    end
                end

                t_checkpoint=Screen('Flip',window);

                Results.PutOnFTImg(trial_total)=t_checkpoint;
                checkkeys;
                stage='ForcedTrial_WaitChoice';

            case 'ForcedTrial_WaitChoice'

                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if ((x_eye >= (boximga1))&&(x_eye <= (boximga3))&&(y_eye >= (boximga2))&&(y_eye <= (boximga4)) &&Results.choice(trial_total)==1)
                    t_checkpoint=GetSecs;
                    Results.FTImageIn(trial_total)=t_checkpoint;
                    stage='ForcedTrialholdChoice';
                elseif ((x_eye >= (boximgb1))&&(x_eye <= (boximgb3))&&(y_eye >= (boximgb2))&&(y_eye <= (boximgb4))&&Results.choice(trial_total)==2)
                    t_checkpoint=GetSecs;
                    Results.FTImageIn(trial_total)=t_checkpoint;

                    stage='ForcedTrialholdChoice';
                elseif GetSecs-t_checkpoint>=cfg.t_waitfixation_fp
                    stage='ForcedTrial_fp';

                end
                % check if key is pressed
                checkkeys;
            case 'ForcedTrialholdChoice'





                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                if Results.choice(trial_total)==1
                    if not((x_eye >= (boximga1))&&(x_eye <= (boximga3))&&(y_eye >= (boximga2))&&(y_eye <= (boximga4)))
                        t_checkpoint=GetSecs;

                        stage='ForcedTrial_fp';
                    elseif GetSecs-t_checkpoint>=cfg.t_fixation_result
                        % eyelink, matlab message, hold comp fp
                        Results.HoldCompFTIMG(trial_total)=GetSecs;
                        %                     Eyelink('Message', 'HoldCompFPWSP');
                        %                     disp('HoldCompFP With SP')
                        stage='reward';
                    end
                elseif Results.choice(trial_total)==2
                    if not((x_eye >= (boximgb1))&&(x_eye <= (boximgb3))&&(y_eye >= (boximgb2))&&(y_eye <= (boximgb4)))
                        t_checkpoint=GetSecs;

                        stage='ForcedTrial_fp';
                    elseif GetSecs-t_checkpoint>=cfg.t_fixation_sp
                        % eyelink, matlab message, hold comp fp
                        Results.HoldCompFTIMG(trial_total)=GetSecs;
                        %                     Eyelink('Message', 'HoldCompFPWSP');
                        %                     disp('HoldCompFP With SP')
                        stage='reward';
                    end
                end
                checkkeys;






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
                save(edfFile, 'Results')
                st1='cfg';
                st2='all';
                save(append(edfFile,st1), 'cfg')
                save(append(edfFile,st2))

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
                Screen('FillRect',window, [0 0 1]);
                Screen('Flip',window);
                checkkeys;
                %if down key is pressed, return to trial start stage
                if (keyCode(down)==1)
                    stage='trial_new_start';
                end


        end
    end




catch exception
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    msgText = getReport(exception);
    cd(path)
    save(edfFile, 'Results')
    st1='cfg';
    st2='all';
    save(append(edfFile,st1), 'cfg')
    save(append(edfFile,st2))
    Screen('CloseAll');
    ListenChar(1);
    Eyelink('ShutDown');
    % Restores the mouse cursor.
    ShowCursor;

end
%end