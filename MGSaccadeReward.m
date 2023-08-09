% Update Log
% 11/28/2022: Add Multi-poistion block fixation task, edit v_fp_x and
% v_fp_y and numrep to have the task run in block (eg. 5 left and 5 right)
% function VGSaccade(cfg)
% persistent flag
baseRect = [1820 900 1920 1100];
rectColor = [255 255 255];

try
    % Add necessary libaries
    %     addpath('E:\work\git\cclab-matlab-tools');
    %     addpath('E:\Eyelink_test_ground_Wenqing');
    datetime.setDefaultFormats('defaultdate','MM-dd-yyyy')


    currDate = string(datetime("today"));
    % Set pathway
    path = strcat('D:\EyelinkData\','MGSaccade\',cfg.sub,'\',currDate,'\'); % where to keep the edf files

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
    sp_color=[0 0 255 cfg.contrasttarget]; % color of the saccade point
    sp2_color=[0 0 255 cfg.contrast]; % saccade point reminder after putting off both saccade point and fixation point

    fpr=round(ppd*cfg.fpr); % radius of fixation point
    spr=round(ppd*cfg.spr); % radius of saccade point
    v_x_fp=cfg.fp_x*ppd; % x position of the fixation points
    x_fp=cfg.fp_x*ppd;
    y_fp=cfg.fp_y*ppd;
    v_y_fp=cfg.fp_y*ppd; % y position of the fixation points
    % check whether using polar coordinates or cartesian
    if ~cfg.polar
        % cartesian
        v_x_sp=cfg.sp_x*ppd;
        v_y_sp=cfg.sp_y*ppd;
    elseif cfg.polar
        % polar
        v_x_sp=cfg.radius*ppd*cos(cfg.degree);
        v_y_sp=cfg.radius*ppd*sin(cfg.degree);
    end



    window_fix=cfg.windowSize*ppd; % the size of the accepted window for fixation point
    window_sp_fix=cfg.spwindowSize*ppd;
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
    % It is important that this background colour is similar to that of the stimuli to prevent lar
    % ge luminance-based
    % pupil size changes (which can cause a drift in the eye movement data)
    el.calibrationtargetsize = 0.5;% Outer target size as percentage of the screen
    el.calibrationtargetwidth = 0;% Inner target size as percentage of the screen
    el.backgroundcolour = [128 128 128];% RGB grey
    el.calibrationtargetcolour = [0 0 1];% RGB black
    % set "Camera Setup" instructions text colour so it is different from background colour
    el.msgfontcolour = [0 0 1];% RGB black
    % You must call this function to apply the changes made to the el structure above
    EyelinkUpdateDefaults(el);

    % Set display coordinates for EyeLink data by entering left, top, right and bottom coordinates in screen pixels
    Eyelink('Command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, width, height);
    % Write DISPLAY_COORDS message to EDF file: sets display coordinates in DataViewer
    % See DataViewer manual section: Protocol for EyeLink Data to Viewer Integration > Pre-trial Message Commands
    Eyelink('Message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, width, height);
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

    if ~cfg.polar
        %cartesian saccade point all combination
        [A_sp,B_sp] = meshgrid(cfg.fp_x*ppd+v_x_sp,cfg.fp_y*ppd+v_y_sp);
        c_sp=cat(2,A_sp',B_sp');
        allcomb_sp=reshape(c_sp,[],2);
        ramidx_sp=randperm(size(allcomb_sp,1));
        allcomb_sp=allcomb_sp(ramidx_sp,:);
        numblock_sp=size(allcomb_sp,1);
    elseif cfg.polar
        %polar saccade point all combination
        allcomb_sp=[cfg.fp_x*ppd+v_x_sp',cfg.fp_y*ppd+v_y_sp'];
        ramidx=randperm(size(allcomb_sp,1));
        allcomb_sp=allcomb_sp(ramidx,:);
        numblock_sp=size(allcomb_sp,1);
    end
    for i=1:size(allcomb_sp,1)
        b1= round(center(1)+allcomb_sp(i,1)-(window_sp_fix/2));
        b2=round(center(2)-allcomb_sp(i,2)-(window_sp_fix/2));
        b3=round(center(1)+allcomb_sp(i,1)+(window_sp_fix/2));
        b4=round(center(2)-allcomb_sp(i,2)+(window_sp_fix/2));
        Eyelink('command','draw_box %d %d %d %d 15', b1, b2, b3,b4);

    end
    box1p= round(center(1)+x_fp-(window_fix/2));
    box2p=round(center(2)-y_fp-(window_fix/2));
    box3p=round(center(1)+x_fp+(window_fix/2));
    box4p=round(center(2)-y_fp+(window_fix/2));
    Eyelink('command','draw_box %d %d %d %d 15',box1p,box2p,box3p,box4p);
    % repeat the same saccade point for certain times in a block
    blocksp_x=repelem(allcomb_sp(:,1),cfg.numrepsp);
    blocksp_y=repelem(allcomb_sp(:,2),cfg.numrepsp);
    % start recording
    %Eyelink('StartRecording');
    % init result table
    Results=table;
    eye_used = el.LEFT_EYE;
    ErrorTime=0;
    ErrorStage=0;
    ErrorTrial=0;
    skip_trial=0;
    Num_tried=0;
  randOrder=cfg.prob(randperm(length(cfg.prob)));
    randper=repelem(randOrder, 2);
    % keep looping or set the number of successful trial wanted
    while trial_success>0
        switch(stage)
            case 'trial_new_start'
                if cfg.Skip
                    if Num_tried>=cfg.SkipTrialNum
                        skip_trial=skip_trial+1;
                    end
                end
                WaitSecs(0.1);
                Eyelink('StartRecording');
                [success_start, sample_start]=cclabPulse('A');

                Results.error_trial_start(trial_total)=Eyelink('Isconnected');
                if(Results.error_trial_start(trial_total)~=1)
                    Result.ErrorTS(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                % init flag for every new trial
                flag=0;
                % determine the saccade point coord for this trial
                if rem(trial_success+skip_trial,cfg.numrepsp*numblock_sp)~=0
                    x_sp=blocksp_x(rem(trial_success+skip_trial,numblock_sp*cfg.numrepsp));
                    y_sp=blocksp_y(rem(trial_success+skip_trial,numblock_sp*cfg.numrepsp));
                else
                    x_sp=blocksp_x(end);
                    y_sp=blocksp_y(end);
                end
                % determine the fixation point coord

                % Record fixation point and saccade point in result table
                Results.x_fp(trial_total)=cfg.fp_x;
                Results.y_fp(trial_total)=cfg.fp_y;
                Results.x_sp(trial_total)=x_sp/ppd;
                Results.y_sp(trial_total)=y_sp/ppd;

                % Eyelink message, table timing, trial start
                if flag==0
                    %                     status= Eyelink('IsConnected');
                    %
                    %                     disp(status)
                    Eyelink( 'Message', 'Trialstart %d',trial_total);
                    fprintf('TrialStart %d \n',trial_total)
                    Results.TrialStart(trial_total)=GetSecs;
                    flag=1;
                end
                if~cfg.polar
                    % cartesian
                    % if it is first trial, set success rate to zero
                    if trial_success==1
                        success_rate=0;
                        success_rate_location_string=' ';
                        % if it is after first trial
                    else
                        % list all the attemped trial and all x and y coord
                        temp=Results.TrialSuccess((Results.TrialAttemp==1));
                        tempx=unique(Results.x_sp);
                        tempy=unique(Results.y_sp);
                        % for all combinations of x and y coords
                        for i=1:size(tempx,1)
                            for j=1:size(tempy,1)
                                % list all the attemped trial for each x
                                % and y coord combination
                                temp_loc{i,j}=Results.TrialSuccess(Results.TrialAttemp==1&Results.x_sp==tempx(i)&Results.y_sp==tempy(j));
                                % if it is less than 20 attemp trials,
                                % calculate SR based on all attemped trials
                                if size(temp_loc{i,j},1)<=20
                                    success_rate_location(i,j)=100*sum(temp_loc{i,j})/size(temp_loc{i,j},1);
                                    Location{i,j}=[tempx(i),tempy(j)];



                                    % if it is more than 20 attemped trials, calculate SR based on past 20 attemped trials
                                elseif size(temp_loc{i,j},1)>20
                                    templ=temp_loc{i,j};
                                    success_rate_location(i,j)=100*sum(templ(end-19:end))/20;
                                    Location{i,j}=[tempx(i),tempy(j)];

                                end


                            end
                        end
                        % init string display on eyelink
                        success_rate_location_string=' ';
                        % for each x and y coord combination
                        for i=size(Location,2):-1:1
                            for j=1:size(Location,1)
                                % append successful rate string for each
                                % location
                                success_rate_location_string=append(success_rate_location_string,num2str(round(success_rate_location(j,i))),'||');

                            end
                        end
                        % clear the figure
                        clf;
                        % set the figure to suitable position for view

                        set(gcf,'Position',[0 550 560 420]);
                        % for each location
                        for i=size(Location,2):-1:1
                            for j=1:size(Location,1)
                                % plot the location and success rate by
                                % location
                                plot(Location{j,i}(1),Location{j,i}(2),'ro')
                                hold on
                                text(Location{j,i}(1)-0.2,Location{j,i}(2)-0.2,num2str(round(success_rate_location(j,i))))
                                hold on

                            end
                        end
                        % set xlim and y lim to make the figure larger
                        xlim([min(cfg.sp_x)-1 max(cfg.sp_x)+1])
                        ylim([min(cfg.sp_y)-1 max(cfg.sp_y)+1])
                        % draw now to reduce lag
                        drawnow
                        % if attemped trial less than 20, calculate over
                        % all location SR based on all attemped trials
                        if size(temp,1)<=20
                            success_rate=100*sum(Results.TrialSuccess(1:end))/sum(Results.TrialAttemp(1:end));
                            % if attemped trial more than 20, calculate over
                            % all location SR based on last 20 attemped trials
                        elseif size(temp,1)>20
                            success_rate=100*sum(temp(end-19:end))/size(temp(end-19:end),1);
                        end
                    end
                    % polar coord
                elseif cfg.polar
                    % init SR calculation
                    if trial_success==1
                        success_rate=0;
                        success_rate_location_string=' ';
                    else
                        % capture all attemped trials and location
                        temp=Results.TrialSuccess((Results.TrialAttemp==1));
                        tempdegree=allcomb_sp/ppd;
                        % for all location, capture the attemped trials
                        for i=1:size(tempdegree,1)

                            temp_loc{i}=Results.TrialSuccess(Results.TrialAttemp==1&Results.x_sp==tempdegree(i,1)&Results.y_sp==tempdegree(i,2));
                            % less than 20 attemped trials, calculate SR on
                            % all
                            if size(temp_loc{i},1)<=20
                                success_rate_location(i)=100*sum(temp_loc{i})/size(temp_loc{i},1);
                                Location{i}=[tempdegree(i,1),tempdegree(i,2)];



                                % more than 20 attemped trials, calculate SR on
                                % last 20 attemped trials
                            elseif size(temp_loc{i},1)>20
                                templ=temp_loc{i};
                                success_rate_location(i)=100*sum(templ(end-19:end))/20;
                                Location{i}=[tempdegree(i,1),tempdegree(i,2)];

                            end



                        end


                        % init SR string
                        success_rate_location_string=' ';
                        % for each location, append SR
                        for i=1:size(Location,2)

                            success_rate_location_string=append(success_rate_location_string,num2str(round(success_rate_location(i))),'||');


                        end
                        % clear figure
                        clf;

                        % set position of figure
                        set(gcf,'Position',[0 550 560 420]);
                        % plot
                        for i=size(Location,2):-1:1

                            plot(Location{i}(1),Location{i}(2),'ro')
                            hold on
                            text(Location{i}(1)-0.2,Location{i}(2)-0.2,num2str(round(success_rate_location(i))))
                            hold on


                        end


                        xlim([min(Results.x_sp)-1 max(Results.x_sp)+1])
                        ylim([min(Results.y_sp)-1 max(Results.y_sp)+1])
                        drawnow
                        % less than 20 trials, calculate all, more than 20
                        % trials, calculate last 20
                        if size(temp,1)<=20
                            success_rate=100*sum(Results.TrialSuccess(1:end))/sum(Results.TrialAttemp(1:end));
                        elseif size(temp,1)>20
                            success_rate=100*sum(temp(end-19:end))/size(temp(end-19:end),1);
                        end
                    end
                end
                % Eyelink message, SR by location
                if flag ==1
                    %                     Eyelink('Command', 'record_status_message "TRIAL %d Success %d Location %s "', trial_success,round(success_rate),success_rate_location_string);

                    flag=2;
                end




                %Clear screen on eyelink machine

                % Set used eye to Left eye as default





                % check if key is pressed in this stage
                checkkeys;

                % Move to stage, put on fixation point on the screen
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
                    boxsp1= round(center(1)+x_sp-(window_sp_fix/2));
                    boxsp2=round(center(2)-y_sp-(window_sp_fix/2));
                    boxsp3=round(center(1)+x_sp+(window_sp_fix/2));
                    boxsp4=round(center(2)-y_sp+(window_sp_fix/2));
                end
                %Check recording status, stop display if error
                Results.error_put_on_fp(trial_total)=Eyelink('Isconnected');
                if(Results.error_put_on_fp(trial_total)~=1)
                    Result.ErrorPOF(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end

                %                 % draw background
                %                 Screen('FillRect',window, el.backgroundcolour);
                %                 Screen('DrawingFinished',window);
                %                 Screen('Flip',window);

                % draw fixation point, update time
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                %                 Screen('FillRect', window, rectColor, baseRect);

                t_checkpoint=Screen('Flip',window);
                [success_end, sample_end]=cclabPulse('C');

                % draw box on eyelink machine, representing window of
                % accepted eye position
                %                 Eyelink('command','clear_screen %d', 0);
                %                 Eyelink('command','draw_box %d %d %d %d 15', box1, box2, box3,box4);

                % check if key is pressed
                checkkeys;
                % Eyelink message, matlab message put on fix point
                if flag==2
                    fprintf('put on fix %d \n',trial_total)
                    Eyelink('Message', 'PutOnFix %d',trial_total);

                    Results.PutOnFix(trial_total)=GetSecs;
                    flag=3;
                end
                % update stage
                stage='wait_for_fix_fp';

            case 'wait_for_fix_fp'
                Results.error_wait_for_fix_fp(trial_total)=Eyelink('Isconnected');
                if(Results.error_wait_for_fix_fp(trial_total)~=1)
                    Result.ErrorWFFF(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                % Eyelink and matlab message, wait for fix fp
                if flag==3
                    %                     disp('wait for fix fp')
                    %
                    %                     Eyelink('Message', 'WaitForFixFP %d',trial_total);
                    Results.WaitForFixFP(trial_total)=GetSecs;
                    flag=4;

                end

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
                    if flag==4
                        fprintf('FixInFP %d \n',trial_total)
                        Eyelink( 'Message', 'FixInFP %d',trial_total);
                        flag=5;

                        Results.FixInFP(trial_total)=GetSecs;
                    end
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
                Results.error_wait_for_hold_fp(trial_total)=Eyelink('Isconnected');
                if(Results.error_wait_for_hold_fp(trial_total)~=1)
                    Result.ErrorWFHF(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                % Matlab Eyelink message wait for hold fp
                if flag==5

                    %                     disp('wait for hold fp')
                    %                     Eyelink('Message', 'WaitForHoldFP');
                    flag=6;
                    Results.WaitForHoldFP(trial_total)=GetSecs;

                end



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
                    Results.HoldCompFPWOSP(trial_total)=GetSecs;
                    %                     Eyelink('Message','HoldCompFPWOSP %d',trial_total);
                    %                     fprintf('Hold Comp FP without SP %d',trial_total)
                    stage='put_on_sp';
                end
                % check if key is pressed
                checkkeys;
            case 'put_on_sp'
                trial_attemp=trial_attemp+1;
                Results.TrialAttemp(trial_total)=1;

                Results.error_put_on_sp(trial_total)=Eyelink('Isconnected');
                if(Results.error_put_on_sp(trial_total)~=1)
                    Result.ErrorPOS=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end


                % draw fixation point, update time
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                Screen('FillOval',window,sp_color, [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                %Screen('FillRect', window, rectColor, baseRect);

                t_checkpoint=Screen('Flip',window);
                [success_end, sample_end]=cclabPulse('C');

                if flag==6
                    % eyelink matlab message, put on SP
                    fprintf('Put on sp %d \n',trial_total)
                    Eyelink('Message', 'PutOnSP %d',trial_total);
                    flag=7;

                end
                Results.PutOnSP(trial_total)=t_checkpoint;

                % check key press
                checkkeys;
                stage='keep_hold_fp';
            case 'keep_hold_fp'
                Results.error_keep_hold_fp(trial_total)=Eyelink('Isconnected');
                if(Results.error_keep_hold_fp(trial_total)~=1)
                    Result.ErrorKHF(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                % eyelink matlab message, keep hold fp
                if flag==7

                    %                     disp('keep hold fp')
                    %                     Eyelink('Message', 'KeepHoldFP');
                    flag=8;
                    Results.KeepHoldFP(trial_total)=GetSecs;

                end



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
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_fp_sp
                    % eyelink matlab message, keep hold comp fp
                    Results.KeepHoldCompFP(trial_total)=GetSecs;

                    %                     Eyelink('Message', 'KeepHoldCompFP');
                    %                     disp('KeepHoldCompFP')
                    stage='put_off_sp';
                end
                % check if key is pressed
                checkkeys;
            case 'put_off_sp'



                if flag==8
                    % eyelink matlab message put off fp
                    fprintf('put_off_sp %d \n',trial_total);
                    Eyelink('Message', 'PutOffSP %d',trial_total);

                    flag=9;

                end
                % Draw the FP, update time
                Screen('FillRect',window, el.backgroundcolour);
                Screen('FillOval',window,fp_color, [center(1)-fpr+x_fp, center(2)-fpr-y_fp, center(1)+fpr+x_fp, center(2)+fpr-y_fp],5);
                %Screen('FillRect', window, rectColor, baseRect);

                t_checkpoint=Screen('Flip',window);
                [success_end, sample_end]=cclabPulse('C');

                Results.PutOffSP(trial_total)=t_checkpoint;
                % draw box on eyelink machine, representing window of
                % accepted eye position
                %                 Eyelink('command','clear_screen %d', 0);
                %                 Eyelink('command','draw_box %d %d %d %d 15', boxsp1, boxsp2, boxsp3,boxsp4);
                % mark as attemped trial
                % check key press
                checkkeys;
                stage='keep_hold_fp_with_fp';
            case 'keep_hold_fp_with_fp'
                Results.error_wait_for_fix_sp(trial_total)=Eyelink('Isconnected');
                if(Results.error_wait_for_fix_sp(trial_total)~=1)
                    Result.ErrorWFFS(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                if flag==9
                    % eyelink matlab message, wait for fix sp
                    %                     disp('wait for fix sp')
                    %                     Eyelink('Message', 'WaitForFixSP');
                    flag=10;
                    Results.KeepHoldFP_fp(trial_total)=GetSecs;

                end


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
                if not((x_eye >=box1)&&(x_eye <= box3)&&(y_eye >= (box2))&&(y_eye <=box4))
                    t_checkpoint=GetSecs;
                    stage='inter_trial_interval';
                elseif GetSecs-t_checkpoint>=cfg.t_keepfixation
                    % eyelink matlab message, fix in sp
                    if flag==10
                        Eyelink( 'Message', 'KeepHoldFixFP_fp %d',trial_total);
                        flag=11;
                        fprintf('KeepHoldFixFP_fp %d \n',trial_total);
                        Results.KeepHoldFixFP_fp(trial_total)=GetSecs;
                    end
                    stage='put_off_fp_sp';


                end


                % check if key is pressed
                checkkeys;
            case 'put_off_fp_sp'
                Screen('FillRect',window, el.backgroundcolour);
                %                 if rand>=0.0
                %                     Results.isSP(trial_total)=0;
                % %                     Screen('FillOval',window,[0 0 255 0], [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                %                 else
                %                     Screen('FillOval',window,sp2_color, [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                %                     Results.isSP(trial_total)=1;
                %
                %                 end
                %  Screen('FillRect', window, rectColor, baseRect);

                t_checkpoint=Screen('Flip',window);
                [success_end, sample_end]=cclabPulse('C');

                Results.PutOffFPSP(trial_total)=t_checkpoint;
                checkkeys;
                stage='wait_for_fix_sp';
            case 'wait_for_fix_sp'
                Results.error_wait_for_fix_sp(trial_total)=Eyelink('Isconnected');
                if(Results.error_wait_for_fix_sp(trial_total)~=1)
                    Result.ErrorWFFS(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                if flag==11
                    % eyelink matlab message, wait for fix sp
                    %                     disp('wait for fix sp')
                    %                     Eyelink('Message', 'WaitForFixSP');
                    flag=12;
                    Results.WaitForFixSP(trial_total)=GetSecs;

                end


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
                if ((x_eye >=boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <=boxsp4))
                    t_checkpoint=GetSecs;
                    % eyelink matlab message, fix in sp
                    if flag==12
                        Eyelink( 'Message', 'FixInSP %d',trial_total);
                        flag=13;
                        fprintf('FixInSP %d \n',trial_total);
                        Results.FixInSP(trial_total)=GetSecs;
                    end
                    stage='wait_for_hold_sp';

                elseif GetSecs-t_checkpoint>=cfg.t_waitfixation_sp
                    stage='inter_trial_interval';
                end


                % check if key is pressed
                checkkeys;
            case 'wait_for_hold_sp'
                Results.error_wait_for_hold_sp(trial_total)=Eyelink('Isconnected');
                if(Results.error_wait_for_hold_sp(trial_total)~=1)
                    Result.ErrorWFHS(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                % eyelink Matlab message, wait for hold sp
                if flag==13

                    %                     disp('wait for hold sp')
                    %                     Eyelink('Message', 'WaitForHoldSP');
                    flag=14;
                    Results.WaitForHoldFP(trial_total)=GetSecs;

                end




                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <= boxsp4))
                    t_checkpoint=GetSecs;

                    stage='inter_trial_interval';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_sp
                    % eyelink, matlab message, hold comp fp
                    Results.HoldCompFPWSP(trial_total)=GetSecs;
                    %                     Eyelink('Message', 'HoldCompFPWSP');
                    %                     disp('HoldCompFP With SP')
                    stage='reward';
                end
                % check if key is pressed
                checkkeys;
            case 'reward'
                Num_tried=0;
                Results.error_reward(trial_total)=Eyelink('Isconnected');
                if(Results.error_reward(trial_total)~=1)
                    Result.ErrorR(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end
                Screen('FillRect',window, el.backgroundcolour);
                % update time
                t_checkpoint=Screen('Flip',window);
                [success_end, sample_end]=cclabPulse('C');

                % matlab message reward and number of success trial
                % Give reward, if random reward is enabled and random
                % number is above threshold, give doble reward
                if cfg.randreward
                    if rand>=randper(trial_success)
                        stage='win_indication';



                    else
                        stage='loss_indication';





                    end
                else
                    % Eyelink matlab message, reward and reward amount

                    cclabReward(cfg.reward, 1, IRI);
                    Eyelink( 'Message', 'Reward %d,trial %d', cfg.reward,trial_total);
                    Results.RewardAmount(trial_total)=cfg.reward;
                    fprintf('reward amount %d,trial %d \n',cfg.reward,trial_total);
                    Results.RewardTime(trial_total)=GetSecs;




                end
            case 'win_indication'
                Screen('FillOval',window,sp_color, [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                t_checkpoint=Screen('Flip',window);
                Results.PutOnWIN(trial_total)=t_checkpoint;
                stage='keep_hold_result_win';
            case 'loss_indication'
                Screen('FillOval',window,sp_color, [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                t_checkpoint=Screen('Flip',window);
                Results.PutOnWIN(trial_total)=t_checkpoint;
                stage='keep_hold_result_loss';

            case 'keep_hold_result_win'
                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                if not((x_eye >= boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <= boxsp4))
                    t_checkpoint=GetSecs;

                    stage='ForcedTrialWin';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_sp
                    % eyelink, matlab message, hold comp fp
                    Results.HoldCompFPWSP(trial_total)=GetSecs;
                    %                     Eyelink('Message', 'HoldCompFPWSP');
                    %                     disp('HoldCompFP With SP')
                    stage='reward_win';
                end
            case 'keep_hold_result_loss'
                % check eye position
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                if not((x_eye >= boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <= boxsp4))
                    t_checkpoint=GetSecs;

                    stage='ForcedTrialLoss';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_sp
                    % eyelink, matlab message, hold comp fp
                    Results.HoldCompFPWSP(trial_total)=GetSecs;
                    %                     Eyelink('Message', 'HoldCompFPWSP');
                    %                     disp('HoldCompFP With SP')
                    stage='reward_loss';
                end
            case 'ForcedTrialWin'
                Screen('FillOval',window,sp_color, [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                t_checkpoint=Screen('Flip',window);
                Results.PutOnWIN(trial_total)=t_checkpoint;
                stage='FTwaitFixWin';
            case 'ForcedTrialLoss'
                Screen('FillOval',window,sp_color, [center(1)-spr+x_sp, center(2)-spr-y_sp, center(1)+spr+x_sp, center(2)+spr-y_sp],5);
                t_checkpoint=Screen('Flip',window);
                Results.PutOnWIN(trial_total)=t_checkpoint;
                stage='FTwaitFixLoss';
            case 'FTwaitFixWin'
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                if ((x_eye >=boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <=boxsp4))
                    t_checkpoint=GetSecs;
                    % eyelink matlab message, fix in sp
                    if flag==12
                        Eyelink( 'Message', 'FixInSP %d',trial_total);
                        flag=13;
                        fprintf('FixInSP %d \n',trial_total);
                        Results.FixInSP(trial_total)=GetSecs;
                    end
                    stage='wait_for_hold_sp_win';
                elseif GetSecs-t_checkpoint>=cfg.t_waitfixation_sp
                    stage='FTwaitFixWin';
                end
            case 'FTwaitFixLoss'
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                if ((x_eye >=boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <=boxsp4))
                    t_checkpoint=GetSecs;
                    % eyelink matlab message, fix in sp
                    if flag==12
                        Eyelink( 'Message', 'FixInSP %d',trial_total);
                        flag=13;
                        fprintf('FixInSP %d \n',trial_total);
                        Results.FixInSP(trial_total)=GetSecs;
                    end
                    stage='wait_for_hold_sp_loss';
                elseif GetSecs-t_checkpoint>=cfg.t_waitfixation_sp
                    stage='FTwaitFixLoss';
                end
            case 'wait_for_hold_sp_win'
                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <= boxsp4))
                    t_checkpoint=GetSecs;

                    stage='FTwaitFixWin';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_sp
                    % eyelink, matlab message, hold comp fp
                    Results.HoldCompFPWSP(trial_total)=GetSecs;
                    %                     Eyelink('Message', 'HoldCompFPWSP');
                    %                     disp('HoldCompFP With SP')
                    stage='reward_win';
                end
            case 'wait_for_hold_sp_loss'

                if Eyelink('NewFloatSampleAvailable') > 0
                    evt=Eyelink('NewestFloatSample');
                    x_eye=evt.gx(eye_used+1);
                    y_eye=evt.gy(eye_used+1);
                end
                % if eye position is not in the box, start a new trial with
                % new fixation point, update time, if eye is in the box and
                % hold for the amount of the time, go to reward stage
                if not((x_eye >= boxsp1)&&(x_eye <= boxsp3)&&(y_eye >= boxsp2)&&(y_eye <= boxsp4))
                    t_checkpoint=GetSecs;

                    stage='FTwaitFixLoss';
                elseif GetSecs-t_checkpoint>=cfg.t_fixation_sp
                    % eyelink, matlab message, hold comp fp
                    Results.HoldCompFPWSP(trial_total)=GetSecs;
                    %                     Eyelink('Message', 'HoldCompFPWSP');
                    %                     disp('HoldCompFP With SP')
                    stage='reward_loss';
                end
            case 'reward_win'
                Num_tried=0;
                Screen('FillRect',window, el.backgroundcolour);
                % update time
                t_checkpoint=Screen('Flip',window);
                cclabReward(cfg.reward, 2, IRI);
                % Eyelink matlab message, reward and reward amount
                Eyelink( 'Message', 'Reward %d,trial %d', cfg.reward*1.5,trial_total);
                fprintf('reward amount %d,trial %d \n',cfg.reward*1.5,trial_total)
                Results.RewardAmount(trial_total)=cfg.reward*2;
                Results.RewardTime(trial_total)=GetSecs;
                % if it is end of the block, shuffle the next block
                if rem(trial_success+skip_trial,cfg.numrepsp*numblock_sp)==0
                    ramidx_sp=randperm(size(allcomb_sp,1));
                    allcomb_sp=allcomb_sp(ramidx_sp,:);
                    blocksp_x=repelem(allcomb_sp(:,1),cfg.numrepsp);
                    blocksp_y=repelem(allcomb_sp(:,2),cfg.numrepsp);
                end
                % update time and success trial count
                t_checkpoint=GetSecs;
                trial_success=trial_success+1;
                Results.Reward(trial_total)=1;
                Results.TrialSuccess(trial_total)=1;
                % Go to inter trial interval
                stage='inter_trial_interval';
            case 'reward_loss'
                Num_tried=0;
                Screen('FillRect',window, el.backgroundcolour);
                % update time
                t_checkpoint=Screen('Flip',window);
                cclabReward(cfg.reward, 2, IRI);
                % Eyelink matlab message, reward and reward amount
                Eyelink( 'Message', 'Reward %d,trial %d', cfg.reward*1.5,trial_total);
                fprintf('reward amount %d,trial %d \n',cfg.reward*1.5,trial_total)
                Results.RewardAmount(trial_total)=cfg.reward*2;
                Results.RewardTime(trial_total)=GetSecs;
                % if it is end of the block, shuffle the next block
                if rem(trial_success+skip_trial,cfg.numrepsp*numblock_sp)==0
                    ramidx_sp=randperm(size(allcomb_sp,1));
                    allcomb_sp=allcomb_sp(ramidx_sp,:);
                    blocksp_x=repelem(allcomb_sp(:,1),cfg.numrepsp);
                    blocksp_y=repelem(allcomb_sp(:,2),cfg.numrepsp);
                end
                % update time and success trial count
                t_checkpoint=GetSecs;
                trial_success=trial_success+1;
                Results.Reward(trial_total)=1;
                Results.TrialSuccess(trial_total)=1;
                % Go to inter trial interval
                stage='inter_trial_interval';
            case 'inter_trial_interval'
                Num_tried=Num_tried+1;
                Results.error_iti(trial_total)=Eyelink('Isconnected');
                if(Results.error_iti(trial_total)~=1)
                    Result.ErrorITI(trial_total)=GetSecs;
                    ErrorTime(end+1)=GetSecs;
                    ErrorStage=stage;
                    ErrorTrial(end+1)=trial_total;
                    disp('error')
                end


                % Fill background grey
                Screen('FillRect',window, el.backgroundcolour);
                % update time
                t_checkpoint=Screen('Flip',window);
                [success_end, sample_end]=cclabPulse('B');

                Results.ITI(trial_total)=t_checkpoint;
                % Eyelink matlab message, iti
                fprintf('iti %d \n',trial_success);
                Eyelink('Message', 'Inter-Trial-Interval %d',trial_total);
                % update total trial count, save results
                trial_total=trial_total+1;
                WaitSecs(0.1); % Add 100 msec of data to catch final events before stopping
                Eyelink('StopRecording');
                Eyelink('SetOfflineMode'); % Put tracker in idle/offline mode


                % wait for iti
                WaitSecs(cfg.t_trialend);
                stage='trial_new_start';



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
                Screen('FillRect',window, [0 0 0]);
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