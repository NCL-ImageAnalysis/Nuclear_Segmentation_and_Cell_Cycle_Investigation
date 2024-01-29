//Please Note: This is an ImageJ macro
//Developed by George Merces, Newcastle University, 21.12.2023
//In a Project with Connor Gilkes-Imeson, Newcastle University
//This macro aims to automate the segmentation of nuclei from monolayer
//Tissue culture cells, identify cells undergoing a specific stage
//Of cell division, and allow for interrogation of genetic material
//Loss within this process

//Define the Home Folder
homeFolder = getDirectory("Choose The Home Folder Containing All Other Folders");
//Define the Raw Images Folder
rawFolder = getDirectory("Choose The Home Folder Containing Your Raw Images");


//Set Measurement Parameters for Measure Function
run("Set Measurements...", "area mean standard modal min centroid center perimeter bounding fit shape feret's integrated median skewness kurtosis area_fraction stack display redirect=None decimal=3");
//Defines the parameter to allow for arrays to be utilised later
setOption("ExpandableArrays", true);

//Allows the Macro to Use BioFormats Importer
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use use_file copy_row save_column save_row");
run("Bio-Formats Macro Extensions");



//Create new folders for the cropped segmented and raw images
tifFolder = homeFolder + "Cropped_Tiff_Import/";
if (File.isDirectory(tifFolder) < 1) {
	File.makeDirectory(tifFolder); 
}

//Create Folders Where Necessary for Saving Output Images and ROI Files

//Creates a Folder to Save the Nuclear Channel Tiles
nuclearFolder = homeFolder + "Nuclear_Channel/";
if (File.isDirectory(nuclearFolder) < 1) {
	File.makeDirectory(nuclearFolder); 
}
//Creates a Folder to Save the Segmented Nuclear Channel Tiles
nuclearSegFolder = homeFolder + "Nuclear_Segmented/";
if (File.isDirectory(nuclearSegFolder) < 1) {
	File.makeDirectory(nuclearSegFolder); 
}
//Creates a Folder to Save the Nuclear Channel Tiles Nuclear ROIs with all Nuclei
nuclearROIFolder = homeFolder + "Nuclear_ROI/";
if (File.isDirectory(nuclearROIFolder) < 1) {
	File.makeDirectory(nuclearROIFolder); 
}
//Creates a Folder to Save the Nuclear Channel Tiles Nuclear ROIs with Only Nuclei Meeting Criteria for Inclusion
nuclearROIModFolder = homeFolder + "Nuclear_ROI_Mod/";
if (File.isDirectory(nuclearROIModFolder) < 1) {
	File.makeDirectory(nuclearROIModFolder); 
}
//Creates a Folder to Save the Channel Two Tiles
chanTwoFolder = homeFolder + "Channel_Two_Images/";
if (File.isDirectory(chanTwoFolder) < 1) {
	File.makeDirectory(chanTwoFolder); 
}
//Creates a Folder to Save the Channel Three Tiles
chanThreeFolder = homeFolder + "Channel_Three_Images/";
if (File.isDirectory(chanThreeFolder) < 1) {
	File.makeDirectory(chanThreeFolder); 
}
//Creates a Folder to Save the Inidividual Cropped Nuclei in Just the Nuclear Channel
singleCellFolder = homeFolder + "Single_Cell_Folder/";
if (File.isDirectory(singleCellFolder) < 1) {
	File.makeDirectory(singleCellFolder); 
}
//Creates a Folder to Save the Inidividual Cropped Nuclei in a Stack of All Channels
singleCellStackFolder = homeFolder + "Single_Cell_Stack_Folder/";
if (File.isDirectory(singleCellStackFolder) < 1) {
	File.makeDirectory(singleCellStackFolder); 
}


//Creates a List of All the Images in your Raw Folder
list = getFileList(rawFolder);
l = list.length;
//Prints the names of all images within this folder for manual checking when necessary
for (i=0; i<l; i++) {
	print("i Number: " + i + "    =     File name: " + list[i]);
}

//Clears the Results Window and the ROI Manager Prior to Starting Analysis
run("Clear Results");
roiManager("reset");

