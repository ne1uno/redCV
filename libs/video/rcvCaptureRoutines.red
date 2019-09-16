Red [	Title:   "Red Computer Vision: Video functions"	Author:  "Francois Jouen"	File: 	 %rcvCapture.red	Tabs:	 4	Rights:  "Copyright (C) 2016 Francois Jouen. All rights reserved."	License: {		Distributed under the Boost Software License, Version 1.0.		See https://github.com/red/red/blob/master/BSL-License.txt	}]#system [	#include %platforms.reds	; for dll access]createCam: routine [device [integer!] return: [integer!]] [	openCamera device]setCamSize: routine [w [float!] h [float!]][	setCameraProperty  CV_CAP_PROP_FRAME_WIDTH w	setCameraProperty  CV_CAP_PROP_FRAME_HEIGHT h]setCamWidth: routine [value [float!] return: [integer!]] [	setCameraProperty  CV_CAP_PROP_FRAME_WIDTH value]setCamHeight: routine [value [float!] return: [integer!]] [	setCameraProperty CV_CAP_PROP_FRAME_HEIGHT value]getCamWidth: routine [return: [float!]][	getCameraProperty  CV_CAP_PROP_FRAME_WIDTH]getCamHeight: routine [return: [float!]][	getCameraProperty  CV_CAP_PROP_FRAME_HEIGHT]getCameraFPS: routine  [return: [float!]][	getCameraProperty CV_CAP_PROP_FPS]getCamImage: routine [return: [integer!]][	readCamera]getMovieFile: routine [ fileName [string!] return: [integer!]] [	openFile as c-string! string/rs-head fileName]; memory leaks_getCamImage: routine [rimg [image!]	/local 	addr	imgData imgSize imgEnd	nch w h wstep istep	pix r g b	handle] [	addr: as int-ptr! readCamera	; RGB IplImage address 	nch: addr/3	w: addr/11						; image width	h: addr/12						; image height	wstep: addr/19					; width step	istep: nch * w 	imgSize: addr/17	imgData: as byte-ptr! addr/18	; get cam image data address	imgEnd: (imgData + imgSize)	; red image 	handle: 0	pix:  image/acquire-buffer rimg :handle	while [imgData < imgEnd][			r: as integer! imgData/1			g: as integer! imgData/2			b: as integer! imgData/3			pix/value: (255 << 24) OR (b << 16 ) OR (g << 8) OR r			pix: pix + 1			imgData: imgData + 3	] 		image/release-buffer rimg handle yes]