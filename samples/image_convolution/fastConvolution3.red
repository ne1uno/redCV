Red [
	Title:   "Fast Convolution tests "
	Author:  "Francois Jouen"
	File: 	 %fastConvolution2.red
	Needs:	 'View
]

{rcvFastConvolve works on an unique channel for faster calculation
 here rcvFastConvolve is applied to each RGB channel of source image}

;required libs
#include %../../libs/tools/rcvTools.red
#include %../../libs/core/rcvCore.red
#include %../../libs/matrix/rcvMatrix.red
#include %../../libs/imgproc/rcvImgProc.red

;a fast laplacian mask
mask: [-1.0 0.0 -1.0 0.0 4.0 0.0 -1.0 0.0 -1.0]
isize: 256x256
isFile: false
factor: 0.5
delta: 	0.0

img1: rcvCreateImage isize
imgC1: rcvCreateImage img1/size		; create images for rgb
imgC2: rcvCreateImage img1/size
imgC3: rcvCreateImage img1/size
imgD:  rcvCreateImage img1/size		; and merged image
bitSize: 32

loadImage: does [
	canvas1/image: canvas2/image: canvas3/image: canvas4/image: black
	tmp: request-file
	if not none? tmp [
		isFile: true
		img1: rcvLoadImage tmp
		imgC1: rcvCreateImage img1/size					; create image for rgb
		imgC2: rcvCreateImage img1/size
		imgC3: rcvCreateImage img1/size
		imgD:  rcvCreateImage img1/size					; and merged image
		mat0: rcvCreateMat 'integer! bitSize img1/size	; create all matrices we need for argb
		mat1: rcvCreateMat 'integer! bitSize img1/size
		mat2: rcvCreateMat 'integer! bitSize img1/size
		mat3: rcvCreateMat 'integer! bitSize img1/size
		mat11: rcvCreateMat 'integer! bitSize img1/size
		mat21: rcvCreateMat 'integer! bitSize img1/size
		mat31: rcvCreateMat 'integer! bitSize img1/size
		canvas1/image: img1
		sl1/data: 0.0 sl2/data: 0.0
		convolve
	]
]


convolve: does [
	rcvSplit2Mat img1 mat0 mat1 mat2 mat3
	rcvConvolveMat mat1 mat11 img1/size mask factor delta
	rcvConvolveMat mat2 mat21 img1/size mask factor delta
	rcvConvolveMat mat3 mat31 img1/size mask factor delta
	rcvMat2Image mat11 imgC1 
	rcvMat2Image mat21 imgC2 
	rcvMat2Image mat31 imgC3 
	canvas2/image: imgC1
	canvas3/image: imgC2
	canvas4/image: imgC3
	rcvMerge2Image mat0 mat11 mat21 mat31 imgD
	canvas5/image: imgD
]



view win: layout [
	title "Fast Convolution tests"
	origin 10x10 space 10x10
	button 50 "Load" [loadImage]
	text 100 "Multiplier"
	sl1: slider 200 [factor: 0.5 + (face/data * 19.5) 
		f1/data: form to integer! factor
		if isFile [convolve]
	]
	f1: field 50 "0"
	text 100 "Brightness"
	sl2: slider 200 [delta: 0.0 + (face/data * 256.0) 
		f2/data: to integer! form delta
		if isFile [convolve]
	]
	f2: field 50 "0"
	pad 430x0
	button 50  "Quit" [quit]
	return
	text 100 "Source"
	pad 156x0 text "Channel 1: R"
	pad 176x0 text "Channel 2: G"
	pad 176x0 text "Channel 3: B"
	pad 170x0 text "RGB Filtered"
	return
	canvas1: base isize
	canvas2: base isize
	canvas3: base isize
	canvas4: base isize
	canvas5: base isize
	do [sl1/data: 0.0 sl2/data: 0.0]
]
	