//For Each Raw Image, returns the size of the image (XY) and crops to create tiles to allow for further analysis
//Of images at reasonable pixel dimensions, creating 400 tiles from a single image
for (i=0; i<l; i++) {
	//Defines the Image name and file location
	fileName = rawFolder + list[i];
	//Gets the XY Dimensions of the Image
	Ext.setId(fileName);
	Ext.getSizeX(sizeX)
	Ext.getSizeY(sizeY)
	//Creates empty arrays for defining the tiling grid
	xArray = newArray();
	yArray = newArray();
	//Creates arrays of the tiles to be generated
	xInt = Math.round(sizeX/20);
	yInt = Math.round(sizeY/20);
	for (j = 0; j < 20; j++) {
		xArray = Array.concat(xArray, xInt*j);
		yArray = Array.concat(yArray, yInt*j);
	}
	imgNum = 1;
	//For each X axis array point
	for (k = 0; k < xArray.length; k++) {
		//For each Y axis array point
		for (j = 0; j < yArray.length; j++) {
			//Opens the defined image
			run("Bio-Formats Importer", "open=" + fileName + " color_mode=Default crop rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT x_coordinate_1=" + xArray[k] + " y_coordinate_1=" + yArray[j] + " width_1=" + xInt + " height_1=" + yInt + " series_1");
			fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
			saveName = tifFolder + fileNameRaw + imgNum + ".tif";
			//Saves the image as a Tiff
			saveAs("Tiff", saveName); 
			//Split the Image into Constituent Channels
			run("Stack to Images");
			//Save Each Channel to Appropriate Location in Appropriate Folder
			saveName = chanThreeFolder + fileNameRaw + imgNum + ".tif";
			saveAs("Tiff", saveName);
			close();
			saveName = chanTwoFolder + fileNameRaw + imgNum + ".tif";
			saveAs("Tiff", saveName);
			close();
			saveName = nuclearFolder + fileNameRaw + imgNum + ".tif";
			saveAs("Tiff", saveName);
			//Close Any Open Images
			close("*");
			imgNum = imgNum + 1;
		}
	}
}	

	
//Creates a List of All the Images in your Nuclear Folder
list = getFileList(nuclearFolder);
l = list.length;
//For Each Nuclear Channel Image scales down by a linear factor of 4 to allow for 
//faster StarDist processing for nuclear segmentation
for (i=0; i<l; i++) {
	//Resets the ROI Manager to Make sure Only Real ROIs are Saved
	roiManager("reset");
	//Open the Image
	fileName = nuclearFolder + list[i];
	open(fileName);
	imgName = getTitle();
	//Converts the nuclear probability image to 8-bit format to allow for subsequent thresholding
	run("8-bit");
	//Gets the image XY dimensions
	getDimensions(width, height, channels, slices, frames);
	originalHeight = height;
	originalWidth = width;
	//Scales the image down by a linear factor of 4
	run("Scale...", "x=0.25 y=0.25 interpolation=None create");
	getDimensions(width, height, channels, slices, frames);
	//Applys a slight Gaussian blur to the image to improve StarDist nuclear segmentation
	run("Gaussian Blur...", "sigma=4");
	//Commands the Plugin "StarDist" to segment the probability map to find the nuclei
	imgName = getTitle();
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'" + imgName + "', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.4', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	//Saves the output regions of interest to an appropriate location if any Nuclei have been identified
	n = roiManager("count");
	if (n > 0) {
		//Create a blank image to draw on the nuclei for to determine cell boundary locations
		newImage("Untitled", "8-bit black", width, height, 1);
		//For each nucleus in the ROI manager
	    for (j=0; j<n; j++) {
	    	//Select the ROI
	    	roiManager("select", j);
	    	//Fill the area of the ROI with black to prevent summation of multiple touching nuclei into one super-nucleus
	    	setForegroundColor(0, 0, 0);
			roiManager("Fill");
			//Re-selects the ROI
			roiManager("select", j);
			//Shrinks the ROI down by 3 pixels
			run("Enlarge...", "enlarge=-3");
			//Fills the ROI with white for the particle analyser to find later
			roiManager("update");
			setForegroundColor(255, 255, 255);
			roiManager("Fill");
			roiManager("deselect");
	    }
	}
	//Creates a blank image if no nuclei are identified
	if (n == 0) {
		newImage("Untitled", "8-bit black", width, height, 1);
	}
	//Scales the image back to its original size prior to StarDist analysis
	roiManager("deselect");
	run("Scale...", "x=4 y=4 interpolation=None create");
	//Saves the binary nuclear image to the appropriate folder location
	saveName = nuclearSegFolder + list[i];
	saveAs("Tiff", saveName);
	//Resets the ROI manager ready for particle analysis
	roiManager("reset");
	//Identifies all nuclei at the correct scaling from the binary nuclear image
	run("Analyze Particles...", "add");
	//Saves the identified ROIs to the appropriate folder location
	saveFile = list[i];
	saveFileRaw = substring(saveFile, 0, (lengthOf(saveFile)-4));
	roiSaveName = nuclearROIFolder + saveFileRaw + ".zip";
	//If no nuclei are identified, adds a single ROI to allow macro to continue
	//This object will be later excluded during analysis
	n = roiManager("count");
	if (n == 0) {
		makeOval(1, 1, 1, 1);
		roiManager("Add");
	}
	roiManager("save", roiSaveName);
	//Resets the ROI Manager and closes open images
	roiManager("reset");
	close("*");
}


