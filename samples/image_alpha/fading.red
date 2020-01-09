Red [
	Title:   "Simple Fading Sample"
	Author:  "Francois Jouen"
	File: 	 %fading.red
	Needs:	 'View
]
; required libs
#include %../../libs/core/rcvCore.red

margins: 10x10
defSize: 512x512
img1: rcvCreateImage defSize
dst:  rcvCreateImage defSize
isFile: false
delta: 0.0

loadImage: does [
    isFile: false
    sl/data: 0%
	delta: 0.0
	tmp: request-file
	if not none? tmp [
		img1: rcvLoadImage tmp
		dst:  rcvCloneImage img1
		canvas/image: dst
		isFile: true
	]
]

; ***************** Test Program ****************************
view win: layout [
		title "Simple Contrast Test"
		origin margins space margins
		button 60 "Load" 		[loadImage]						
		sl: slider 240 [if isFile [
							delta: 1.0 - to float! sl/data * 1
							vf/data: form delta 
							rcvPow img1 dst delta	
						]				 
		]	
		vf: field 50 "1.0"								
		button 50 "Quit" 		[rcvReleaseImage img1 rcvReleaseImage dst Quit]
		return 
		canvas: base 512x512 dst
		do [sl/data: 0%]	
]