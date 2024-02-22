//Define the Home Folder
homeFolder = getDirectory("Choose The Home Folder Containing All Other Folders");
//Define the Raw Images Folder
rawFolder = getDirectory("Choose The Home Folder Containing Your Raw Images");


//Set Measurement Parameters for Measure Function
run("Set Measurements...", "area mean standard modal min centroid center perimeter fit shape area_fraction display redirect=None decimal=3");
//Defines the parameter to allow for arrays to be utilised later
setOption("ExpandableArrays", true);

//Allows the Macro to Use BioFormats Importer
run("Input/Output...", "jpeg=85 gif=-1 file=.csv use use_file copy_row save_column save_row");
run("Bio-Formats Macro Extensions");



//Create new folders for the cropped segmented and raw images
nuclearFolder = homeFolder + "Nuclear_Channel/";
if (File.isDirectory(nuclearFolder) < 1) {
	File.makeDirectory(nuclearFolder); 
}

nuclearcropFolder = homeFolder + "Nuclear_Cropped_Channel/";
if (File.isDirectory(nuclearcropFolder) < 1) {
	File.makeDirectory(nuclearcropFolder); 
}

nuclearSegFolder = homeFolder + "Nuclear_Segmented/";
if (File.isDirectory(nuclearSegFolder) < 1) {
	File.makeDirectory(nuclearSegFolder); 
}

nuclearROIFolder = homeFolder + "Nuclear_ROI/";
if (File.isDirectory(nuclearROIFolder) < 1) {
	File.makeDirectory(nuclearROIFolder); 
}

chanTwoFolder = homeFolder + "Channel_Two_Images/";
if (File.isDirectory(chanTwoFolder) < 1) {
	File.makeDirectory(chanTwoFolder); 
}

chanTwoCropFolder = homeFolder + "Channel_Two_Cropped_Images/";
if (File.isDirectory(chanTwoCropFolder) < 1) {
	File.makeDirectory(chanTwoCropFolder); 
}

chanTwoSegFolder = homeFolder + "Channel_Two_Segmented_Images/";
if (File.isDirectory(chanTwoSegFolder) < 1) {
	File.makeDirectory(chanTwoSegFolder); 
}

chanThreeFolder = homeFolder + "Channel_Three_Images/";
if (File.isDirectory(chanThreeFolder) < 1) {
	File.makeDirectory(chanThreeFolder); 
}

chanThreeCropFolder = homeFolder + "Channel_Three_Cropped_Images/";
if (File.isDirectory(chanThreeCropFolder) < 1) {
	File.makeDirectory(chanThreeCropFolder); 
}

chanThreeSegFolder = homeFolder + "Channel_Three_Segmented_Images/";
if (File.isDirectory(chanThreeSegFolder) < 1) {
	File.makeDirectory(chanThreeSegFolder); 
}

chanTwoCroppedFolder = homeFolder + "Channel_Two_Cropped/";
if (File.isDirectory(chanTwoCroppedFolder) < 1) {
	File.makeDirectory(chanTwoCroppedFolder); 
}

chanThreeCroppedFolder = homeFolder + "Channel_Three_Cropped/";
if (File.isDirectory(chanThreeCroppedFolder) < 1) {
	File.makeDirectory(chanThreeCroppedFolder); 
}

chanTwoSegCroppedFolder = homeFolder + "Channel_Two_Seg_Cropped/";
if (File.isDirectory(chanTwoSegCroppedFolder) < 1) {
	File.makeDirectory(chanTwoSegCroppedFolder); 
}

chanThreeSegCroppedFolder = homeFolder + "Channel_Three_Seg_Cropped/";
if (File.isDirectory(chanThreeSegCroppedFolder) < 1) {
	File.makeDirectory(chanThreeSegCroppedFolder); 
}


//Creates a List of All the Images in your Raw Folder
list = getFileList(rawFolder);
l = list.length;

//Clears the Results Window and the ROI Manager Prior to Starting Analysis
run("Clear Results");
roiManager("reset");
//For Each Raw Image
for (i=0; i<l; i++) {
	//Open the Image
	fileName = rawFolder + list[i];
	run("Bio-Formats", "check_for_upgrades open=[" + fileName + "] autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT series_1");
	//Split the Image into Constituent Channels
	run("Stack to Images");
	//Save Each Channel to Appropriate Location in Appropriate Folder
	saveName = chanThreeFolder + list[i];
	saveAs("Tiff", saveName);
	close();
	saveName = chanTwoFolder + list[i];
	saveAs("Tiff", saveName);
	close();
	saveName = nuclearFolder + list[i];
	saveAs("Tiff", saveName);
	//Close Any Open Images
	close("*");
}	

//NEED TO INCORPORATE A SECTION HERE THAT BASICALLY CROPS ALL THE IMAGES INTO MORE MANAGABLE CHUNKS, OR JUST RUN THIS ON A BEAST OF A COMPUTER

