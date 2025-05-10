# Clinical-SWE-Measurement-Tool
Author: Georgina Flynn-Smith, 5/9/2025

Description:  This code iterates through a series of DICOM images obtained using the SuperSonic ultrasound machine.  For each image, it displays the image and the user places 3 circular regions of interest (ROI's) within the fascia.  The code then calculates the mean shear wave speed within these regions of interest.

MATLAB packages required:
1) Image Processing Toolbox
2) Statistics and Machine Learning Toolbox

Main code: clinical_SWS_measurement_tool.m

Suporting code:
1) getSuperimposedColormap.mlx  - this code subtracts out the background grayscale image from behind the colormap. Only needed if the opacity is set to less than 100%
2) transformSWEColormapToGrayscale.mlx - this code converts the colormap to grayscale for calculation
3) reconstructSWEColormapFromGrayscale.mlx - this code reconstructs the colormap from the grayscale map to confirm that the transformation occurred correctly
4) calcFirstOrderStatsSWEv2.m - this code calculates the first order statistics (distribution-based statistics such as mean, variance, skewness, kurtosis, etc.) of the shear wave speed distribution within each user defined ROI.


USE
1) User Inputs: the user can change the maximum shear wave speed (default is 10 m/s) and the opacity setting for the shear wave colormap (default is 100%) by updating these lines in section 1 of the code.  The user can also change the starting image number by updating the value for "i" (default is 1, which starts at teh first image in the series)
2) Running the code:
User uses the DICOM broser app to load the Series Details to the workspace.  User then clicks the "run" button to begin running the code.  The code will display the fist image, along with the image regions defined in the image metadata (shear wave region and grayscale region). When the cursor displays as a crosshair, the user can begin placing the first circular ROI on the GRAYSCALE portion of the image.  To place the ROI, the user clicks and drags. Once placed, the size of teh ROI can be scaled by dragging any of the black dots on the perimeter of the circle. The ROI can be moved by dragging the perimeter (anywhere other than the black dots).  Once the user is satisfied with placement and size of the ROI, click "enter" to save the location.  The crosshairs will appear again and the user can place the next ROI.  Note that once "Enter" has been pressed, any subsequent changes to the ROI will not save.  The default order for placing these ROI's is left, middle, right.
After the ROI's have been placed, the code will translate the ROI's to the shear wave portion of the image and display their location.  It will then isolate the colormap and convert it to a grayscale shear wave speed map (this step is computationally expensive and takes a long time). Next, the code will display the grayscale shear wave speed map only within the 3 designated ROI's. Lastly, the code will calculate the mean shear wave speed within each ROI and export the Image number and 3 means to a spreadsheet.  The default spreadsheet naming convention is PatientID_ExamDate_ShearWaveSpeeds.xlsx (e.g. TLF2024-3_20240311_ShearWaveSpeeds.xlsx), and the data for each image will be listed in a separate row. After the code iterates through all images in the series, the full shear wave speed 
   
