Red [	Title:   "Rotate image"	Author:  "Francois Jouen"	File: 	 %resize.red	Needs:	 'View]; last Red Master required!#include %../../libs/redcv.red ; for redCV functionsmargins: 10x10img1: rcvLoadImage %../../images/lena.jpgx: 0y: 0drawBlk: rcvSkewImage 0.5 0x0 x yappend drawBlk [img1] ; append to Draw block! the image instance; ***************** Test Program ****************************view win: layout [		title "Skew Image"		origin margins space margins				sl1: slider 310		[sz/text: form to integer! face/data * 180 							 if cbx/data [x:  face/data * 180.0 ] [x: 0] drawBlk/7: x							 if cby/data [y:  face/data * 180.0] [y: 0] drawBlk/8: y							 ]		sz: field 30 "0"		text "Degrees"		button 60 "Quit"	[Quit]		return 		text "Skew X" cbx: check		text "Skew Y" cby: check		return 		canvas: base iSize black draw drawBlk			do [ sl1/data: 0.0 cbx/data: true]]