list = getFileList(nuclearFolder);
l = list.length;
//For each Image in the Nuclear Folder (and the other channel folders)
for (i=0; i<l; i++) {
	//Open the images
	fileName = nuclearFolder + list[i];
	open(fileName);
	nuclear = getTitle();
	fileName = chanTwoFolder + list[i];
	open(fileName);
	chanTwo = getTitle();
	fileName = chanThreeFolder + list[i];
	open(fileName);
	chanThree = getTitle();
	//Get the height and width of the image
	height = getHeight();
	width = getWidth();
	//Divide each axis by 10 and put into arrays
	xArray = newArray();
	yArray = newArray();
	xInt = Math.round(width/10);
	yInt = Math.round(height/10);
	for (j = 0; j < 10; j++) {
		xArray = Array.concat(xArray, xInt*j);
		yArray = Array.concat(yArray, yInt*j);
	}
	//For each X axis array point
	for (k = 0; k < xArray.length; k++) {
		//For each Y axis array point
		for (j = 0; j < yArray.length; j++) {
			//Select the Image
			selectWindow(nuclear);
			//Draw the box
			makeRectangle(xArray[k], yArray[j], xInt, yInt);
			//Duplicate that region
			run("Duplicate...", " ");
			//Save into new folders with specific names (i.e. [imageName]_X_02_Y_03.tif)
			fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
			saveName = nuclearcropFolder + fileNameRaw + "_X_0" + k + "_Y_0" + j + ".tif";
			saveAs(saveName);
			//Close the duplicate
			close();
			//Select the Image
			selectWindow(chanTwo);
			//Draw the box
			makeRectangle(xArray[k], yArray[j], xInt, yInt);
			//Duplicate that region
			run("Duplicate...", " ");
			//Save into new folders with specific names (i.e. [imageName]_X_02_Y_03.tif)
			fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
			saveName = chanTwoCropFolder + fileNameRaw + "_X_0" + k + "_Y_0" + j + ".tif";
			saveAs(saveName);
			//Close the duplicate
			close();
			//Select the Image
			selectWindow(chanThree);
			//Draw the box
			makeRectangle(xArray[k], yArray[j], xInt, yInt);
			//Duplicate that region
			run("Duplicate...", " ");
			//Save into new folders with specific names (i.e. [imageName]_X_02_Y_03.tif)
			fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
			saveName = chanThreeCropFolder + fileNameRaw + "_X_0" + k + "_Y_0" + j + ".tif";
			saveAs(saveName);
			//Close the duplicate
			close();
		}
	}
	//Close All Open Images
	close("*");
}
		
//Creates a List of All the Images in your Nuclear Folder
list = getFileList(nuclearcropFolder);
l = list.length;
//For Each Nuclear Channel Image
for (i=0; i<l; i++) {
	//Resets the ROI Manager to Make sure Only Real ROIs are Saved
	roiManager("reset");
	//Open the Image
	fileName = nuclearcropFolder + list[i];
	open(fileName);
	imgName = getTitle();
	//Converts the nuclear probability image to 8-bit format to allow for subsequent thresholding
	run("8-bit");
	//Commands the Plugin "StarDist" to segment the probability map to find the nuclei
	imgName = getTitle();
	run("Command From Macro", "command=[de.csbdresden.stardist.StarDist2D], args=['input':'" + imgName + "', 'modelChoice':'Versatile (fluorescent nuclei)', 'normalizeInput':'true', 'percentileBottom':'1.0', 'percentileTop':'99.8', 'probThresh':'0.6', 'nmsThresh':'0.4', 'outputType':'Both', 'nTiles':'1', 'excludeBoundary':'2', 'roiPosition':'Automatic', 'verbose':'false', 'showCsbdeepProgress':'false', 'showProbAndDist':'false'], process=[false]");
	//Saves the segmented nucleus image to an appropriate location
	saveName = nuclearSegFolder + list[i];
	saveAs("Tiff", saveName);
	//Saves the output regions of interest to an appropriate location
	saveFileRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	roiName = nuclearROIFolder + saveFileRaw + ".zip";
	n = roiManager("count");
		if (n == 0) {
			makeOval(1, 1, 1, 1);
			roiManager("Add");
		}
	roiManager("save", roiName);
	//Resets the RO Manager and closes open images
	roiManager("reset");
	close("*");
}


//Creates a List of All the Images in your Channel Two Folder
list = getFileList(chanTwoCropFolder);
l = list.length;
//For Each Channel 2 Image
for (i=0; i<l; i++) {
	//Open the Image
	fileName = chanTwoCropFolder + list[i];
	open(fileName);	
	//Segment Using Most Effective Method
	run("Gaussian Blur...", "sigma=1");
	run("Find Maxima...", "prominence=50 output=[Single Points]");
	//Save the Output Image
	saveName = chanTwoSegFolder + list[i];
	saveAs("Tiff", saveName);
	close("*");
}
	

