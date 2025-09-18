%clinical_SWS_measurement_tool.m
%This script calculates shear wave speed from 3 circular ROI's manually
%placed on the image to recapitulate the clinical measurement technique
% using on the SuperSonic Machine

%written by Georgina Flynn-Smith 5/9/2025
%updated 5/28/2025: removed color from region boxes (faceAlpha = 0), added
%save function to save figure displaying all 3 circular ROI's, updated
%label text color, updated grayscale display for better visualization

%updated 6/13/2025 to correct shear wave speed calculation error. Also 
% corrected saving error for .mat file.

%Inputs: SeriesDetails 
%Outputs: excel spreadsheet with shear wave speed measurements; .mat file
%with all shear wave speed values within each of the 3 ROI's for all images
%in the series

%Notes: Offset calculation updated!

%% 1. USER INPUTS 
%review images beforehand and input here
opacity = 100; %percent
maxShearModulus = 300; %needs to be modulus, not speed
i=1; %change if you need to start partway through the series

%% 2. START CODE
%code gets all the initial information needed to analyze the image set
%close existing windows, clear command window
close all; clc;

%obtain file names from the series details
files = seriesDetails.Filenames{1};
series_length = length(files);

%obtain data labels from first image in series
file = files(1);
info = dicominfo(file);
ID = info.PatientID;
date = info.StudyDate;

%makeBox creates a box using defined region boundaries.  This is used in
%later sections to draw a box around regions extracted from the image
%metadata.  
makeBox = @(region) double([region.RegionLocationMinX0+1
region.RegionLocationMinY0+1
region.RegionLocationMaxX1-region.RegionLocationMinX0
region.RegionLocationMaxY1-region.RegionLocationMinY0]);

%initialize output
output = cell(series_length,4);
%filename
filename = strcat(ID, "_", date, "_ShearWaveSpeeds.xlsx");
column_headers = {"Image Name", "Left SWS (m/s)", "Middle SWS (m/s)", "Right SWS (m/s)"};
writecell(column_headers, filename,'Range','A:D');

