imgDir = 'D:\Wenqing\Foraging\Natural\';
imgFiles = dir(fullfile(imgDir, 'Image*.bmp')); % Change the file extension to match your images
numImages = length(imgFiles);
fig = figure;
currentImage = 1;
img = imread(fullfile(imgDir, imgFiles(currentImage).name));
imshow(img);
while true

    w = waitforbuttonpress;
    if w == 0
        clickType = get(fig, 'SelectionType');
        if strcmp(clickType, 'alt')
            % Show a message box to confirm image deletion
            msg = sprintf('Are you sure you want to delete %s?', imgFiles(currentImage).name);
            result = questdlg(msg, 'Delete Image', 'Yes', 'No', 'No');
            if strcmp(result, 'Yes')
                % Delete the current image
                delete(fullfile(imgDir, imgFiles(currentImage).name));
                numImages = numImages - 1;
                imgFiles(currentImage) = [];
                if currentImage > numImages
                    currentImage = numImages;
                end
                % Show a message box to confirm image deletion
                msgbox(sprintf('%s has been deleted.', imgFiles(currentImage).name));
                % Display the next image
                img = imread(fullfile(imgDir, imgFiles(currentImage).name));
                imshow(img);
            end
        end
    else % Keyboard key press
        key = get(fig, 'CurrentKey');
        if strcmp(key, 'leftarrow') % Left arrow
            % Display the previous image
            if currentImage > 1
                currentImage = currentImage - 1;
                img = imread(fullfile(imgDir, imgFiles(currentImage).name));
                imshow(img);
            end
        elseif strcmp(key, 'rightarrow') % Right arrow
            % Display the next image
            if currentImage < numImages
                currentImage = currentImage + 1;
                img = imread(fullfile(imgDir, imgFiles(currentImage).name));
                imshow(img);
            end
        elseif strcmp(key, 'escape') % Check for Escape key press
            close(fig); % Close the figure and exit the script
            return;
        end
    end
end