//Creates a List of All the Images in your Channel Three Folder
list = getFileList(chanThreeCropFolder);
l = list.length;
//For Each Channel 3 Image
for (i=0; i<l; i++) {
	//Open the Image
	fileName = chanThreeCropFolder + list[i];
	open(fileName);	
	//Segment Using Most Effective Method
	run("Gaussian Blur...", "sigma=1");
	run("Find Maxima...", "prominence=50 output=[Single Points]");
	//Save the Output Image
	saveName = chanThreeSegFolder + list[i];
	saveAs("Tiff", saveName);
	close("*");
}

	
//Makes all the arrays necessary for this code to work
xCentroidArray = newArray();
yCentroidArray = newArray();
nuclearAreaArray = newArray();
nuclearPerimeterArray = newArray();
nuclearMajorArray = newArray();
nuclearMinorArray = newArray();
nuclearCircularityArray = newArray();
nuclearRoundArray = newArray();
nuclearSolidityArray = newArray();
spotXArray = newArray();
spotYArray = newArray();
distanceArray = newArray();
channelArray = newArray();
nuclearAreaValues = newArray();
nuclearPerimeterValues = newArray();
nuclearMajorValues = newArray();
nuclearMinorValues = newArray();
nuclearCircularityValues = newArray();
nuclearRoundnessValues = newArray();
nuclearSolidityValues = newArray();
spotNNDArray = newArray();
imgNameArray = newArray();
nameArray = newArray();
nucleusNumberArray = newArray();
spotNumberArray = newArray();
colocalisingArray = newArray();
nucleusXArray= newArray();
nucleusYArray = newArray();
spotTwoCountArray = newArray();
spotThreeCountArray = newArray();
colocalisationQuantifiedArray = newArray();
imgFullNameArray = newArray();


//Crop the images based on the nuclear segmentation
list = getFileList(chanTwoCropFolder);
list = Array.sort(list);
roilist = getFileList(nuclearROIFolder);
roilist = Array.sort(roilist);
l = list.length;
row = 0;
run("Clear Results");
//For each image in the channel two folder
for (i=0; i<l; i++) {
	//Resets the ROI manager in preparation for Macro function
	roiManager("reset");
	//Opens the image
	fileName = chanTwoCropFolder + list[i];
	open(fileName);
	//Ensures the image properties are converted to pixel dimensions
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	//Opens the appropriate nuclear segmentation ROIs
	fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	roiName =nuclearROIFolder + roilist[i];
	roiManager("open", roiName);
	//For each nucleus in the ROI file
	n = roiManager("count");
	for (j=0; j<n; j++) {
		//Create a single nucleus image and save it to an appropriate location
		roiManager("select", j);
		run("Duplicate...", " ");
		saveName = chanTwoCroppedFolder + fileNameRaw + "_Cell_" + j + ".tif";
		saveAs("Tiff", saveName);
		//Measures the parameters relating to this cell and stores the information for later
		roiManager("select", j);
		roiManager("measure");
		xCen = getResult("X");
		print(xCen);
		yCen = getResult("Y");
		print(yCen);
		nuclearArea = getResult("Area");
		print(nuclearArea);
		nuclearPerimeter = getResult("Perim.");
		print(nuclearPerimeter);
		nuclearMajor = getResult("Major");
		print(nuclearMajor);
		nuclearMinor = getResult("Minor");
		print(nuclearMinor);
		nuclearCircularity = getResult("Circ.");
		print(nuclearCircularity);
		nuclearRound = getResult("Round");
		print(nuclearRound);
		nuclearSolidity = getResult("Solidity");
		print(nuclearSolidity);
		xCentroidArray = Array.concat(xCentroidArray,xCen);
		yCentroidArray = Array.concat(yCentroidArray,yCen);
		nuclearAreaArray = Array.concat(nuclearAreaArray,nuclearArea);
		nuclearPerimeterArray = Array.concat(nuclearPerimeterArray,nuclearPerimeter);
		nuclearMajorArray  = Array.concat(nuclearMajorArray,nuclearMajor);
		nuclearMinorArray  = Array.concat(nuclearMinorArray,nuclearMinor);
		nuclearCircularityArray  = Array.concat(nuclearCircularityArray,nuclearCircularity);
		nuclearRoundArray  = Array.concat(nuclearRoundArray,nuclearRound);
		nuclearSolidityArray  = Array.concat(nuclearSolidityArray,nuclearSolidity);
		close();		
	}
	close();
}
//Crop the images based on the cell segmentation
list = getFileList(chanThreeCropFolder);
roilist = getFileList(nuclearROIFolder);
l = list.length;
row = 0;
for (i=0; i<l; i++) {
	roiManager("reset");
	//Opens the appropriate image
	fileName = chanThreeCropFolder + list[i];
	open(fileName);
	//Converts image to pixel dimensions
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	//Opens the appropriate nuclear ROI file
	fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	roiName =nuclearROIFolder + roilist[i];
	roiManager("open", roiName);
	//For each nuclear roi
	n = roiManager("count");
	for (j=0; j<n; j++) {
		//Creates a single image for each cell based on the nuclear segmentation ROIs
		roiManager("select", j);
		run("Duplicate...", " ");
		//Saves it to an appropriate location
		saveName = chanThreeCroppedFolder + fileNameRaw + "_Cell_" + j + ".tif";
		saveAs("Tiff", saveName);
		close();		
	}
	close();
}

