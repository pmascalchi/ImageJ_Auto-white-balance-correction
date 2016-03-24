// Original code by Vytas Bindokas; Oct 2006, Univ. of Chicago
// https://digital.bsd.uchicago.edu/docs/imagej_macros/_graybalancetoROI.txt
// This macro white balances RGB to a selected region (equal R,G,B =gray)
//    draw a region prior to running the macro

// Code modified by Patrice Mascalchi, 2014, Univ. of Cambridge UK
// Ask for region to be drawn / Check region existence / check RGB at start / compaction of code (loop)

setTool(0);
waitForUser("Draw a region over background");
run("Set Measurements...", "  mean redirect=None decimal=3");
if (selectionType==-1) exit("you must draw a region first");

ti = getTitle;
run("Select None");
//setBatchMode(true);

run("Duplicate...", "title=rgbstk-temp");
origBit = bitDepth;
if (bitDepth() != 24) exit("Active image is not RGB");
run("RGB Stack");
run("Restore Selection");

val = newArray(3);
for (s=1;s<=3;s++) {
	setSlice(s);
	run("Measure");
	val[s-1] = getResult("Mean");
}

run("Select None");

run("16-bit");
run("32-bit");
Array.getStatistics(val, min, max, mean);

for (s=1; s<=3; s++) {
	setSlice(s);
	dR = val[s-1] - mean;
	if (dR < 0) {
		run("Add...", "slice value="+ abs(dR));
	} else if (dR > 0) {
		run("Subtract...", "slice value="+ abs(dR));
	}
}

run("16-bit");
run("Convert Stack to RGB");

rename(ti + "-corrected");
//closeWin("Results");
closeWin("rgbstk-temp");

setBatchMode("exit and display");
run("Tile");			// Can be removed

// ------------------------------------------------------------------------------------------
// close any window without returning any error
function closeWin(name) {
	if (isOpen(name)) {
	     selectWindow(name);
	     run("Close");
	}
}