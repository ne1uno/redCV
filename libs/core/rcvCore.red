Red [
	Title:   "Red Computer Vision: Core functions"
	Author:  "Francois Jouen"
	File: 	 %rcvCore.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]


{To know: loaded images by red are in RGBA format (a tuple )
Images are 8-bit [0..255] by channel and internally use bytes as a binary string
Actually Red can't create 1 2 or 3 channels images : only 4 channels
Actually Red can't create 16-bit (0..65536) 32-bit or 64-bit (0.0..1.0) images

pixel and FF0000h >> 16 	: Red
pixel and FF00h >> 8		: Green
pixel and FFh				: Blue
pixel >>> 24				: Alpha
}


; ********* image basics **********

rcvCreateImage: function [
"Create empty (black) image"
	size 	[pair!]  "Image size"
][
	make image! reduce [size black]
]


rcvReleaseImage: routine [
"Delete image from memory"
	src [image!]
][
	image/delete src
]


rcvReleaseAllImages: function [
"Delete all images"
	list [block!] "List of images to delete"
][
	foreach img list [rcvReleaseImage img]
]


rcvLoadImage: function [
"Loads image from file"
	fileName [file!]  
	/grayscale		
][
	src: load fileName
	if grayscale [
		gray: rcvCreateImage src/size
		rcv2Gray/average src gray 
		rcvCopyImage gray src
	]
	src
]


rcvLoadImageAsBinary: function [
"Load image from file and return image as binary"
	fileName [file!] 
	/alpha			 
][
	tmp: load fileName
	either alpha [str: tmp/argb] [str: tmp/rgb]
	rcvReleaseImage tmp
	str
]

rcvGetImageFileSize: function [
"Gets Image File Size as a pair!"
	fileName 	[file!] 
][
	tmp: load fileName
	isize: tmp/size
	rcvReleaseImage tmp
	isize
]

rcvGetImageSize: function [
"Returns Image Size as a pair!"
	src 	[image!]  
][
	src/size
]

rcvSaveImage: function [
"Save image to file (only png actually)"
	src 		[image!] 
	fileName 	[file!] 
][
	save fileName src
]