// set global variables for Ilastik Project
pixelClassificationProject = homeFolder + "20231128_Cell_Type.ilp";
outputType = "Probabilities"; //  or "Segmentation"
inputDataset = "data";
outputDataset = "exported_data";
axisOrder = "tzyxc";
compressionLevel = 0;

//Defines the output location for Ilastik probability maps
foldertoProcess = nuclearFolder;
folderforOutput = homeFolder + "Ilastik_Probability_Output/";
if (File.isDirectory(folderforOutput) < 1) {
	File.makeDirectory(folderforOutput); 
}

//Creates list of files for analysis
list = getFileList(nuclearFolder);
list = Array.sort(list);
l = list.length;
//Performs Ilastik probability mapping based on trained model developed as part of this project
//The model has been trained to identify nuclei that are in a specific stage in the cell cycle
for (i=0; i<l; i++) {
	//Defines the image to be processed
	fileName = foldertoProcess + list[i];
	//Used to confirm if image has already been processed
	testName = folderforOutput + list[i];
	//If a probability map does not already exist for this image...
	if( File.exists(testName) == 0){
		print("Creating New Probability Map");
		//Opens the image to be processed
		open(fileName);
		inputImage = getTitle();
		//Performed Ilastik probability mapping on the image
		pixelClassificationArgs = "projectfilename=[" + pixelClassificationProject + "] saveonly=false inputimage=[" + inputImage + "] pixelclassificationtype=" + outputType;
		run("Run Pixel Classification Prediction", pixelClassificationArgs);
		//Converts to 8-bit format
		run("8-bit");
		//Saves the probability map to the appropriate folder
		saveAs("Tiff", folderforOutput + list[i]);
		close("*");
	}
	//If a probability map already exists...
	else{
		print("Probability Map Already Existed");
	}
}


