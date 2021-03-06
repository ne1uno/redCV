Red [
	Title:   "Red Computer Vision: Statistics"
	Author:  "Francois Jouen"
	File: 	 %rcvSats.red
	Tabs:	 4
	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."
	License: {
		Distributed under the Boost Software License, Version 1.0.
		See https://github.com/red/red/blob/master/BSL-License.txt
	}
]

;***************** STATISTICAL ROUTINES ON IMAGE ***********************
rcvCount: routine [
"Returns the number of non zero values in image"
	src1 		[image!] 
	return: 	[integer!]
	/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		a		[integer!]
		n		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    y: 0
    n: 0
    while [y < h][
    	x: 0
        while [x < w][
            a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
       		if any [r > 0 g > 0 b > 0] [n: n + 1]
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    n
]


rcvStdImg: routine [
"Returns standard deviation value of image as an integer"
	src1 	[image!] 
	return: [integer!]
	/local 
		pix1	[int-ptr!]
		pix2	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		a		[integer!]
		mr		[integer!] 
		mg		[integer!]
		mb		[integer!]
		ma		[integer!]
		sr 		[integer!]
		sg		[integer!]
		sb		[integer!]
		sa		[integer!]
		fr 		[float!]
		fg		[float!]
		fb		[float!]
		fa		[float!]
		e		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    pix2: pix1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    x: 0 y: 0
    sa: 0 sr: 0 sg: 0 sb: 0
    fa: 0.0 fr: 0.0 fg: 0.0 fb: 0.0
    ; Sigma X
    while [y < h][
    	x: 0
        while [x < w][
            a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            sa: sa + a
            sr: sr + r  
            sg: sg + g
            sb: sb + b
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    ; mean values
    ma: sa / (w * h)
    mr: sr / (w * h)
    mg: sg / (w * h)
    mb: sb / (w * h)
    x: 0 y: 0 e: 0
    ;pix1: image/acquire-buffer src1 :handle1 ; pbs with windows
    ; x - m 
    while [y < h][
    	x: 0
        while [x < w][
           	a: pix2/value >>> 24
       		r: pix2/value and 00FF0000h >> 16 
        	g: pix2/value and FF00h >> 8 
       		b: pix2/value and FFh 
            e: a - ma sa: sa + (e * e)
            e: r - mr sr: sr + (e * e)
            e: g - mg sg: sg + (e * e)
            e: b - mb sb: sb + (e * e)
            pix2: pix2 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    ; standard deviation
    fa: 0.0; 255 xor sa / ((w * h) - 1)
    fr: sqrt as float! (sr / ((w * h) - 1))
    fg: sqrt as float! (sg / ((w * h) - 1))
    fb: sqrt as float! (sb / ((w * h) - 1))
    a: as integer! fa
    r: as integer! fr
    g: as integer! fg
    b: as integer! fb
    image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

rcvMeanImg: routine [
"Returns mean value of image as an integer"
	src1 	[image!] 
	return: [integer!]
	/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		a		[integer!]
		sr 		[integer!]
		sg		[integer!]
		sb		[integer!]
		sa		[integer!]
][
    handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
  	y: 0
    sa: 0 sr: 0 sg: 0 sb: 0
    while [y < h][
    	x: 0
        while [x < w][
            a: pix1/value >>> 24
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            sa: sa + a
            sr: sr + r 
            sg: sg + g
            sb: sb + b
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    a: sa / (w * h)
    r: sr / (w * h)
    g: sg / (w * h)
    b: sb / (w * h)
    image/release-buffer src1 handle1 no
    (a << 24) OR (r << 16 ) OR (g << 8) OR b 
]

rcvMinLocImg: routine [
"Finds global minimum location in image"
	src1 	[image!] 
	return: [pair!]
/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		v		[integer!]
		mini  	[integer!]
		locmin 	[red-pair!]
] [
	handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    mini: (255 << 16) or (255 << 8) or 255
    locmin: pair/make-at stack/push* 0 0
    y: 0
    while [y < h][
    	x: 0
        while [x < w][
       		r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            v: (r << 16 ) OR (g << 8) OR b 
            if v < mini [mini: v locmin/x: x locmin/y: y]
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    as red-pair! stack/set-last as cell! locmin 
]


rcvMaxLocImg: routine [
"Finds global maximun location in image"
	src1 	[image!] 
	return: [pair!]
/local 
		pix1	[int-ptr!]
		handle1	[integer!]
		w 		[integer!]
		h 		[integer!]
		x 		[integer!]
		y 		[integer!]
		r 		[integer!]
		g		[integer!]
		b		[integer!]
		v		[integer!]
		maxi 	[integer!] 
		locmax	[red-pair!] 
] [
	handle1: 0
    pix1: image/acquire-buffer src1 :handle1
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    maxi: 0
    locmax: pair/make-at stack/push* 0 0
    y: 0
    while [y < h][
    	x: 0
        while [x < w][
            r: pix1/value and 00FF0000h >> 16 
        	g: pix1/value and FF00h >> 8 
       		b: pix1/value and FFh 
            v: (r << 16 ) OR (g << 8) OR b 
            if v > maxi [maxi: v locmax/x: x locmax/y: y]
            pix1: pix1 + 1
            x: x + 1
        ]
        y: y + 1
    ]
    image/release-buffer src1 handle1 no
    as red-pair! stack/set-last as cell! locmax 
]

; sorting images
_sortPixels: routine [
	arr 	[vector!]
	/local
	ptr		[int-ptr!]
	tmp		[integer!]
	n		[integer!]
	i 		[integer!]
	j		[integer!]
	j2		[integer!]
	
][
	n: vector/rs-length? arr
	ptr: as int-ptr! vector/rs-head arr
	i: 1
	while [i <= n] [
		j: 1
		while [j < i] [
			if ptr/i < ptr/j [
				j2: j + 1
				tmp: ptr/i
				ptr/i: ptr/j2
				ptr/j2: ptr/j
				ptr/j: tmp
			]
			j: j + 1
		]
		i: i + 1
	]
]

_sortReversePixels: routine [
	arr 	[vector!]
	/local
	ptr		[int-ptr!]	
	n		[integer!]
	i 		[integer!]
	j		[integer!]
	j2		[integer!]
	tmp		[integer!]
][
	n: vector/rs-length? arr
	ptr: as int-ptr! vector/rs-head arr
	i: 0
	while [i <= n] [
		j: 1
		while [j < i] [
			if ptr/i > ptr/j [
				j2: j + 1
				tmp: ptr/i
				ptr/i: ptr/j2
				ptr/j2: ptr/j
				ptr/j: tmp
			]
			j: j + 1
		]
		i: i + 1
	]
]


rcvSortImagebyX: routine [
"Sorts image columns"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [integer!]
    handleD [integer!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    y: 0
    while [y < h] [
    	x: 0 
    	vector/rs-clear b
    	while [x < w] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		x: x + 1
    	]
    	either flag [_sortReversePixels b] 
    				[_sortPixels b]
    	ptr: as int-ptr! vBase
    	x: 0
		while [x < w] [
			idx: pixD + (y * w) + x
			n: x + 1			; ptr/0 returns vector size
			idx/value: ptr/n
			x: x + 1
		]
    	y: y + 1
    ]
    image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]


rcvSortImagebyY: routine [
"Sorts image lines"
	src1 	[image!]
	dst		[image!]
	b		[vector!]
	flag	[logic!]
	/local
	pix1 	[int-ptr!]
    pixD 	[int-ptr!]
    handle1 [integer!]
    handleD [integer!]
    h 		[integer!]
    w 		[integer!]
    x		[integer!]	 
    y		[integer!]
    n		[integer!]
    idx 	[int-ptr!]
    vBase 	[byte-ptr!]
    ptr 	[int-ptr!]
][
	handle1: 0
    handleD: 0
    pix1: image/acquire-buffer src1 :handle1
    pixD: image/acquire-buffer dst :handleD
    w: IMAGE_WIDTH(src1/size)
    h: IMAGE_HEIGHT(src1/size)
    vBase: vector/rs-head b
    x: 0
    while [x < w] [
    	y: 0 
    	vector/rs-clear b
    	while [y < h] [
    		idx: pix1 + (y * w) + x
    		vector/rs-append-int b idx/value
    		y: y + 1
    	]
    	either flag [_sortReversePixels b] 
    				[_sortPixels b]
    	ptr: as int-ptr! vBase
    	y: 0
		while [y < h] [
			idx: pixD + (y * w) + x
			n: y + 1		; ptr/0 returns vector size
			idx/value: ptr/n 
			y: y + 1
		]
    	x: x + 1
    ]
    image/release-buffer src1 handle1 no
	image/release-buffer dst handleD yes
]



;***************** STATISTICAL ROUTINES ON MATRIX ***********************

rcvCountMat: routine [
"Returns number of non zero values in matrix"
	mat 	[vector!] 
	return: [integer!]
	/local
	svalue 	[byte-ptr!]
	tail	[byte-ptr!]
	s		[series!]
	f		[float!]
	int 	[integer!] 
	unit	[integer!]  
	n		[integer!] 
	
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	n: 0
	;integer matrix
	if unit <= 4 [
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			if (int > 0) [n: n + 1] 
			svalue: svalue + unit 
		]
	]
	;float matrix
	if unit > 4 [
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			if (int > 0) [n: n + 1] 
			svalue: svalue + unit 
		]
	]
	n
]

rcvSumMat: routine [
"Returns sum value of matrix as a float"
	mat 	[vector!] 
	return: [float!]
	/local
	svalue 	[byte-ptr!]
	tail	[byte-ptr!]
	s		[series!]
	f		[float!]
	sum 	[float!] 
	int		[integer!]   
	unit	[integer!]
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	sum: 0.0
	;integer matrix
	if unit <= 4 [
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			sum: sum + as float! int
			svalue: svalue + unit 
		]
	]
	;float matrix
	if unit > 4 [
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			sum: sum + f
			svalue: svalue + unit 
		]
	]
	sum
]

rcvMeanMat: routine [
"Returns mean value of matrix as a float"
	mat 	[vector!] 
	return: [float!]
	/local
	int svalue  tail unit
	s sum f
	n
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    n: vector/rs-length? mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	sum: 0.0
	;integer matrix
	if unit <= 4 [
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			sum: sum + as float! int
			svalue: svalue + unit 
		]
	]
	;float matrix
	if unit > 4 [
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			sum: sum + f
			svalue: svalue + unit 
		]
	]
	sum / n
]

rcvStdMat: routine [
"Returns standard deviation value of matrix as a float"
	mat 	[vector!] 
	return: [float!]
	/local
	svalue 	[byte-ptr!] 
	tail 	[byte-ptr!]
	s		[series!]
	n		[integer!]
	int		[integer!]
	unit	[integer!]
	sum 	[integer!]
	sum2	[integer!]
	e 		[integer!]
	m		[integer!]
	mf		[float!]
	f 		[float!]
	ef		[float!]
	sumf 	[float!]
	sumf2	[float!]
	
] [
    svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    n: vector/rs-length? mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	sum: 0 
	sum2: 0
	; integer matrix
	if unit <= 4 [
		; mean
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			sum: sum + int
			svalue: svalue + unit 
		]
		m: sum / n
		svalue: vector/rs-head mat 
		while [svalue < tail][
			int: vector/get-value-int as int-ptr! svalue unit
			e: int - m
			sum2: sum + (e * e)
			svalue: svalue + unit 
		]
		f: sqrt as float! (sum2 / (n - 1))	
	]
	;float matrix
	sumf: 0.0 
	sumf2: 0.0
	if unit > 4 [
		; mean
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			sumf: sumf + f
			svalue: svalue + unit 
		]
		mf: sumf / n
		svalue: vector/rs-head mat 
		while [svalue < tail][
			f: vector/get-value-float svalue unit
			ef: f - mf
			sumf2: sumf + (ef * ef)
			svalue: svalue + unit 
		]
		f: sqrt  (sumf2 / (n - 1))
	]
	f
]


rcvMaxLocMat: routine [
"Finds global maximum location in matrix"
	mat 		[vector!] 
	matSize 	[pair!] 
	return: 	[pair!]
	/local 
	svalue 		[byte-ptr!] 
	tail		[byte-ptr!]
	s			[series!]
	int 		[integer!]
	unit		[integer!]
	x 			[integer!]
	y			[integer!]
	maxi 		[integer!]
	locmax		[red-pair!]
		
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    tail: vector/rs-tail mat
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
    maxi: 0
    locmax: pair/make-at stack/push* 0 0
    y: 0
    while [y < matSize/y] [	
    	x: 0
       	while [x < matSize/x][
       		either unit <= 4 [int: vector/get-value-int as int-ptr! svalue unit]
       			[int: as integer! vector/get-value-float svalue unit]
    		if int > maxi [maxi: int locmax/x: x locmax/y: y]
       		svalue: svalue + 1 
        	x: x + 1
       ]
       y: y + 1
    ]
    as red-pair! stack/set-last as cell! locmax 
]


rcvMinLocMat: routine [
"Finds global minimum location in matrix"
	mat 	[vector!] 
	matSize [pair!] 
	return: [pair!]
	/local 
	int svalue s unit
	w h x y
	mini locmin
		
] [
	svalue: vector/rs-head mat ; get pointer address of the matrice
    s: GET_BUFFER(mat)
	unit: GET_UNIT(s)
	w: matSize/x
    h: matSize/y
    mini: 32767
    locmin: pair/make-at stack/push* 0 0
    y: 0
    while [y < h] [	
    	x: 0
       	while [x < w][
    		either unit <= 4 [int: vector/get-value-int as int-ptr! svalue unit]
       						 [int: as integer! vector/get-value-float svalue unit]
    		if int < mini [mini: int locmin/x: x locmin/y: y]
       		svalue: svalue + 1 
        	x: x + 1
       ]
       y: y + 1
    ]
    as red-pair! stack/set-last as cell! locmin
]


;************** STATISTICAL FUNCTIONS (images or matrices) *********************

rcvCountNonZero: function [
"Returns number of non zero values in image or matrix"
	arr [image! vector!]
][
	t: type? arr
	if t = image! 	[n: rcvCount arr]
	if t = vector!  [n: rcvCountMat arr]
	n
]

rcvSum: function [
"Returns sum value of image or matrix as a block"
	arr [image! vector!] 
	/argb
][
	t: type? arr
	if t = image! 	[	v: rcvMeanImg arr
						a: v >>> 24
    					r: v and 00FF0000h >> 16 
    					g: v and FF00h >> 8 
    					b: v and FFh
    					sz: arr/size/x * arr/size/y
    					sa: a * sz
    					sr: r * sz
    					sg: g * sz
    					sb: b * sz
    					either argb [blk: reduce [sa sr sg sb]] [blk: reduce [sr sg sb]]
					]
	if t = vector!  [sum: rcvSumMat arr blk: reduce [sum]]
	blk
]

rcvMean: function [
"Returns mean value of image or matrix as a tuple"
	arr [image! vector!] 
	/argb
][
	t: type? arr
	if t = vector!  [m: rcvMeanMat arr tp: make tuple! reduce [m]]
	if t = image! 	[v: rcvMeanImg arr
					a: v >>> 24
    				r: v and 00FF0000h >> 16 
    				g: v and FF00h >> 8 
    				b: v and FFh
   					either argb [tp: make tuple! reduce [a r g b]] [tp: make tuple! reduce [r g b]]
	]
	tp
]

rcvSTD: function [
"Returns standard deviation value of image or matrix as a tuple"
	arr [image! vector!] 
	/argb
][
t: type? arr
	if t = vector!  [m: rcvStdMat arr tp: make tuple! reduce [m]]
	if t = image! 	[v: rcvStdImg arr
    				a: v >>> 24
    				r: v and 00FF0000h >> 16 
    				g: v and FF00h >> 8 
    				b: v and FFh
   					either argb [tp: make tuple! reduce [a r g b]] 
   					            [tp: make tuple! reduce [r g b]]
	]
	tp
]	


rcvMedian: function [
"Returns median value of image or matrix as a tuple"
	arr [image! vector!] 
][
t: type? arr
	if t = vector!  [mat: copy arr
					 sort mat
					 n: to integer! length? mat
					 pos: to integer! ((n + 1) / 2)
					 either odd? n  [pxl: make tuple! reduce [mat/(pos)]] 
					 				[m1: mat/(pos) m2: mat/(pos + 1) pxl: make tuple! reduce [(m1 + m2) / 2]]
	]
	if t = image! 	[img: make image! arr/size
					 img/rgb: copy sort arr/rgb 
					 n: length? img
					 pos: to integer! ((n + 1) / 2)
					 either odd? n [pxl: img/(pos)] [m1: img/(pos) m2: img/(pos + 1) pxl: (m1 + m2) / 2]
	]
	pxl
]	

rcvMinValue: function [
"Minimal value in image or matrix as a tuple"
	arr [image! vector!]
][
t: type? arr
	if t = vector!  [mat: copy arr
					 sort mat
					 pxl: make tuple! reduce [mat/1]
	]
	if t = image! 	[img: make image! arr/size
					 img/rgb: copy sort arr/rgb 
					 pxl: img/1
	]
	pxl
]	


rcvMaxValue: function [
"Maximal value in image or matrix as a tuple"
	arr [image! vector!] 
][
	t: type? arr
	if t = vector!  [mat: copy arr
					 sort mat
					 pxl: make tuple! reduce [last mat]
	]
	if t = image! 	[img: make image! arr/size
					 img/rgb: copy sort arr/rgb 
					 pxl: last img
	]
	pxl
]	


rcvMinLoc: function [
"Finds global minimum location in array"
	arr 	[image! vector!] 
	arrSize [pair!]
][
	t: type? arr
	if t = vector! 	[ret: rcvMinLocMat arr arrSize]
	if t = image! 	[ret: rcvMinLocImg arr]
	ret
]


rcvMaxLoc: function [
"Finds global maximum location in array"
	arr 	[image! vector!] 
	arrSize [pair!]
][
	t: type? arr
	if t = vector! 	[ret: rcvMaxLocMat arr arrSize]
	if t = image! 	[ret: rcvMaxLocImg arr]
	ret
]


rcvRangeImage: function [
"Range value in Image as a tuple"
	source [image!] 
][
	img: copy source
	n: to integer! (length? img/rgb) / 3 ; RGB channels only
	img/rgb: copy sort source/rgb 
	;return: [tuple!]
	pxl1: img/1
	pxl2: img/(n)
	pxl2 - pxl1
]


rcvSortImage: function [
"Ascending image sorting"
	source 	[image!] 
	dst 	[image!]
][
	dst/rgb: copy sort source/rgb 
]

rcvXSortImage: function [
"Image sorting by line"
	src 	[image!] 
	dst		[image!] 
	flag 	[logic!] ; reverse order
][
	b: make vector! src/size/x
	rcvSortImagebyX src dst b flag
]

rcvYSortImage: function [
"Image sorting by column"
	src 	[image!] 
	dst		[image!] 
	flag 	[logic!] ; reverse order
][
	b: make vector! src/size/y
	rcvSortImagebyY src dst b flag
]


