%calcFirstOrderStatsSWEv2.m

%DESCRIPTION: calculates first order stats for a shear wave colormap that
%has been converted to gray scale. This code excludes shear wave values of
%0, as these indicate regions where the machine could not detect the shear
%wave speed. If a mask is used during pre-processing, excluded areas should
%be indicated with a 0.
%INPUT: Image in double format, maximum shear wave speed or shear modulus
%value, depending on image 
% OUTPUT: 1st order stats (structure), all shear wave speed or modulus 
% values within the image

function [stats, data] = calcFirstOrderStatsSWEv2(grayscaleImage, maxShearWaveSpeed)

    shearWaveSpeedMap = double(grayscaleImage)./255.*maxShearWaveSpeed;
    data = shearWaveSpeedMap(shearWaveSpeedMap ~= 0);
    
    stats.Mean = mean(data);
    stats.Median = median(data);
    stats.Variance = var(data);
    stats.Skewness = skewness(data);
    stats.Kurtosis = kurtosis(data);
    
    tmp = grayscaleImage./255; %scales image from [0:255] to [0:1]
    tmp(tmp == 0) = NaN; %exclude 0 values from calculation
    stats.Entropy = entropy(tmp);
end