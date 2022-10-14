function [tox] = kbddemo(nLaps, thrms)

    % matlab will block keyboard input - keypresses will not end up on
    % command line. 
    % This call should be paired with a ListenChar(0) call, which lets
    % keyboard input reach the command line. 
    % If script crashes, or otherwise exits WITHOUT calling ListenChar(0), 
    % you won't be able to type in matlab, and you may need to ^C to 
    % restore proper keyboard behavior. 
    ListenChar(2);

    % Consistent names for each keyboard key, independent of platform 
    KbName('UnifyKeyNames');    


    iQuit = 0;
    lapCount = 0;
    state = 'up';
    timerVal = tic;
    tox=zeros(nLaps, 1);
    while ~iQuit && lapCount < nLaps
        [keyIsDown, ~, keyCode]=KbCheck;
        switch (state)
            case 'up'
                if keyIsDown
                    state = 'down';
                    if ~keyCode(KbName('q'))

                        % Detecting multiple keys is hard - only recognized
                        % as two keys if they're pressed at the same time
                        % (this on my linux machine). 
                        if sum(keyCode) == 1
                            fprintf('Transition to down, key %d = %s\n', find(keyCode), KbName(keyCode));
                        else
                            codes=find(keyCode);
                            for code=[1:length(codes)]
                                fprintf('Transition to down, multiple keys %d = %s\n', codes(code), KbName(codes(code)));
                            end
                        end
                    else
                        fprintf('Quit\n');
                        iQuit = 1;
                    end
                end
            case 'down'
                if (~keyIsDown)
                    state = 'up';
                    fprintf('Transition to up\n');
                end
        end
        lapCount = lapCount + 1;    % increment here, this is the first/second/third/etc lap...
        tox(lapCount) = toc(timerVal);

        if (thrms>0)
            WaitSecs(thrms/1000);
        end
    end
    ListenChar(0);
    fprintf('%d laps, elapsed time: %f sec,  per lap %f ms\n', lapCount, max(tox), mean(diff(tox(1:lapCount)) * 1000));
end