//Creates a List of All the Images in your Nuclear Folder
list = getFileList(nuclearFolder);
list = Array.sort(list);
l = list.length;
//For Each nuclear image, checks each identified nucleus and records metrics
//used to determine if nucleus is of interest or not
for (i=0; i<l; i++) {
	//Opens the nuclear image
	fileName = nuclearFolder + list[i];
	open(fileName);
	nuclear = getTitle();
	//Opens the associated probability map
	fileName = folderforOutput + list[i];
	open(fileName);
	probMap = getTitle();
	//Selects the Nuclear channel image
	selectWindow(nuclear);
	//Opens the relevant nuclear ROI file
	saveFile = list[i];
	saveFileRaw = substring(saveFile, 0, (lengthOf(saveFile)-4));
	roiSaveName = nuclearROIFolder + saveFileRaw + ".zip";
	roiManager("open", roiSaveName);
	n = roiManager("count");
	//Creats an empty array to store the nuclei that don't meet the requirements to be of interest
	deleteArray = newArray();
	roiManager("deselect");
	//Performs a measurement of the whole image to determine the mean intensity level
	run("Measure");
	subVal = getResult("Mean");
	//Uses the mean intensity value to subtract from each pixel in the image
	run("Subtract...", "value=" + subVal);
	//For each nucleus identified by StarDist
	for (j = 0; j < n; j++) {
		//Selects the appropriate nucleus
		roiManager("select", j);
		//Measures the nucleus ROI on the nuclear channel and stores relevant measurements
		run("Measure");
		area = getResult("Area");
		major = getResult("Major");
		minor = getResult("Minor");
		circ = getResult("Circ.");
		intDen = getResult("IntDen");
		minFeret = getResult("MinFeret");
		roundness = getResult("Round");
		mean = getResult("Mean");
		median = getResult("Median");
		AR = getResult("AR");
		//Selects the probability map
		selectWindow(probMap);
		//Selects the appropriate nucleus and measures the probability intensity of the ROI
		roiManager("select", j);
		run("Measure");
		meanProb = getResult("Mean");
		//If nucleus meets any of the below exclusion conditions, it is noted for deletion from the ROI list
		if (median < 2*subVal) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (median > 10*subVal) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (area > 70) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (major < 10) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (major > 20) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (minor > 9) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (minor < 4) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (AR >3) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (roundness > 0.7) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (roundness < 0.3) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (circ>0.8) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (circ<0.6) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (intDen>850000) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		else if (minFeret>9) {
			deleteArray = Array.concat(deleteArray,j);		
		}	
		else if (meanProb < 51) {
			deleteArray = Array.concat(deleteArray,j);		
		}
		selectWindow(nuclear);
	}
	
	
	
	//Deletes all nuclei that do not meet requirements from the ROI list
	mod = 0;
	for (k = 0; k < deleteArray.length; k++) {
		roiManager("select", deleteArray[k]-mod);
		roiManager("delete");
		mod = mod + 1;
	}
	//Goes to the nuclear image window
	selectWindow(nuclear);
	n = roiManager("count");
	//For each nucleus that does meet conditions for further analysis...
	for (m = 0; m < n; m++) {
		//Select the relevant nucleus
		roiManager("select", m);
		//Expand the ROI by 10 pixels in every direction
		run("Enlarge...", "enlarge=10");
		//Creates a copy of just the new ROI surrounding the nucleus
		run("Duplicate...", " ");
		//Saves the single nucleus of interest to the appropriate folder with a unique name that can be tracked
		saveName = singleCellFolder + saveFileRaw + "_Cell_" + m + ".tif";
		saveAs("Tiff", saveName);
		close();
	}
	//If any nuclei are of interest...
	if (n > 0) {
		//Saves the new ROI list to the appropriate folder
		roiSaveName = nuclearROIModFolder + saveFileRaw + ".zip";
		roiManager("save", roiSaveName);
		
	}
	//Resets the ROI manager and closes all open images
	roiManager("reset");
	close("*");
}
	

	
//Creates a List of All the Images in your Nuclear Folder
list = getFileList(nuclearROIModFolder);
l = list.length;
//For Each cropped multi-channel image...
for (i=0; i<l; i++) {
	roiManager("reset");
	//Opens the modified nuclear ROI file and relevant multi-channel cropped image, containing only nuclei of interest
	roiName = nuclearROIModFolder + list[i];
	saveFileRaw = substring(list[i], 0, (lengthOf(list[i])-4));	
	fileName = tifFolder + saveFileRaw + ".tif";
	open(fileName);
	roiManager("open", roiName);
	//Counts the number of nuclei that are of interest
	n = roiManager("count");
	for (j=0; j<n; j++) {
		//Select the relevant nucleus
		roiManager("select", j);
		//Expand the ROI by 10 pixels in every direction
		run("Enlarge...", "enlarge=10");
		//Creates a copy of just the new ROI surrounding the nucleus
		run("Duplicate...", "duplicate");
		//Saves the single nucleus of interest to the appropriate folder with a unique name that can be tracked
		saveName = singleCellStackFolder + saveFileRaw + "_Cell_" + j + ".tif";
		saveAs("Tiff", saveName);
		close();
	}
	//Resets the ROI manager and closes all open images
	close("*");
	roiManager("reset");
}
		
	
