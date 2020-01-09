Red [
	Title:   "Matrix tests "
	Author:  "Francois Jouen"
	File: 	 %matRoberts.red
	Needs:	 'View
]

; required libs
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/tools/rcvTools.red
#include %../../libs/imgproc/rcvImgProc.red

isize: 256x256
bitSize: 8

img1: rcvCreateImage isize
img2: rcvCreateImage isize
img3: rcvCreateImage isize
img4: rcvCreateImage isize


loadImage: does [
	canvas1/image/rgb: black
	canvas2/image/rgb: black
	canvas3/image/rgb: black
	canvas4/image/rgb: black
	
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		img2: rcvCreateImage img1/size
		img3: rcvCreateImage img1/size
		img4: rcvCreateImage img1/size
		mat1: rcvCreateMat 'integer! bitSize img1/size
		mat2: rcvCreateMat 'integer! bitSize img1/size
		mat3: rcvCreateMat 'integer! bitSize img1/size
		mat4: rcvCreateMat 'integer! bitSize img1/size
		
		canvas1/image: img1
		rcvImage2Mat img1 mat1 								; Converts to  grayscale image and to 1 Channel matrix [0..255]  
		rcvRoberts mat1 mat2 img1/size 1 1					; Roberts convolution x
		rcvRoberts mat1 mat3 img1/size 2 1					; Roberts convolution y
		rcvRoberts mat1 mat4 img1/size 3 1					; Roberts convolution x and y
		rcvMat2Image mat2 img2								; from matrix to red image
		rcvMat2Image mat3 img3								; from matrix to red image
		rcvMat2Image mat4 img4	
		canvas2/image: img2
		canvas3/image: img3
		canvas4/image: img4
		rcvReleaseMat mat1
		rcvReleaseMat mat2
		rcvReleaseMat mat3
		rcvReleaseMat mat4
	]
]


; ***************** Test Program ****************************
view win: layout [
		title "Roberts Operator on matrix"
		button "Load" [loadImage]
		
		button 60 "Quit" [	rcvReleaseImage img1 
							rcvReleaseImage img2
							Quit]
		return
		text "Source" 100 pad 156x0 
		text "X"
		pad 176x0 
		text "Y"
		pad 176x0 
		text "X + Y;"
		
		return
		canvas1: base isize img1
		canvas2: base isize img2
		canvas3: base isize img3
		canvas4: base isize img4
]