//Performs the same process as above on the segmented images from channel 2 and channel 3
//Crop the images based on the cell segmentation
list = getFileList(chanTwoSegFolder);
roilist = getFileList(nuclearROIFolder);
l = list.length;
row = 0;
for (i=0; i<l; i++) {
	roiManager("reset");
	//Opens the appropriate image
	fileName = chanTwoSegFolder + list[i];
	open(fileName);
	//Converts image to pixel dimensions
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	//Opens the relevant nuclear ROI file for the image
	fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	roiName =nuclearROIFolder + roilist[i];
	roiManager("open", roiName);
	//For each nuclear roi
	n = roiManager("count");
	for (j=0; j<n; j++) {
		//Creates a single image for each cell based on the nuclear segmentation ROIs
		roiManager("select", j);
		run("Duplicate...", " ");
		//Saves it to an appropriate location
		saveName = chanTwoSegCroppedFolder + fileNameRaw + "_Cell_" + j + ".tif";
		saveAs("Tiff", saveName);
		close();		
	}
	close();
}

//Crop the images based on the cell segmentation
list = getFileList(chanThreeSegFolder);
roilist = getFileList(nuclearROIFolder);
l = list.length;
row = 0;
for (i=0; i<l; i++) {
	//Opens the appropriate image//Opens the appropriate image
	roiManager("reset");
	fileName = chanThreeSegFolder + list[i];
	open(fileName);
	//Converts image to pixel dimensions
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width=1.0000 pixel_height=1.0000 voxel_depth=1.0000");
	//Opens the relevant nuclear ROI file for the image
	fileNameRaw = substring(list[i], 0, (lengthOf(list[i])-4));
	roiName =nuclearROIFolder + roilist[i];
	roiManager("open", roiName);
	//For each nuclear roi
	n = roiManager("count");
	for (j=0; j<n; j++) {
		//Creates a single image for each cell based on the nuclear segmentation ROIs
		roiManager("select", j);
		run("Duplicate...", " ");
		//Saves it to an appropriate location
		saveName = chanThreeSegCroppedFolder + fileNameRaw + "_Cell_" + j + ".tif";
		saveAs("Tiff", saveName);
		close();		
	}
	close();
}

