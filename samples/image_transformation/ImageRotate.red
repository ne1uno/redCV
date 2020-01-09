Red [
	Title:   "Rotate image"
	Author:  "Francois Jouen"
	File: 	 %imageRotate.red
	Needs:	 'View
]


; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

margins: 10x10
img1: rcvCreateImage 512x512
iSize: img1/size
centerXY: iSize / 2
rot: 0.0

drawBlk: []
canvas: none

loadImage: does [
	canvas/image: none
	drawBlk: []
	tmp: request-file
	if not none? tmp [
		canvas/draw: none
		img1: rcvLoadImage tmp
		canvas/image: img1
		img1: to-image canvas	; force image size to 512x512
		iSize: img1/size
		centerXY: iSize / 2
		canvas/image: none
		rot: 0.0
		drawBlk: rcvRotateImage 0.625 144x144 rot centerXY img1
		canvas/draw: drawBlk
	]
]



; ***************** Test Program ****************************
view win: layout [
		title "Rotate Image"
		origin margins space margins
		button 60 "Load"	[loadImage]
		sl1: slider 230		[sz/text: form to integer! face/data * 360 
							 rot:  face/data * 360.0 drawBlk/7: rot]
		sz: field 30 "0"
		text 80 "Degrees"
		button 60 "Quit"	[Quit]
		return 
		canvas: base iSize black draw drawBlk	
		do [ sl1/data: 0.0]
]
