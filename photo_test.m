% Clear the workspace and the screen
sca;
close all;
clear;
allColors = [255 255 255];
baseRect = [0 0 200 200];
backgroundColor=[128 128 128];
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
%Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = Screen('OpenWindow', screenNumber, backgroundColor); % Open graphics window

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);





% Draw the rect to the screen
Screen('FillRect', window, allColors, baseRect);

% Flip to the screen
Screen('Flip', window);

% Wait for a key press
KbStrokeWait;

% Clear the screen
sca;