//For each of the images in the segmented folder (should have the same name I think)
//Finds the names of image files within folder and counts the number of files from the new images
list = getFileList(chanTwoSegCroppedFolder);
list = Array.sort(list);
roilist = getFileList(nuclearROIFolder);
roilist = Array.sort(roilist);
l = list.length;
row = 0;
for (i=0; i<l; i++) {
	roiManager("reset");
	//Open the cropped raw images for colocalisation analysis
	fileName = chanTwoCroppedFolder + list[i];
	open(fileName);
	chanTwo = getTitle();
	fileName = chanThreeCroppedFolder + list[i];
	open(fileName);
	chanThree = getTitle();
	//open channel two segmented cropped image
	fileName = chanTwoSegCroppedFolder + list[i];
	open(fileName);
	//run("Invert");
	segTwo = getTitle();
	//open channel three segmented cropped image
	fileName = chanThreeSegCroppedFolder + list[i];
	open(fileName);
	//run("Invert");
	segThree = getTitle();
	//Selects the Seg Two Window
	selectWindow(segTwo);
	//Stores the relevant XY centroid coordinates for the nucleus ready for analysis later
	centralX = xCentroidArray[i];
	centralY = yCentroidArray[i];
	//Delete the results line
	run("Clear Results");
	//Perform find particles to get channel two spots
	run("Analyze Particles...", "size=0-5 show=[Overlay Masks] add");
	//Count the number of rows in the results window
	spotsTwo = roiManager("count");
	//For each spot identified
	colocalisation = 0;
	colocalisingROI = "NA";
	spotXtempArrayTwo = newArray();
	spotXtempArrayThree = newArray();
	spotYtempArrayTwo = newArray();
	spotYtempArrayThree = newArray();
	print("Spots Two Number = " + spotsTwo);
	for (k=0; k<spotsTwo; k++) {
		//Select the channel three image
		selectWindow(chanThree);
		//Measure the intensity in the location of the channel 2 spot
		roiManager("select", k);
		roiManager("measure");
		colocalisationTest = getResult("Mean");
		print("Colocalisation Test Result: " + colocalisationTest);
		//Figure out which spot is colocalising with the other channel based on intensity measurements
		if (colocalisationTest > colocalisation) {
			colocalisation = colocalisationTest;
			colocalisingROI = k;
			print("Colocalising ROI is: " + k);			
		}
		xCordTwo = getResult("X");
		yCordTwo = getResult("Y");
		spotXtempArrayTwo = Array.concat(spotXtempArrayTwo,xCordTwo);
		spotYtempArrayTwo = Array.concat(spotYtempArrayTwo,yCordTwo);
		colocalisationQuantifiedArray = Array.concat(colocalisationQuantifiedArray,colocalisationTest);
	}
	//Clear the results and ROI manager for the NND analysis
	run("Clear Results");
	roiManager("deselect");
	roiManager("Reset");
	//Select the segmented channel 3 image
	selectWindow(segThree);
	//Perform particle Analysis to get coordinates of channel 3 spots
	run("Analyze Particles...", "size=0-5 show=[Overlay Masks] add");
	//For each spot get the XY coordinates
	spotsThree = roiManager("count");
	print("Spots Three Number = " + spotsThree);
	for (k=0; k<spotsThree; k++) {
		roiManager("select", k);
		roiManager("measure");
		xCordThree = getResult("X");
		yCordThree = getResult("Y");
		spotXtempArrayThree = Array.concat(spotXtempArrayThree,xCordThree);
		spotYtempArrayThree = Array.concat(spotYtempArrayThree,yCordThree);
	}
	
	roiManager("deselect");
	roiManager("reset");
	//Selects the Seg Two Window
	selectWindow(segTwo);
	//Delete the results line
	run("Clear Results");
	//Perform find particles to get channel two spots
	run("Analyze Particles...", "size=0-5 show=[Overlay Masks] add");
	//Run throught the spots again
	for (k=0; k<spotsTwo; k++) {
		//Measure the spots to get their XY coordinates
		roiManager("select", k);
		roiManager("measure");
		XVal = getResult("X");
		YVal = getResult("Y");
		//Calculate the distance of each spot from the nuclear centroid
		centroidDistance = sqrt(((XVal-centralX)*(XVal-centralX))+((YVal-centralY)*(YVal-centralY)));
		print("Colocalising Factor is : " + colocalisingROI);
		if (colocalisingROI == k){
			colocalisingFactor = "Colocalising";
		}
		else {
			colocalisingFactor = "Independent";
		}
		
		arrayThreeLength = spotXtempArrayThree.length;
		distance = 10000;
		for (j=0; j<arrayThreeLength; j++) {
			posX = XVal;
			print(posX);
			posY = YVal;
			print(posY);
			XComp = spotXtempArrayThree[j];
			print(XComp);
			YComp = spotYtempArrayThree[j];
			print(YComp);
			xDiff = posX - XComp;
			print(xDiff);
			yDiff = posY - YComp;
			print(yDiff);
			tempDist = sqrt((xDiff*xDiff)+(yDiff*yDiff));
			print("TempDist = ", tempDist);
			if (tempDist < distance) {
				distance = tempDist;
				xClose = XComp;
				yClose = YComp;
			}
			
		}
		
		
		//Plug all the parameters and calcualted values into arrays to generate a results table at the end of the macro
		//Spot X Location
		spotXArray = Array.concat(spotXArray, XVal);
		//spot Y location
		spotYArray = Array.concat(spotYArray, YVal);
		//Nucleus X Values
		nucleusXArray = Array.concat(nucleusXArray, xCentroidArray[i]);
		//Nucleus Y Values
		nucleusYArray = Array.concat(nucleusYArray, yCentroidArray[i]);
		//spot distance to centre
		distanceArray = Array.concat(distanceArray, centroidDistance);
		//Spot channel
		channelArray = Array.concat(channelArray, 2);
		//Nuclear Area
		nuclearArea = nuclearAreaArray[i];
		nuclearAreaValues = Array.concat(nuclearAreaValues, nuclearArea);
		//Nuclear Perimeter
		nuclearPerimeter = nuclearPerimeterArray[i];
		nuclearPerimeterValues = Array.concat(nuclearPerimeterValues, nuclearPerimeter);
		//Nuclear Major
		nuclearMajor = nuclearMajorArray [i];
		nuclearMajorValues = Array.concat(nuclearMajorValues, nuclearMajor);
		//Nuclear Minor
		nuclearMinor = nuclearMinorArray [i];
		nuclearMinorValues = Array.concat(nuclearMinorValues, nuclearMinor);
		//Nuclear Circularity
		nuclearCircularity = nuclearCircularityArray [i];
		nuclearCircularityValues = Array.concat(nuclearCircularityValues, nuclearCircularity);
		//Nuclear Roundness
		nuclearRoundness = nuclearRoundArray [i];
		nuclearRoundnessValues = Array.concat(nuclearRoundnessValues, nuclearRoundness);
		//Nuclear Solidity
		nuclearSolidity = nuclearSolidityArray [i];
		nuclearSolidityValues = Array.concat(nuclearSolidityValues, nuclearSolidity);
		//Spot NND Distance
		spotNNDArray = Array.concat(spotNNDArray, distance);
		//Image Name
		nameArray = split(list[i], "_");
		imgName = nameArray[0] + "_" + nameArray[1] + "_" + nameArray[2];
		imgNameArray = Array.concat(imgNameArray, imgName);
		imgFullNameArray = Array.concat(imgFullNameArray, list[i]);
		//Nucleus Number
		nuclearNumber = nameArray[4];
		nucleusNumberArray = Array.concat(nucleusNumberArray, nuclearNumber);
		//Spot Number
		spotNumberArray = Array.concat(spotNumberArray, k);
		//Does spot colocalise with other channel?
		colocalisingArray = Array.concat(colocalisingArray, colocalisingFactor);
		//Number of spots in channel 2
		spotTwoCountArray = Array.concat(spotTwoCountArray, spotsTwo);
		//Number of spots in channel 3
		spotThreeCountArray = Array.concat(spotThreeCountArray, spotsThree);
	}
	
	
	//Performs the same task to segmented channel 3	
	//open channel two segmented cropped image
	selectWindow(segTwo);
	close();
	fileName = chanTwoSegCroppedFolder + list[i];
	open(fileName);
	//run("Invert");
	segTwo = getTitle();
	selectWindow(segTwo);
	
	selectWindow(segThree);
	close();
	fileName = chanThreeSegCroppedFolder + list[i];
	open(fileName);
	//run("Invert");
	segThree = getTitle();
	//Delete the results line
	roiManager("deselect");
	roiManager("Reset");
	run("Clear Results");
	//Perform find particles to get channel two spots
	run("Analyze Particles...", "size=0-5 show=[Overlay Masks] add");
	//Count the number of rows in the results window
	spotsThree = roiManager("count");//NUMBER OF ROWS
	print("Spots Three Number during Round 2 = " + spotsThree); //Only seems to be counting final spot from original method
	//For each spot identified
	colocalisation = 0;
	colocalisingROI = "NA";
	spotXtempArrayTwo = newArray();
	spotXtempArrayThree = newArray();
	spotYtempArrayTwo = newArray();
	spotYtempArrayThree = newArray();
	for (k=0; k<spotsThree; k++) {
		//Select the channel three image
		selectWindow(chanTwo);
		//Determine which spot is colocalising, as with channel 2
		roiManager("select", k);
		roiManager("measure");
		colocalisationTest = getResult("Mean");
		if (colocalisationTest > colocalisation) {
			colocalisation = colocalisationTest;
			colocalisingROI = k;
		}
		xCordThree = getResult("X");
		yCordThree = getResult("Y");
		spotXtempArrayThree = Array.concat(spotXtempArrayThree,xCordThree);
		spotYtempArrayThree = Array.concat(spotYtempArrayThree,yCordThree);
		colocalisationQuantifiedArray = Array.concat(colocalisationQuantifiedArray,colocalisationTest);
	}
	
	//Clear the results and ROI manager for the NND analysis
	run("Clear Results");
	roiManager("deselect");
	roiManager("Reset");
	//Select the segmented channel 3 image
	selectWindow(segTwo);
	//Perform particle Analysis to get coordinates of channel 3 spots
	run("Analyze Particles...", "size=0-5 show=[Overlay Masks] add");
	//For each spot get the XY coordinates
	spotsTwo = roiManager("count");
	for (k=0; k<spotsTwo; k++) {
		roiManager("select", k);
		roiManager("measure");
		xCordTwo = getResult("X");
		yCordTwo = getResult("Y");
		spotXtempArrayTwo = Array.concat(spotXtempArrayTwo,xCordTwo);
		spotYtempArrayTwo = Array.concat(spotYtempArrayTwo,yCordTwo);
	}
	
	roiManager("deselect");
	roiManager("Reset");
	//Selects the Seg Three Window
	selectWindow(segThree);
	close();
	fileName = chanThreeSegCroppedFolder + list[i];
	open(fileName);
	selectWindow(segThree);
	//Delete the results line
	run("Clear Results");
	//Perform find particles to get channel two spots
	run("Analyze Particles...", "size=0-5 show=[Overlay Masks] add");
	//Run throught the spots again
	spotsThree = roiManager("count");
	//Run through the spots again
	for (k=0; k<spotsThree; k++) {
		//Measure each channel 3 spot for key measurement parameters
		roiManager("select", k);
		roiManager("measure");
		XVal = getResult("X");
		YVal = getResult("Y");
		//Calculate the distance from each spot to the nuclear centroid
		centroidDistance = sqrt(((XVal-centralX)*(XVal-centralX))+((YVal-centralY)*(YVal-centralY)));
		if (colocalisingROI == k){
			colocalisingFactor = "Colocalising";
		}
		else {
			colocalisingFactor = "Independent";
		}
		arrayTwoLength = spotXtempArrayTwo.length;
		distance = 10000;
		for (j=0; j<arrayTwoLength; j++) {
			posX = XVal;
			print(posX);
			posY = YVal;
			print(posY);
			XComp = spotXtempArrayTwo[j];
			print(XComp);
			YComp = spotYtempArrayTwo[j];
			print(YComp);
			xDiff = posX - XComp;
			print(xDiff);
			yDiff = posY - YComp;
			print(yDiff);
			tempDist = sqrt((xDiff*xDiff)+(yDiff*yDiff));
			print("TempDist = ", tempDist);
			if (tempDist < distance) {
				distance = tempDist;
				xClose = XComp;
				yClose = YComp;
			}
			
		}
		//Plug all the parameters and calcualted values into arrays to generate a results table at the end of the macro
		//Spot X Location
		spotXArray = Array.concat(spotXArray, XVal);
		//spot Y location
		spotYArray = Array.concat(spotYArray, YVal);
		//Nucleus X Values
		nucleusXArray = Array.concat(nucleusXArray, xCentroidArray[i]);
		//Nucleus Y Values
		nucleusYArray = Array.concat(nucleusYArray, yCentroidArray[i]);
		//spot distance to centre
		distanceArray = Array.concat(distanceArray, centroidDistance);
		//Spot channel
		channelArray = Array.concat(channelArray, 3);
		//Nuclear Area
		nuclearArea = nuclearAreaArray[i];
		nuclearAreaValues = Array.concat(nuclearAreaValues, nuclearArea);
		//Nuclear Perimeter
		nuclearPerimeter = nuclearPerimeterArray[i];
		nuclearPerimeterValues = Array.concat(nuclearPerimeterValues, nuclearPerimeter);
		//Nuclear Major
		nuclearMajor = nuclearMajorArray [i];
		nuclearMajorValues = Array.concat(nuclearMajorValues, nuclearMajor);
		//Nuclear Minor
		nuclearMinor = nuclearMinorArray [i];
		nuclearMinorValues = Array.concat(nuclearMinorValues, nuclearMinor);
		//Nuclear Circularity
		nuclearCircularity = nuclearCircularityArray [i];
		nuclearCircularityValues = Array.concat(nuclearCircularityValues, nuclearCircularity);
		//Nuclear Roundness
		nuclearRoundness = nuclearRoundArray [i];
		nuclearRoundnessValues = Array.concat(nuclearRoundnessValues, nuclearRoundness);
		//Nuclear Solidity
		nuclearSolidity = nuclearSolidityArray [i];
		nuclearSolidityValues = Array.concat(nuclearSolidityValues, nuclearSolidity);
		//Spot NND Distance
		spotNNDArray = Array.concat(spotNNDArray, distance);
		//Image Name
		nameArray = split(list[i], "_");
		imgName = nameArray[0] + "_" + nameArray[1] + "_" + nameArray[2];
		imgNameArray = Array.concat(imgNameArray, imgName);
		imgFullNameArray = Array.concat(imgFullNameArray, list[i]);
		//Nucleus Number
		nuclearNumber = nameArray[4];
		nucleusNumberArray = Array.concat(nucleusNumberArray, nuclearNumber);
		//Spot Number
		spotNumberArray = Array.concat(spotNumberArray, k);
		//Does spot colocalise with other channel?
		colocalisingArray = Array.concat(colocalisingArray, colocalisingFactor);
		//Number of spots in channel 2
		spotTwoCountArray = Array.concat(spotTwoCountArray, spotsTwo);
		//Number of spots in channel 3
		spotThreeCountArray = Array.concat(spotThreeCountArray, spotsThree);
	}
	roiManager("reset");
	close("*");
	run("Clear Results");
	row = 0;
	for (k=0; k<spotXArray.length; k++) {
		//Prints all the below results row by row until all arrays have been transfered to the results window
		setResult("Spot_X_Location", row, spotXArray[k]);
		setResult("Spot_Y_Location", row, spotYArray[k]);
		setResult("Nucleus_X_Location", row, nucleusXArray[k]);
		setResult("Nucleus_Y_Location", row, nucleusYArray[k]);
		setResult("Centroid_Distance", row, distanceArray[k]);
		setResult("Image_Channel", row, channelArray[k]);
		setResult("Nuclear_Area", row, nuclearAreaValues[k]);
		setResult("Nuclear_Perimeter", row, nuclearPerimeterValues[k]);
		setResult("Nuclear_Major", row, nuclearMajorValues[k]);
		setResult("Nuclear_Minor", row, nuclearMinorValues[k]);
		setResult("Nuclear_Circularity", row, nuclearCircularityValues[k]);
		setResult("Nuclear_Roundness", row, nuclearRoundnessValues[k]);
		setResult("Nuclear_Solidity", row, nuclearSolidityValues[k]);
		setResult("NND", row, spotNNDArray[k]);
		setResult("Image_Name", row, imgNameArray[k]);
		setResult("Image_Full_Name", row, imgFullNameArray[k]);
		setResult("Nucleus_Number", row, nucleusNumberArray[k]);
		setResult("Spot_Number", row, spotNumberArray[k]);
		setResult("Colocalising_Mean", row, colocalisationQuantifiedArray[k]);
		if (colocalisationQuantifiedArray[k] < 10) {
			setResult("Colocalising_Mean_Threshold", row, 0);
		}
		else {
			setResult("Colocalising_Mean_Threshold", row, 1);
		}
		setResult("Colocalising", row, colocalisingArray[k]);
		if (spotNNDArray[k] > 10) {
			setResult("NND_Colocalisation", row, 0);
		}
		else {
			setResult("NND_Colocalisation", row, 1);
		}
		setResult("Spot_Two_Count", row, spotTwoCountArray[k]);
		setResult("Spot_Three_Count", row, spotThreeCountArray[k]);
		if (spotTwoCountArray[k] != 2) {
			setResult("Spot_Two_Count_Parameter", row, 0);
		}
		else {
			setResult("Spot_Two_Count_Parameter", row, 1);
		}
		if (spotThreeCountArray[k] != 4) {
			setResult("Spot_Three_Count_Parameter", row, 0);
		}
		else {
			setResult("Spot_Three_Count_Parameter", row, 1);
		}
		
		row = row + 1;
	}		
	
	
			
			
	//Saves the final results table to the home folder for subsequent analysis and statistics
	saveName = homeFolder + "Collated_Centroid_Distance_Results.csv";
	saveAs("Results", saveName);
}

