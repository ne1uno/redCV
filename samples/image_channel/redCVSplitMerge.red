Red [
	Title:   "Channel tests "
	Author:  "Francois Jouen"
	File: 	 %redCVChannels.red
	Needs:	 'View
]
;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red

fileName: ""
isFile: false
margins: 10x10
gSize: 256x256


loadImage: does [	
	isFile: false
	canvas/image: none
	canvasR/image: none
	canvasG/image: none
	canvasB/image: none
	canvasRGB/image: none
	sb1/text: ""
	tmp: request-file 
	if not none? tmp [		
		fileName: to string! to-local-file tmp	
		rimg: load tmp	
		imgR: make image! reduce [rimg/size black]
		imgG: make image! reduce [rimg/size black]
		imgB: make image! reduce [rimg/size black]
		imgA: make image! reduce [rimg/size black]
		imgRGB: make image! reduce [rimg/size black]
		canvas/image: rimg
		isFile: true
	]
]

splitImage: func[][
	if isFile [
		t1: now/time/precise
		blk: rcvSplit2 rimg
		imgR: blk/1 imgG: blk/2 imgB: blk/3 imgA: blk/4
		canvasR/image: imgR
		canvasG/image: imgG
		canvasB/image: imgB
		sb1/text: copy "Rendered in "
		t2: now/time/precise
		sb1/text: rejoin [ "Rendered in " form rcvElapsed t1 t2  " ms"]
	]	
]

mergeImage: func[][
	if isFile [
		t1: now/time/precise
		rcvMerge2 imgR imgG imgB imgA imgRGB
		canvasRGB/image: imgRGB
		sb1/text: copy "Rendered in "
		t2: now/time/precise
		sb1/text: rejoin [ "Rendered in " form rcvElapsed t1 t2  " ms"]
	]	
]

; ***************** Test Program ****************************
view win: layout [
		title "RGB Channels Test with redCV"
		origin margins space margins
		button 60 "Load"	[loadImage]
		button 60 "Split"	[splitImage]
		button 60 "Merge"	[mergeImage]
		button 60 "Quit" 	[Quit]
		return 
		text 256  "Source"
		text 256  "Red"
		text 256  "Green"
		text 256  "Blue"
		text 256  "RGB"
		return
		canvas:  	base gSize black	
		canvasR: 	base gSize red
		canvasG: 	base gSize green
		canvasB: 	base gSize blue
		canvasRGB: 	base gSize white
		return
		sb1: field  1320
]