//
//  NSColor+HexRGB.m
//  TextDo
//
//  Created by Vojto Rinik on 28.6.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "NSColor+HexRGB.h"


@implementation NSColor (NSColor_HexRGB)

+ (NSColor *) colorFromHexRGB:(NSString *) inColorString {
	NSColor *result = nil;
	unsigned int colorCode = 0;
	uint8_t redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (uint8_t) (colorCode >> 16);
	greenByte	= (uint8_t) (colorCode >> 8);
	blueByte	= (uint8_t) (colorCode);	// masks off high bits
	result = [NSColor colorWithCalibratedRed:(CGFloat)redByte   / 0xff
									   green:(CGFloat)greenByte / 0xff
										blue:(CGFloat)blueByte  / 0xff
									   alpha:1.0];
	return result;
}

@end