run("Clear Results");
//Prints all the generated arrays for a user to check if necessary
Array.print(spotXArray);
Array.print(spotYArray);
Array.print(nucleusXArray);
Array.print(nucleusYArray);
Array.print(distanceArray);
Array.print(channelArray);
Array.print(nuclearAreaValues);
Array.print(nuclearPerimeterValues);
Array.print(nuclearMajorValues);
Array.print(nuclearMinorValues);
Array.print(nuclearCircularityValues);
Array.print(nuclearRoundnessValues);
Array.print(nuclearSolidityValues);
Array.print(spotNNDArray);
Array.print(imgNameArray);
Array.print(nucleusNumberArray);
Array.print(spotNumberArray);
Array.print(colocalisingArray);
Array.print(spotTwoCountArray);
Array.print(spotThreeCountArray);
Array.print(colocalisationQuantifiedArray);

//Creates a new results table based on the arrays built up throughout the macro
row = 0;
for (k=0; k<spotXArray.length; k++) {
	//Prints all the below results row by row until all arrays have been transfered to the results window
	setResult("Spot_X_Location", row, spotXArray[k]);
	setResult("Spot_Y_Location", row, spotYArray[k]);
	setResult("Nucleus_X_Location", row, nucleusXArray[k]);
	setResult("Nucleus_Y_Location", row, nucleusYArray[k]);
	setResult("Centroid_Distance", row, distanceArray[k]);
	setResult("Image_Channel", row, channelArray[k]);
	setResult("Nuclear_Area", row, nuclearAreaValues[k]);
	setResult("Nuclear_Perimeter", row, nuclearPerimeterValues[k]);
	setResult("Nuclear_Major", row, nuclearMajorValues[k]);
	setResult("Nuclear_Minor", row, nuclearMinorValues[k]);
	setResult("Nuclear_Circularity", row, nuclearCircularityValues[k]);
	setResult("Nuclear_Roundness", row, nuclearRoundnessValues[k]);
	setResult("Nuclear_Solidity", row, nuclearSolidityValues[k]);
	setResult("NND", row, spotNNDArray[k]);
	setResult("Image_Name", row, imgNameArray[k]);
	setResult("Image_Full_Name", row, imgFullNameArray[k]);
	setResult("Nucleus_Number", row, nucleusNumberArray[k]);
	setResult("Spot_Number", row, spotNumberArray[k]);
	setResult("Colocalising_Mean", row, colocalisationQuantifiedArray[k]);
	if (colocalisationQuantifiedArray[k] < 10) {
		setResult("Colocalising_Mean_Threshold", row, 0);
	}
	else {
		setResult("Colocalising_Mean_Threshold", row, 1);
	}
	setResult("Colocalising", row, colocalisingArray[k]);
	if (spotNNDArray[k] > 10) {
		setResult("NND_Colocalisation", row, 0);
	}
	else {
		setResult("NND_Colocalisation", row, 1);
	}
	setResult("Spot_Two_Count", row, spotTwoCountArray[k]);
	setResult("Spot_Three_Count", row, spotThreeCountArray[k]);
	if (spotTwoCountArray[k] != 2) {
		setResult("Spot_Two_Count_Parameter", row, 0);
	}
	else {
		setResult("Spot_Two_Count_Parameter", row, 1);
	}
	if (spotThreeCountArray[k] != 4) {
		setResult("Spot_Three_Count_Parameter", row, 0);
	}
	else {
		setResult("Spot_Three_Count_Parameter", row, 1);
	}
	
	row = row + 1;
}		


		
		
//Saves the final results table to the home folder for subsequent analysis and statistics
saveName = homeFolder + "Collated_Centroid_Distance_Results.csv";
saveAs("Results", saveName);


