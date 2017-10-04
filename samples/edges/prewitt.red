Red [	Title:   "Prewitt Filter "	Author:  "Francois Jouen"	File: 	 %prewitt.red	Needs:	 'View]; last Red Master required!#include %../../libs/redcv.red ; for redCV functionsmargins: 10x10defSize: 512x512img1: rcvCreateImage defSizedst:  rcvCreateImage defSizeisFile: falseloadImage: does [    isFile: false	canvas/image/rgb: black	canvas/size: 0x0	tmp: request-file	if not none? tmp [		fileName: to string! to-local-file tmp		win/text: fileName		either cb/data [img1: rcvLoadImage/grayscale tmp]					   [img1: rcvLoadImage tmp]		dst:  rcvCloneImage img1		; update faces		if img1/size/x >= defSize/x [			win/size/x: img1/size/x + 20			win/size/y: img1/size/y + 256; 90		] 		either (img1/size/x = img1/size/y) [bb/size: 120x120] [bb/size: 160x120]		canvas/size: img1/size		canvas/offset/x: (win/size/x - img1/size/x) / 2		bb/image: img1		canvas/image: dst		isFile: true		rcvPrewitt img1 dst img1/size 3		r1/data: false		r2/data: false		r3/data: true		r4/data: false	]]; ***************** Test Program ****************************view win: layout [		title "Edges detection: Prewitt"		origin margins space margins		cb: check "Grayscale"		button 60 "Load" 		[loadImage]							button 60 "Quit" 		[rcvReleaseImage img1 								rcvReleaseImage dst Quit]		return		bb: base 128x128 img1		return		text middle 100x20 "Prewitt Direction"		r1: radio "Horizontal" 	[rcvPrewitt img1 dst img1/size 1]		r2: radio "Vertical" 	[rcvPrewitt img1 dst img1/size 2]			r3:	radio "Both" 		[rcvPrewitt img1 dst img1/size 3]		r4:	radio "Magnitude"	[rcvPrewitt img1 dst img1/size 4]		return		canvas: base 512x512 dst			do [r3/data: true]]