rcvCopyImage: routine [
"Copy source image to destination image"
    src1 [image!]
    dst  [image!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
           	pixD/value: pix1/value
           	pix1: pix1 + 1
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


rcvCloneImage: function [
"Returns a copy of source image"
	src 	[image!] 
][
	;dst: make image! reduce [src/size black]
	dst: make image! src/size
	rcvCopyImage src dst
	dst
]

; Random New To be documented
rcvRandImage: routine [
	src1	[image!]
	/local
    pix1 [int-ptr!]
    handle1 h w x y
    r g b int
][
	handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
    	 x: 0
      	 while [x < w][
      	 	r: _random/rand and FFh
      	 	g: _random/rand and FFh
      	 	b: _random/rand and FFh
      	 	x: x + 1
      	 	pix1/value: (255 << 24) OR (r << 16 ) OR (g  << 8) OR b
           	pix1: pix1 + 1
      	 ]
      	 y: y + 1
	]  
	image/release-buffer src1 handle1 yes	
]


rcvRandomImage: function [
"Create a random uniform or pixel random image"
	size 	[pair!] 	
	value 	[tuple!] 	
	return: [image!]
	/uniform /alea /fast 

][
	case [
		uniform [img: make image! reduce [size random value]]
		alea 	[img: make image! reduce [size black] forall img [img/1: random value ]]
		fast 	[img: make image! reduce [size black] rcvRandImage img]
	] 
	img
]

rcvZeroImage: function [src [image!]
"All pixels to 0"
][
	src/argb: black
]

rcvColorImage: function [src [image!] acolor [tuple!]
"All pixels to color"
][
	src/rgb: 	acolor	;--rgb value 
	src/alpha: 	0		;--opaque image
]


; ********* Image Alpha Routine **********
rcvSetAlpha: routine [
"Sets image transparency"
	src  	[image!]
    dst   	[image!]
    alpha 	[integer!]
    /local
	pixS 	[int-ptr!]
    pixD 	[int-ptr!]
    handleS	[integer!] 
    handleD	[integer!] 
    h		[integer!]
    w		[integer!] 
    x 		[integer!]
    y 		[integer!]
    r		[integer!]
    g		[integer!]
    b		[integer!] 
][
	handleS: 0
    handleD: 0
    pixS: image/acquire-buffer src :handleS
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       		r: pixS/value and 00FF0000h >> 16 
    		g: pixS/value and FF00h >> 8 
    		b: pixS/value and FFh 	 
       		pixD/value: (alpha << 24) OR (r << 16 ) OR (g << 8) OR b
           	pixS: pixS + 1
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handleS no
    image/release-buffer dst handleD yes
]


;************** Pixel Access Routines **********
rcvGetPixel_old: routine [
"Returns pixel value at xy coordinates as tuple"
	src1 		[image!] 
	coordinate 	[pair!] 
	return: 	[tuple!]
	/local 
		pix1 	[int-ptr!]
		handle1	[integer!] 
		w		[integer!] 
		pos		[integer!] 
		t		[red-tuple!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
   	pix1: pix1 + pos		; for img/node offset
    t: image/rs-pick src1 pos
    image/release-buffer src1 handle1 no
    as red-tuple! stack/set-last as cell! t
]

rcvGetPixel: routine [
"Returns pixel value at xy coordinates as tuple"
	src1 		[image!] 
	coordinate 	[pair!] 
	return: 	[tuple!]
	/local 
		pix1 	[int-ptr!]
		handle1	[integer!] 
		w		[integer!] 
		pos		[integer!] 
		t		[red-tuple!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
   	pix1: pix1 + pos		; for img/node offset
    t: tuple/rs-make [
			pix1/value and FF0000h >> 16
			pix1/value and FF00h >> 8
			pix1/value and FFh
			255 - (pix1/value >>> 24)
	]
    image/release-buffer src1 handle1 no
    as red-tuple! stack/set-last as cell! t
]

rcvGetPixelAsInteger: routine [
"Returns pixel value at xy coordinates as integer"
	src1 		[image!] 
	coordinate 	[pair!] 
	return: [integer!]
	/local 
		pix1 	[int-ptr!]
		handle1	[integer!] 
		w		[integer!]
		pos		[integer!]
		a		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
    pix1: pix1 + pos
    a: 255 - (pix1/value >>> 24)
    r: pix1/value and FF0000h >> 16
    g: pix1/value and FF00h >> 8
    b: pix1/value and FFh
   	image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b
]

rcvSetPixel: routine [
"Set pixel value at xy coordinates"
	src1 		[image!] 
	coordinate 	[pair!] 
	color 		[tuple!]
	/local
		p		[byte-ptr!]
		pix1 	[int-ptr!]
		handle1	[integer!] 
		w		[integer!]
		pos		[integer!]
		tp		[red-tuple!]
		r 		[integer!]
		g		[integer!] 
		b 		[integer!]
		a		[integer!]
][
	tp: as red-tuple! color
	p: (as byte-ptr! tp) + 4
	r: as-integer p/1
	g: as-integer p/2
	b: as-integer p/3
	a: either TUPLE_SIZE?(tp) > 3 [255 - as-integer p/4][255]
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    pos: (coordinate/y * w) + coordinate/x
    pix1: pix1 + pos
    pix1/value: (a << 24) or (r << 16) or (g << 8) or b
    image/release-buffer src1 handle1 yes
]

rcvIsAPixel: routine [
"Returns true if  pixel value is greater than threshold"
	src 		[image!] 
	coordinate 	[pair!] 
	threshold 	[integer!] 
	return: 	[logic!]
	/local 
		v		[integer!]
		a		[integer!] 
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		mean	[integer!]
][
	v: rcvGetPixelAsInteger src coordinate
	a: 255 - (v >>> 24)
    r: v and 00FF0000h >> 16 
    g: v and FF00h >> 8 
    b: v and FFh
    mean: (r + g + b) / 3
    either mean > threshold [true] [false]
]


;************** Pixel Access Functions **********
rcvPickPixel: function [
"Returns pixel value at xy coordinates as tuple"
	src 		[image!] 
	coordinate 	[pair!]  
][
	pick src coordinate
]


rcvPokePixel: function [
"Set pixel value at xy coordinates"
	src 		[image!]  
	coordinate  [pair!]   
	val 		[tuple!]  

] [
	poke src coordinate val
]

;***************** IMAGE CONVERSION ROUTINES *****************
rcvConvert: routine [
"General image conversion routine"
    src1 [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        rf		[float!]
        gf		[float!] 
        bf		[float!] 
        sf		[float!]
        handle1	[integer!] 
        handleD	[integer!] 
        h		[integer!] 
        w		[integer!] 
        x		[integer!] 
        y		[integer!]
        r		[integer!] 
        g		[integer!] 
        b		[integer!] 
        a		[integer!] 
        s		[integer!] 
        mini	[integer!] 
        maxi	[integer!]
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    s: 0
    sf: 0.0
    mini: 0
    maxi: 0
    while [y < h] [
       x: 0
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        s: (r + g + b) / 3 
        rf: as float! r
        gf: as float! g
        bf: as float! b
        switch op [
        	0 [pixD/value: pix1/value]
        	1 [pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray average
          111 [ r: (r * 21) / 100
              		g: (g * 72) / 100 
              		b: (b * 7) / 100
              		s: r + g + b
                  	pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray luminosity
          112 [ either r > g [mini: g][mini: r] 
              		  either b > mini [mini: mini][ mini: b] 
              		  either r > g [maxi: r][maxi: g] 
              		  either b > maxi [maxi: b][ maxi: maxi] 
              		  s: (mini + maxi) / 2
              		  pixD/value: (a << 24) OR (s << 16 ) OR (s << 8) OR s] ;RGB2Gray lightness
          113 [sf: rf + gf + bf 
          		r: as integer! ((rf / sf) * 255)
          		g: as integer! ((gf / sf) * 255)
          		b: as integer! ((bf / sf) * 255)
          		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
          	] ; Normalized RGB by sum
          114 [ sf: sqrt((pow rf 2.0) + (pow gf 2.0) + (pow bf 2.0))
          		r: as integer! ((rf  / sf) * 255)
          		g: as integer! ((gf  / sf) * 255)
          		b: as integer! ((bf  / sf) * 255)
          		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
          	] ; Normalized RGB by square sum
        	2 [pixD/value: (a << 24) OR (b << 16 ) OR (g << 8) OR r] ;2BGRA
            3 [pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2RGBA
            4 [either s > 127 [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0] 
            	   pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2BW
            5 [ either s > 127 [r: 0 g: 0 b: 0] [r: 255 g: 255 b: 255] 
            	   pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b] ;2WB
        ]
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

;***************** IMAGE CONVERSION FUNCTIONS *****************
rcv2NzRGB: function [ 
"Normalizes the RGB values of an image" 
	src [image!]    
	dst [image!]    
	/sum/sumsquare  
][
	case [
		sum  		[rcvConvert src dst 113]
		sumsquare 	[rcvConvert src dst 114]
	] 
]
 
rcv2Gray: function [ 
"Convert RGB image to Grayscale acording to refinement" 
	src [image!]  
	dst [image!] 
	/average /luminosity /lightness 
][
	case [
		average 	[rcvConvert src dst 1]
		luminosity 	[rcvConvert src dst 111]
		lightness 	[rcvConvert src dst 112]
	]
]

rcv2BGRA: function [
"Convert RGBA => BGRA"
	src [image!] 
	dst [image!] 
][
	rcvConvert src dst 2 
]

rcv2RGBA: function [
"Convert BGRA => RGBA"
	src [image!] 
	dst [image!]
][
	rcvConvert src dst 3 
]

rcv2BW: function [
"Convert RGB image => Black and White" 
	src [image!] 
	dst [image!]
][
	rcvConvert src dst 4
]

rcv2WB: function [
	"Convert RGB image => White and Black" 
	src [image!] 
	dst [image!]
][
	rcvConvert src dst 5
]

;******************** BW Filter Routine ******************
rcvFilterBW: routine [
"General B&W Filter routine"
    src1 		[image!]
    dst  		[image!]
    thresh		[integer!]
    maxValue 	[integer!]
    op	 		[integer!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1	[integer!] 
        handleD	[integer!] 
        h 		[integer!]
        w		[integer!] 
        x		[integer!] 
        y		[integer!]
        r 		[integer!]
        g		[integer!] 
        b 		[integer!]
        a		[integer!] 
        v		[integer!]
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh
        v: (r + g + b) / 3
        r: v
        g: v
        b: v
        switch op [
        	0 [either v >= thresh [r: 255 g: 255 b: 255] [r: 0 g: 0 b: 0]]
        	1 [either v > thresh [r: maxValue g: maxValue b: maxValue] [r: 0 g: 0 b: 0]]
        	2 [either v > thresh [r: 0 g: 0 b: 0] [r: maxValue g: maxValue b: maxValue]]
        	3 [either v > thresh [r: thresh g: thresh b: thresh] [r: r g: g b: b]]
        	4 [either v > thresh [r: r g: g b: b] [r: 0 g: 0 b: 0]]
        	5 [either v > thresh [r: 0 g: 0 b: 0] [r: r g: g b: b]]
        ]  
        pixD/value: FF000000h or ((a << 24) OR (r << 16 ) OR (g << 8) OR b)    
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]

;******************** BW Filter Functions ******************
rcv2BWFilter: function [
"Convert RGB image => Black and White according to threshold"
	src [image!] 
	dst [image!] 
	thresh [integer!]
][
	rcvFilterBW src dst thresh 0 0
]

rcvThreshold: function [
"Applies fixed-level threshold to image"
	src [image!] 
	dst [image!] 
	thresh [integer!] 
	mValue [integer!]
	/binary /binaryInv /trunc /toZero /toZeroInv
][
	case [
		binary 		[rcvFilterBW src dst thresh mValue 1]
		binaryInv 	[rcvFilterBW src dst thresh mValue 2]
		trunc		[rcvFilterBW src dst thresh mValue 3]
		toZero 		[rcvFilterBW src dst thresh mValue 4]
		toZeroInv 	[rcvFilterBW src dst thresh mValue 5]
	]
]
 
rcvInvert: function [
"Similar to NOT image"
	src [image!] 
	dst [image!]
][
	dst/rgb:  complement src/rgb 
]

;***************** LOGICAL OPERATOR ON IMAGE ROUTINES ************


rcvNot: routine [
"dst: NOT src"
    src1 		[image!]
    dst  		[image!]
    /local
        pix1 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1	[integer!] 
        handleD	[integer!] 
        h 		[integer!]
        w		[integer!] 
        x		[integer!] 
        y		[integer!]
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD

    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
           pixD/value: FF000000h or NOT pix1/value
           pix1: pix1 + 1
           pixD: pixD + 1
           x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]


rvcLogical: routine [
"General routine for logical operators on image"
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handle2 handleD h w x y
][
	handle1: 0
	handle2: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD
	
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			switch op [
				1 [pixD/value: FF000000h or pix1/Value AND pix2/value]
				2 [pixD/value: FF000000h or pix1/Value OR pix2/Value]
				3 [pixD/value: FF000000h or pix1/Value XOR pix2/Value]
				4 [pixD/value: FF000000h or NOT pix1/Value AND pix2/Value]
				5 [pixD/value: FF000000h or NOT pix1/Value OR pix2/Value]
				6 [pixD/value: FF000000h or NOT pix1/Value XOR pix2/Value]
				7 [either pix1/Value > pix2/Value [pixD/value: pix2/Value][pixD/value: FF000000h or pix1/Value]]
           		8 [either pix1/Value > pix2/Value [pixD/value: pix1/Value] [pixD/value: FF000000h or pix2/Value]]
			]
			pix1: pix1 + 1
			pix2: pix2 + 1
			pixD: pixD + 1
			x: x + 1
		]
		x: 0
		y: y + 1
		
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

; ************* Logical operator functions ***************************
rcvAND: function [
"dst: src1 AND src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 1
]

rcvOR: function [
"dst: src1 OR src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 2
]

rcvXOR: function [
"dst: src1 XOR src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2  dst 3
]

rcvNAND: function [
"dst: src1 NAND src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 4
]

rcvNOR: function [
"dst: src1 NOR src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 5
]

rcvNXOR: function [
"dst: src1 NXOR rc2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 6
]


; ********** Math Operators on image **********
rcvMath: routine [
"General Routine for math operators on image"
	src1 	[image!]
	src2 	[image!]
	dst	 	[image!]
	op 		[integer!]
	/local 
	pix1 	[int-ptr!]
	pix2 	[int-ptr!]
	pixD 	[int-ptr!]
	handle1	[integer!] 
	handle2 [integer!]
	handleD [integer!]
	h		[integer!] 
	w 		[integer!]
	x 		[integer!]
	y		[integer!]
][
	handle1: 0
	handle2: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD	
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			switch op [
				0 [pixD/value: pix1/Value]
				1 [pixD/value: FF000000h or (pix1/Value + pix2/value)]
				2 [pixD/value: FF000000h or (pix1/Value - pix2/Value)]
				3 [pixD/value: FF000000h or (pix1/Value * pix2/Value)]
				4 [pixD/value: FF000000h or (pix1/Value / pix2/Value)]
				5 [pixD/value: FF000000h or (pix1/Value // pix2/Value)]
				6 [pixD/value: FF000000h or (pix1/Value % pix2/Value)]
				7 [either pix1/Value > pix2/Value [pixD/value: FF000000h or (pix1/Value - pix2/Value) ]
				                       [pixD/value: FF000000h or (pix2/Value - pix1/Value)]]
				8 [pixD/value: FF000000h or ((pix1/Value + pix2/value) / 2)]
			]
			pix1: pix1 + 1
			pix2: pix2 + 1
			pixD: pixD + 1
			x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

rcvAdd: function [
"dst: src1 + src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 1
]

rcvSub: function [
"dst: src1 - src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 2
]

rcvMul: function [
"dst: src1 * src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 3
]

rcvDiv: function [
"dst: src1 / src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 4
] 

rcvMod: function [
"dst: src1 // src2 (modulo)"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 5
] 

rcvRem: function [
"dst: src1 % src2 (remainder)"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 6
] 

rcvAbsDiff: function [
"dst: absolute difference src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvMath src1 src2 dst 7
] 

rcvMIN: function [
"dst: minimum src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 7
]

rcvMAX: function [
"dst: maximum src1 src2"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rvcLogical src1 src2 dst 8
]

;*************Logarithmic Image Processing Model ************

rcvLIP: routine [
	src1 [image!]
	src2 [image!]
	dst	 [image!]
	op [integer!]
	/local 
	pix1 [int-ptr!]
	pix2 [int-ptr!]
	pixD [int-ptr!]
	handle1 handle2 handleD h w x y
	a1 r1 g1 b1
	a2 r2 g2 b2 
	fa fr fg fb
][
	handle1: 0
	handle2: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pix2: image/acquire-buffer src2 :handle2
	pixD: image/acquire-buffer dst :handleD	
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			a1: pix1/value >>> 24
    		r1: pix1/value and 00FF0000h >> 16 
    		g1: pix1/value and FF00h >> 8 
    		b1: pix1/value and FFh 	
    		a2: pix2/value >>> 24
    		r2: pix2/value and 00FF0000h >> 16 
    		g2: pix2/value and FF00h >> 8 
    		b2: pix2/value and FFh
			switch op [
				1 [fr: (r1 + r2) - ((r1 * r2) / 256) 
				   fg: (g1 + g2) - ((g1 * g2) / 256)
			       fb: (b1 + b2) - ((b1 * b2) / 256)
			    ]
			    2 [ fr: (256 * (r1 - r2)) / (256 - r2)
			    	fg: (256 * (g1 - g2)) / (256 - g2)
			    	fb: (256 * (b1 - b2)) / (256 - b2)
			    ]
			]
			pixD/value: (255 << 24) OR (fr << 16 ) OR (fg << 8) OR fb
			pix1: pix1 + 1
			pix2: pix2 + 1
			pixD: pixD + 1
			x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

rcvAddLIP: function [
"dest(x,y)= src1(x,y)+ src(x,y) – (src1(x,y)* src2(x,y)) / M"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvLIP src1 src2 dst 1
]

rcvSubLIP: function [
"im_out(x,y) = M.(im_in1(x,y) - im_in2(x,y)) / ( M - im_in2(x,y))"
	src1 [image!] 
	src2 [image!] 
	dst  [image!]
][
	rcvLIP src1 src2 dst 2
]


; ********** Math operators routine with scalar (tuple or integer) *********
; integer scalar
rcvMathS: routine [
"General routine for scalar on image"
	src1 	[image!]
	dst 	[image!]
	v	 	[integer!]
	op 		[integer!]
	/local 
	pix1 	[int-ptr!]
	pix2 	[int-ptr!]
	pixD 	[int-ptr!]
	handle1	[integer!] 
	handleD	[integer!] 
	h		[integer!] 
	w		[integer!] 
	x		[integer!] 
	y		[integer!] 
][
	handle1: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pixD: image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			switch op [
				0 [pixD/value: pix1/Value ]
				1 [pixD/value: FF000000h or (pix1/Value + v)]
				2 [pixD/value: FF000000h or (pix1/Value - v)]
				3 [pixD/value: FF000000h or (pix1/Value * v)]
				4 [pixD/value: FF000000h or (pix1/Value / v)]
				5 [pixD/value: FF000000h or (pix1/Value // v)]
				6 [pixD/value: FF000000h or (pix1/Value % v)]
				7 [pixD/value: FF000000h or (pix1/Value << v)]
				8 [pixD/value: FF000000h or (pix1/Value >> v)]
				9 [pixD/value: FF000000h or as integer! (pow as float! pix1/Value as float! v)]
			   10 [pixD/value: FF000000h or as integer! (sqrt as float! pix1/Value >> v)]
			]
			pix1: pix1 + 1
			pixD: pixD + 1
			x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]

; Float scalar
rcvMathF: routine [
	src1 	[image!]
	dst 	[image!]
	v	 	[float!]
	op 		[integer!]
	/local 
	pix1 	[int-ptr!]
	pix2 	[int-ptr!]
	pixD 	[int-ptr!]
	handle1	[integer!] 
	handleD	[integer!] 
	h		[integer!] 
	w		[integer!] 
	x 		[integer!]
	y 		[integer!]
	a 		[integer!]
	r 		[integer!]
	g 		[integer!]
	b		[integer!]
	fa		[integer!]
	fr		[integer!] 
	fg		[integer!] 
	fb		[integer!]
][
	handle1: 0
	handleD: 0
	pix1: image/acquire-buffer src1 :handle1
	pixD: image/acquire-buffer dst :handleD
	w: IMAGE_WIDTH(src1/size) 
	h: IMAGE_HEIGHT(src1/size)
	x: 0
	y: 0
	while [y < h] [
		while [x < w][
			a: pix1/value >>> 24
    		r: pix1/value and 00FF0000h >> 16 
    		g: pix1/value and FF00h >> 8 
    		b: pix1/value and FFh 	
			switch op [
				1 [ fa: as integer! (pow as float! a v)
					fr: as integer! (pow as float! r v)
					fg: as integer! (pow as float! g v)
					fb: as integer! (pow as float! b v)
				  ]
			    2 [ fa: as integer! (sqrt as float! a >> as integer! v)
			    	fr: as integer! (sqrt as float! r >> as integer! v)
					fg: as integer! (sqrt as float! g >> as integer! v)
					fb: as integer! (sqrt as float! b >> as integer! v)]
				3  [ fa: as integer! (v * a)
					 fr: as integer! (v * r)
					 fg: as integer! (v * g)
					 fb: as integer! (v * b)] ; * for image intensity
				4 [ fa: as integer! ((as float! a) / v)
					fr: as integer! ((as float! r) / v)
					fg: as integer! ((as float! g) / v)
					fb: as integer! ((as float! b) / v)] ; /
				5 [ fa: as integer! (v + a)
					fr: as integer! (v + r)
					fg: as integer! (v + g)
					fb: as integer! (v + b)] ; +
				6 [ fa: as integer! (v - a)
					fr: as integer! (v - r)
					fg: as integer! (v - g)
					fb: as integer! (v - b)] ; -
			]
			pixD/value: FF000000h or ((fa << 24) OR (fr << 16 ) OR (fg << 8) OR fb)
			pix1: pix1 + 1
			pixD: pixD + 1
			x: x + 1
		]
		x: 0
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]

; tuples mettre à jour la doc
rcvMathT: routine [
    src1 	[image!]
    dst  	[image!]
    t		[tuple!]
    op1 	[integer!]
    flag	[logic!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        a r g b
        rt gt bt
        tp
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    rt: t/array1 and FFh 
	gt: t/array1 and FF00h >> 8 
	bt: t/array1 and 00FF0000h >> 16 
    while [y < h] [
    	 x: 0
      	 while [x < w][
           	a: pix1/value >>> 24
           	r: pix1/value and 00FF0000h >> 16
           	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	
          	switch op1 [
          		0 [r: r g: g b: b]
          		1 [r: r + rt g: g + gt b: b + bt]
           		2 [r: r - rt g: g - gt b: b - bt]
           		3 [r: r * rt g: g * gt b: b * bt]
           		4 [r: r / rt g: g / gt b: b / bt]
           		5 [r: r // rt g: g // gt b: b // bt]
           		6 [r: r % rt g: g % gt b: b % bt]
          	]
          	
          	if flag [
          		if all [r > 255 g > 255 b > 255] [r: 255 g: 255 b: 255]
          		if all [r < 0 g < 0 b < 0] [r: 0 g: 0 b: 0]
          	]
          	pixD/value: (a << 24) OR (r << 16 ) OR (g  << 8) OR b
           	pix1: pix1 + 1
           	pixD: pixD + 1
           	x: x + 1
       	]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]




; ********** Math operators functions with scalar ****************
;mettre à jour dans la doc
rcvAddS: function [
"dst: src + integer or float value"
	src [image!] 
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = integer! [rcvMathS src dst val 1]
	if t = float!	[rcvMathF src dst val 5]
]

rcvSubS: function [
"dst: src - integer or float value"
	src [image!] 
	dst [image!] 
	val [number!]
][
	t: type? val
	if t = integer! [rcvMathS src dst val 2]
	if t = float!	[rcvMathF src dst val 6]
]

rcvMulS: function [
"dst: src * integer or float value"
	src [image!] 
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = integer! [rcvMathS src dst val 3]
	if t = float!	[rcvMathF src dst val 3]
]

rcvDivS: function [
"dst: src / integer or float value"
	src [image!] 
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = integer! [rcvMathS src dst val 4]
	if t = float!	[rcvMathF src dst val 4]
]

rcvPow: function [
"dst: src ^integer! or float! value"
	src [image!]  
	dst [image!] 
	val [number!] 
][
	t: type? val
	if t = float!   [rcvMathF src dst val 1] 
	if t = integer! [rcvMathS src dst val 9] 
]


rcvSQR: function [
"Image square root"
	src [image!] 
	dst [image!] 
	val [number!]  
][
	t: type? val
	if t = integer! [rcvMathS src dst val 10] 
	if t = float!   [rcvMathF src dst val 2]
]

rcvModS: function [
"dst: src // integer! value (modulo)"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	rcvMathS src dst val 5
]

rcvRemS: function [
"dst: src % integer! value (remainder)"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	rcvMathS src dst val 6
]


rcvLSH: function [
"Left shift image by value"
	src [image!] 
	dst [image!]
	val [integer!] 
][
	rcvMathS src dst val 7
]

rcvRSH: function [
"Right Shift image by value"
	src [image!] 
	dst [image!] 
	val [integer!] 
][
	rcvMathS src dst val 8
]


rcvAddT: function [
"dst: src + tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!] 
	flag	[logic!]
][
	rcvMathT src dst val 1 flag
]

rcvSubT: function [
"dst: src - tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!]
][
	rcvMathT src dst val 2 flag
]

rcvMulT: function [
"dst: src * tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 3 flag
]

rcvDivT: function [
"dst: src / tuple! value"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 4 flag
]

rcvModT: function [
"dst: src // tuple! value (modulo)"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 5 flag
]

rcvRemT: function [
"dst: src % tuple! value (remainder)"
	src 	[image!] 
	dst 	[image!] 
	val 	[tuple!]
	flag	[logic!] 
][
	rcvMathT src dst val 6 flag
]

; ************ logical operators and scalar (tuple!) on image **********

rcvANDS: function [
"dst: src AND tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	rvcLogical src tmp dst 1
	tmp: none
]

rcvORS: function [
"dst: src OR tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	rvcLogical src tmp dst 2
	tmp: none
]

rcvXORS: function [
"dst: src XOR tuple! as image"
	src [image!] 
	dst [image!] 
	value [tuple!] 
][
	tmp: make image! reduce[src/size value]
	rvcLogical src tmp dst 3
	tmp: none
]

; ;********** stats on 2 images ***********************
 
rcvMeanImages: function [
"Calculates pixels mean value for 2 images"
	src1 [image!] 
	src2 [image!] dst [image!]
][
	rcvMath src1 src2 dst 8
]

;******************** SUB-ARRAYS ************************

rcvSChannel: routine [
    src  [image!]
    dst  [image!]
    op	 [integer!]
    /local
        pix1 [int-ptr!]
        pixD [int-ptr!]
        handle1 handleD h w x y
        r g b a
][
    handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src/size)
    h: IMAGE_HEIGHT(src/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       	a: pix1/value >>> 24
       	r: pix1/value and 00FF0000h >> 16 
        g: pix1/value and FF00h >> 8 
        b: pix1/value and FFh 
        switch op [
        	0 [pixD/value: pix1/value]
            1 [pixD/value: (a << 24) OR (r << 16 ) OR (r << 8) OR r]	;Red Channel
            2 [pixD/value: (a << 24) OR (g << 16 ) OR (g << 8) OR g] 	;Green Channel 
            3 [pixD/value: (a << 24) OR (b << 16 ) OR (b << 8) OR b] 	;blue Channel
            4 [pixD/value: (a << 24) OR (a << 16 ) OR (a << 8) OR a] 	;alpha Channel
        ]
        pix1: pix1 + 1
        pixD: pixD + 1
        x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src handle1 no
    image/release-buffer dst handleD yes
]

rcvSplit: function [
"Split source image in RGB and alpha separate channels"
	src [image!] 
	dst [image!]
	/red /green /blue /alpha
][
	case [
		red 	[rcvSChannel src dst 1]
		green 	[rcvSChannel src dst 2]
		blue 	[rcvSChannel src dst 3]
		alpha	[rcvSChannel src dst 4]
	]
]

rcvSplit2: function [
"Split source image in RGB and alpha separate channels"
	src 	[image!] 
	return: [block!]
][
	size: src/size
	r: make image! reduce [size black]
	g: make image! reduce [size black]
	b: make image! reduce [size black]
	a: make image! reduce [size black]
	rcvSChannel src r 1
	rcvSChannel src g 2
	rcvSChannel src b 3
	rcvSChannel src a 4
	reduce [r g b a]
]

rcvMerge: routine [
    src1  [image!]
    src2  [image!]
    src3  [image!]
    dst   [image!]
    /local
        pix1 [int-ptr!]
        pix2 [int-ptr!]
        pix3 [int-ptr!]
        pixD [int-ptr!]
        handle1 handle2 handle3 handleD 
        h w x y
        r g b a
][
    handle1: 0
    handle2: 0
    handle3: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pix3: image/acquire-buffer src3 :handle3
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
       	 	g: pix2/value and FF00h >> 8 
        	b: pix3/value and FFh 
        	pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
        	pix1: pix1 + 1
        	pix2: pix2 + 1
        	pix3: pix3 + 1
        	pixD: pixD + 1
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer src2 handle2 no
    image/release-buffer src3 handle3 no
    image/release-buffer dst handleD yes
]


rcvMerge2: routine [
"Merge 4 images to destination image"
    src1  [image!]	;--r
    src2  [image!]	;--g
    src3  [image!]	;--b
    src4  [image!]	;--a
    dst   [image!]	;-result
    /local
        pix1 [int-ptr!]
        pix2 [int-ptr!]
        pix3 [int-ptr!]
        pix4 [int-ptr!]
        pixD [int-ptr!]
        handle1 handle2 handle3 handle4 handleD 
        h w x y
        r g b a
][
    handle1: 0
    handle2: 0
    handle3: 0
    handle4: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pix3: image/acquire-buffer src3 :handle3
    pix4: image/acquire-buffer src4 :handle4
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    y: 0
    while [y < h] [
    	x: 0
       	while [x < w][
       		a: pix4/value >>> 24
       		r: pix1/value and FF0000h >> 16 
       	 	g: pix2/value and FF00h >> 8 
        	b: pix3/value and FFh 
        	pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
        	pix1: pix1 + 1
        	pix2: pix2 + 1
        	pix3: pix3 + 1
        	pix4: pix4 + 1
        	pixD: pixD + 1
        	x: x + 1
       ]
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer src2 handle2 no
    image/release-buffer src3 handle3 no
    image/release-buffer src4 handle4 no
    image/release-buffer dst handleD yes
]


_rcvInRange: routine [
	src1  	[image!]
    dst   	[image!]
    lowr 	[integer!]
    lowg 	[integer!]
    lowb 	[integer!]
    upr 	[integer!]
    upg 	[integer!]
    upb 	[integer!]
    op		[integer!]
    /local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 handleD 
    h w x y r g b a
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0
    y: 0
    while [y < h] [
       while [x < w][
       		a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
        	b: pix1/value and FFh 
        	either (((r > lowr) and (r <= upr)) and ((g > lowg) and (g <= upg)) and ((b > lowb) and (b <= upb)))
        	[if op = 0 [r: FFh g: FFh b: FFh]
        	 if op = 1 [r: r g: g b: b]]
        	[r: 0 g: 0 b: 0] 
       		pixD/value: (a << 24) OR (r << 16 ) OR (g << 8) OR b
           	pix1: pix1 + 1
           	pixD: pixD + 1
           	x: x + 1
       ]
       x: 0
       y: y + 1
    ]
    image/release-buffer src1 handle1 no
    image/release-buffer dst handleD yes
]



rcvInRange: function [
"Extracts sub array from image according to lower and upper rgb values"
	src 	[image!] 
	dst 	[image!] 
	lower 	[tuple!] 
	upper 	[tuple!] 
	op 		[integer!]
][
	lr: lower/1 lg: lower/2 lb: lower/3
	ur: upper/1 ug: upper/2 ub: upper/3
	_rcvInRange src dst lr lg lb ur ug ub op

]

; ********** image intensity and blending ******************

rcvSetIntensity: function [
"Sets image intensity"
	src [image!] 
	dst [image!] 
	alpha	[float!]
][
	rcvMathF src dst alpha 3
]	

rcvBlend: routine [
"Mixes 2 images"
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    alpha	[float!]
    /local
        pix1 	[int-ptr!]
        pix2 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        a1 r1 g1 b1
        a2 r2 g2 b2
        a3 r3 g3 b3
        calpha
][
	handle1: 0
	handle2: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pixD: image/acquire-buffer dst  :handleD
	w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    a3: 0
    r3: 0
    g3: 0
    b3: 0
    calpha: 1.0 - alpha
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
				a1: pix1/value >>> 24
       			r1: pix1/value and 00FF0000h >> 16 
        		g1: pix1/value and FF00h >> 8 
        		b1: pix1/value and FFh 
        		a2: pix2/value >>> 24
       			r2: pix2/value and 00FF0000h >> 16 
        		g2: pix2/value and FF00h >> 8 
        		b2: pix2/value and FFh 
        		a3: as integer! (alpha * a1) + (calpha * a2) 
        		r3: as integer! (alpha * r1) + (calpha * r2) 
        		g3: as integer! (alpha * g1) + (calpha * g2)
        		b3: as integer! (alpha * b1) + (calpha * b2)
        		pixD/value: (a3 << 24) OR (r3 << 16 ) OR (g3 << 8) OR b3
				pix1: pix1 + 1
				pix2: pix2 + 1
				pixD: pixD + 1
				x: x + 1
		]
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

rcvAlphaBlend: routine [
"Alpha blending with 2 images"
    src1  	[image!]
    src2  	[image!]
    dst  	[image!]
    /local
        pix1 	[int-ptr!]
        pix2 	[int-ptr!]
        pixD 	[int-ptr!]
        handle1 handle2 handleD 
        h w x y
        a1 r1 g1 b1
        a2 r2 g2 b2
        a3 r3 g3 b3
        calpha
        alphaR
        aInt
        rInt
        gInt
        bInt
][
	handle1: 0
	handle2: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: image/acquire-buffer src2 :handle2
    pixD: image/acquire-buffer dst  :handleD
	w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    a3: 0.0
    r3: 0.0
    g3: 0.0
    b3: 0.0
    y: 0
    while [y < h] [
    	x: 0
		while [x < w][
				a1: as float! (pix1/value >>> 24) / 255.0
       			r1: as float! (pix1/value and FF0000h >> 16) 
        		g1: as float! (pix1/value and FF00h >> 8) 
        		b1: as float! (pix1/value and FFh) 
        		a2: as float! (pix2/value >>> 24)
       			r2: as float! (pix2/value and FF0000h >> 16) 
        		g2: as float! (pix2/value and FF00h >> 8) 
        		b2: as float! (pix2/value and FFh) 
        		a1: a1 / 255 
        		r1: r1 / 255
        		g1: g1 / 255
        		b1: b1 / 255
        		a2: a2 / 255
        		r2: r2 / 255
        		g2: g2 / 255
        		b2: b2 / 255
        		
        		calpha: 1.0 - a1
        		alphaR: a1 + (a2 * calpha)
        		a3: alphaR * 255
        		
        		r1: r1 * a1
        		r2: r2 * calpha
        		r2: r2 * a2
        		r3: (r1 + r2) / alphaR
        		r3: r3 * 255
        		
        		g1: g1 * a1
        		g2: g2 * calpha
        		g2: g2 * a2
        		g3: (g1 + g2) / alphaR
        		g3: g3 * 255
        		
        		b1: b1 * a1
        		b2: b2 * calpha
        		b2: b2 * a2
        		b3: (b1 + b2) / alphaR
        		b3: b3 * 255.0
        	
        		aInt: as integer! a3
        		rInt: as integer! r3
        		gInt: as integer! g3
        		bInt: as integer! b3
        		pixD/value: (aInt << 24) OR (rInt << 16 ) OR (gInt << 8) OR bInt
				pix1: pix1 + 1
				pix2: pix2 + 1
				pixD: pixD + 1
				x: x + 1
		]
		y: y + 1
	]
	image/release-buffer src1 handle1 no
	image/release-buffer src2 handle2 no
	image/release-buffer dst handleD yes
]

;Specific version for Windows until rcvBlend problem solved
rcvBlendWin: function [
"Mixes 2 images"
	src1 	[image!] 
	src2 	[image!] 
	dst 	[image!] 
	alpha	[float!]
][	 
	img1: rcvCreateImage src1/size
	img2: rcvCreateImage src2/size
	rcvMathF src1 img1 alpha 3
	rcvMathF src2 img2 1.0 - alpha 3
	rcvMath img1 img2 dst 1
	rcvReleaseImage img1
	rcvReleaseImage img2
]

rcvResizeImage: routine [
"Resizes image"
	src 	[image!] 
	iSize 	[pair!] 
	return: [image!]
][
	as red-image! stack/set-last as cell! image/resize src iSize/x iSize/y
]







