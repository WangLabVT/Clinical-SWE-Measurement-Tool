%calcFirstOrderStatsSWEv2.m

%Updated 6/13/2025 to convert shear modulus to shear wave speed, using
%relation specific to SuperSonic machines. Removed entropy calculation.

%DESCRIPTION: calculates first order stats for a shear wave colormap that
%has been converted to gray scale. This code excludes shear wave values of
%0, as these indicate regions where the machine could not detect the shear
%wave speed. If a mask is used during pre-processing, excluded areas should
%be indicated with a 0.

%INPUT: Image in double format, maximum shear modulus value (must be
%modulus, shear wave speed does not have a linear relationship with
%colormap)

% OUTPUT: 1st order stats (structure), all shear wave speed
% values within the image

function [stats, speed_data] = calcFirstOrderStatsSWEv2(grayscaleImage, maxShearModulus)
    %convert from GS values to modulus values, extract data from map
    shearWaveModulusMap = double(grayscaleImage)./255.*maxShearModulus;
    mod_data = shearWaveModulusMap(shearWaveModulusMap ~= 0);

    %convert from modulus to speed
    speed_data = 0.0190+0.5733.*sqrt(mod_data); %experimentally determined relationship
    
    stats.Mean = mean(speed_data);
    stats.Median = median(speed_data);
    stats.Variance = var(speed_data);
    stats.Skewness = skewness(speed_data);
    stats.Kurtosis = kurtosis(speed_data);
    
end