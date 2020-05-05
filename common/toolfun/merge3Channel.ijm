/*This macro will merge two images and save the composite
 * INPUT
 * 	Input directory: path to folder where images are stored
 * 	Prefix for channel 1
 * 	Prefix for channel 2
 * 	Name for composite: Desire name for composite. Numbers will be automatically added
 * 						Example: You input "Merge" Final file name is "Merge-1-01.tif" and so on
 * 	OUTPUT
 * 	Merges will be saved at the input path with name define in Name for composite
 * 	
 * 	Jesus Vega-Lugo November 2019
 */

//Set inputs
//A pop up window will show asking for below values
#@ File (label = "Input directory", style = "directory") input
#@ String (label = "File suffix", value = ".tif") suffix
#@ String (label = "Input prefix of image to be merge as channel 1 (red)", value = "") ch1Prefix
#@ String (label = "Input prefix of image to be merge as channel 2 (green)", value = "") ch2Prefix
#@ String (label = "Input prefix of image to be merge as channel 3 (blue)", value = "") ch3Prefix
#@ String (label = "Name for composite", value = "Merge") compName

/*input = getDirectory("Input a directory");
*suffix = getString("File suffix");
*ch1Prefix = getString("Input prefix of image to be merge as channel 1 (red)");
*ch2Prefix = getString("Input prefix of image to be merge as channel 2 (green)");
*compName = getString("Name for composite");
*/

//Don't know what this is for
processFolder(input);

//Function goes through the folder specified in Input directory
//get list of images stored in it and take the ones containing the specified suffix and prefixes
function processFolder(input) {

	//makes a list of all files in the folder
	//list everything inside the folder, i.e. files and subfolders
	list = getFileList(input);
	list = Array.sort(list);

	//preallocate space for list of images names for each channel
	setOption("ExpandableArrays", true);
	listCh1 = newArray;
	listCh2 = newArray;
	listCh3 = newArray;
	//set a counter for indexing names into the lists
	c1 = 0;
	c2 = 0;
	c3 = 0;
	//rememeber this language starts counting at 0 (zero)
	for (i = 0; i < list.length; i++) {
		//check if the file is not a folder
		//! is the symbol for boolean complement
		if((!File.isDirectory(input + File.separator + list[i]))){
			//if the file is not a folder (above) check if its a .tif file 
			//containing the prefix for channel 1 store it in list for channel 1
			if(startsWith(list[i],ch1Prefix) && endsWith(list[i], suffix)){
			listCh1[c1] = list[i];
			c1++; //the ++ is the same as c1 = c1 + 1; 

			//do the same for channel 2
			}else if (startsWith(list[i],ch2Prefix) && endsWith(list[i], suffix)){
			listCh2[c2] = list[i];
			c2++; 
	        
	        }else if (startsWith(list[i],ch3Prefix) && endsWith(list[i], suffix)){
	        	listCh3[c3] = list[i];
	        	c3++; 
	        }
		}
	}
 //get the number of images on each channel
numCh1 = listCh1.length
numCh2 = listCh2.length
numCh3 = listCh3.length

 //check if number of images is the same in both channels
 if ((numCh1 == numCh2) && (numCh2 == numCh3)){ 
 	//if number of images is the same merge them
   for (i = 0; i<numCh1; i++) {
   	 setBatchMode(true);
   	 
   	 open(input + File.separator + listCh1[i]);
  	 open(input + File.separator + listCh2[i]);
  	 open(input + File.separator + listCh3[i]);
  	 
  	 run("Merge Channels...", "c1="+listCh1[i]+" c2="+listCh2[i]+" c3="+listCh3[i]+" create");
   
     if (i < 9) {
  	 	saveAs("Tiff", input + File.separator + compName + "-0" + toString(i+1));
  	 	setBatchMode(false);
     }else { 	
  	 	saveAs("Tiff", input + File.separator + compName + "-" + toString(i+1));
  	 	setBatchMode(false); 
     } 	 	 
  }
  //if number of images is not the same in both channels
  }else {
  	print("Number of images is not the same in all channels");
  	print("Channel 1 has" + toString(numCh1) + "images");
  	print("Channel 2 has" + toString(numCh2) + "images");
  	print("Channel 3 has" + toString(numCh3) + "images");
 }
 
}