%% 3. WHILE LOOP TO ANALYZE SWE IMAGES IN THE SERIES
%cycles through all images in series
while i <= series_length  
        
    % get image info
    file = files(i);
    info = dicominfo(file);

    %identify only SWE images, which have 3 regions defined in the
    %ultrasound metadata
    if numel(fieldnames(info.SequenceOfUltrasoundRegions)) == 3

        %% 3.A DISPLAY IMAGE & IDENTIFY REGIONS
        
        %read image
        [raw_img, ~, ~] = dicomread(file);
        raw_img = raw_img(:, :, :, 1);
        imnum = regexp(file, 'I\d\d\d\d\d\d\d', 'match');

        %display image 
        figure()
        imshow(raw_img)

        %identify regions
        %SWE imgage region
        sweImgBox = makeBox(info.SequenceOfUltrasoundRegions.Item_1);
        %B-Mode image region
        bModeImgBox = makeBox(info.SequenceOfUltrasoundRegions.Item_3);
        %SWE colormap region
        colormapRegionBox = makeBox(info.SequenceOfUltrasoundRegions.Item_2);
    
        %Crop colormap region box to eliminate white borders
        colormapRegionBox = colormapRegionBox + [2; 2; -5; -5]; 
    
        %display boxes to confirm region boundaries 
        %optional - recommend performing for first image in series to confirm
        SWEImg = drawrectangle('Position', sweImgBox',"Color","Y", 'FaceAlpha', 0);
        BmodeImg = drawrectangle('Position',bModeImgBox',"Color","B", 'FaceAlpha', 0);
        colormapBox = drawrectangle('Position', colormapRegionBox',"Color","G", 'FaceAlpha', 0);
    
        %calculate offset between SWE & B-mode image regions
        %This offset is used to mirror the boundaries of the colormap region onto the B-mode image.
        offset = sweImgBox(1:2) - bModeImgBox(1:2);
    
        %display colormap region boundary & new (offset) region boundary in b-mode
        %portion of image
        GSBox = [colormapRegionBox(1) - offset(1); colormapRegionBox(2)-offset(2); colormapRegionBox(3); colormapRegionBox(4)];
        drawrectangle('Position', GSBox', "Color", "R", 'FaceAlpha', 0);
        
        %% 3.B USER PLACES 3 ROI'S
        %draw on greyscale portion of image
        left_roi = drawcircle('FaceAlpha', 0, 'LineWidth', 1, 'MarkerSize', 0.5, 'Color', 'g','InteractionsAllowed', 'all', 'Label', 'Left ROI', 'LabelAlpha', 0.2, LabelTextColor="w"); 
        pause()
        left_center = left_roi.Center;
        left_radius = left_roi.Radius;
    
        middle_roi = drawcircle('FaceAlpha', 0, 'LineWidth', 1, 'MarkerSize', 0.5, 'Color', 'r','InteractionsAllowed', 'all', 'Label', 'Middle ROI','LabelAlpha', 0.2, LabelTextColor="w"); 
        pause()
        middle_center = middle_roi.Center;
        middle_radius = middle_roi.Radius;
    
        right_roi = drawcircle('FaceAlpha', 0, 'LineWidth', 1, 'MarkerSize', 0.5, 'Color', 'b','InteractionsAllowed', 'all', 'Label', 'Right ROI','LabelAlpha', 0.2, LabelTextColor="w"); 
        pause()
        right_center = right_roi.Center;
        right_radius = right_roi.Radius;
         
        %save figure displaying 3 ROI's
        saveas(gcf, strcat(ID, '_', imnum, '.jpg'))

        %% 3.C PRE-PROCESS SWE PORTION OF IMAGE
        %translate each ROI to shear wave portion of image
        if left_center(1,1) < offset (1,1) | left_center(1,2) > offset(2,1)
            left_center(1,1) = left_center(1,1) + offset(1,1);
            left_center(1,2) = left_center(1,2) + offset(2,1);
        end
    
        if middle_center(1,1) < offset (1,1) | middle_center(1,2) > offset(2,1)
            middle_center(1,1) = middle_center(1,1) + offset(1,1);
            middle_center(1,2) = middle_center(1,2) + offset(2,1);
        end
    
        if right_center(1,1) < offset (1,1) | right_center(1,2) > offset(2,1)
            right_center(1,1) = right_center(1,1) + offset(1,1);
            right_center(1,2) = right_center(1,2) + offset(2,1);
        end
    
        % display drawn ROI's on SWE region of image, create mask for each
        figure
        imshow(raw_img)
        drawrectangle('Position', colormapRegionBox');
        left_roi = drawcircle('Center', left_center, 'Radius', left_radius, 'FaceAlpha', 0, 'LineWidth', 1, 'Color', 'g', 'MarkerSize', 0.1, 'InteractionsAllowed', 'none', 'Label', 'Left ROI', 'LabelAlpha', 0);
        left_mask = createMask(left_roi);
    
        middle_roi = drawcircle('Center', middle_center, 'Radius', middle_radius, 'FaceAlpha', 0, 'LineWidth', 1, 'Color', 'r', 'MarkerSize', 0.1, 'InteractionsAllowed', 'none', 'Label', 'Middle ROI','LabelAlpha', 0);
        middle_mask = createMask(middle_roi);
    
        right_roi = drawcircle('Center', right_center, 'Radius', right_radius, 'FaceAlpha', 0, 'LineWidth', 1, 'Color', 'b', 'MarkerSize', 0.1, 'InteractionsAllowed', 'none', 'Label', 'Right ROI', 'LabelAlpha', 0);
        right_mask = createMask(right_roi);

           
        %crop masks to size of colormapRegionBox
        cropped_left_mask = left_mask(colormapRegionBox(2,1):(colormapRegionBox(2,1) + colormapRegionBox(4,1)), colormapRegionBox(1,1):(colormapRegionBox(1,1) + colormapRegionBox(3,1)));
        cropped_middle_mask = middle_mask(colormapRegionBox(2,1):(colormapRegionBox(2,1) + colormapRegionBox(4,1)), colormapRegionBox(1,1):(colormapRegionBox(1,1) + colormapRegionBox(3,1)));
        cropped_right_mask = right_mask(colormapRegionBox(2,1):(colormapRegionBox(2,1) + colormapRegionBox(4,1)), colormapRegionBox(1,1):(colormapRegionBox(1,1) + colormapRegionBox(3,1)));
    
        % %display cropped masks
        % figure
        % imshow(cropped_left_mask)
        % figure
        % imshow(cropped_middle_mask)
        % figure
        % imshow(cropped_right_mask)
    
        %if opacity <100%, subtract out background greyscale image
        if opacity < 100       
            %isolate colormap by "subtracting" out background image from the
            %entire SWE colormap region using alpha composition formula 
            alpha = opacity/100;
            [~, croppedSWEImage] = getSuperimposedColormap(raw_img, colormapRegionBox', offset, alpha);  
        elseif opacity == 100
            %if opacity is 100%, just crop image colormap box
            croppedSWEImage = raw_img(colormapRegionBox(2,1):(colormapRegionBox(2,1) + colormapRegionBox(4,1)), colormapRegionBox(1,1):(colormapRegionBox(1,1) + colormapRegionBox(3,1)),:);
        end
    
        %display isolated colormap
        figure
        imshow(croppedSWEImage)
    
        % define the color range used for the SWE map, where blue is the low end
        % and red is the high end
        map = double(uint8(jet(900)*255)); 
        
        % transform the SWE colormap from color domain to grayscale domain
        % (note this step is very time consuming)
        grayscaleSWEImage = transformSWEColormapToGrayscale(croppedSWEImage, map);
        figure
        imshow(grayscaleSWEImage, [0,0.5*255]) %display range decreased for better visualization

        % % reconstruct image to verify transformation was successful
        % reconstructedImage = reconstructSWEColormapFromGrayscale(grayscaleSWEImage, map);
        % figure
        % imshow(reconstructedImage)
    
        %crop grayscale colormap to user-defined circular ROI's
        left_GS = grayscaleSWEImage.*uint8(cropped_left_mask);
        % figure()
        % imshow(left_GS)
        middle_GS = grayscaleSWEImage.*uint8(cropped_middle_mask);
        % figure()
        % imshow(middle_GS)
        right_GS = grayscaleSWEImage.*uint8(cropped_right_mask);
        % figure()
        % imshow(right_GS)
        %display combined image to reduce number of figures
        combined = left_GS+middle_GS+right_GS;
        figure()
        imshow(combined, [0,0.5*255]) %display range decreased for better visualization

        %pause to allow user to review output images
        pause(5)


        %% 3.D CALCULATE SWE VALUES
        [left_firstOrderStats, left_shearWaveSpeeds] = calcFirstOrderStatsSWEv3(left_GS, maxShearModulus);
        left_meanSWS = left_firstOrderStats.Mean;
        [middle_firstOrderStats, middle_shearWaveSpeeds] = calcFirstOrderStatsSWEv3(middle_GS, maxShearModulus);
        middle_meanSWS = middle_firstOrderStats.Mean;
        [right_firstOrderStats, right_shearWaveSpeeds] = calcFirstOrderStatsSWEv3(right_GS, maxShearModulus);
        right_meanSWS = right_firstOrderStats.Mean;

        %% 3.E APPEND TO EXCEL SPREADSHEET
        %update output with mean values (columns 1-4)
        output{i,1} = imnum;
        output{i,2} = left_meanSWS;
        output{i,3} = middle_meanSWS;
        output{i,4} = right_meanSWS;
        %update with full shear wave speed data (columns 5-7)
        output{i,5} = left_shearWaveSpeeds;
        output{i,6} = middle_shearWaveSpeeds;
        output{i,7} = right_shearWaveSpeeds;

        %write to excel
        w = output(i,1:4);
        writecell(w, filename,'WriteMode', 'append');
        disp(['Shear wave data for image ' imnum ' has been saved to the datasheet. \n'])

    end % end of if loop to only analyze shear wave images

    %move on to next image
    i=i+1;
    close all;
    
end % end of while loop

%save full output in case it's needed later
save([ID '_' date '_' 'Texture Parameters'])
    

