//
//  BPColorWell.m
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Source14 Platforms. All rights reserved.
//

#import "BPColorWell.h"


@interface BPColorWell (Private)

@end

@implementation BPColorWell

#pragma mark -
#pragma mark Construction and deallocation

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize color;

- (void)setColor:(UIColor *)aColor {
	if (aColor != color) {
		[color release];
		color = [aColor retain];
		[self setNeedsDisplay];
	}
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect {
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(ctx, NO);
	CGContextSetFillColorWithColor(ctx, color.CGColor);
	CGContextFillRect(ctx, rect);

	CGContextSetRGBStrokeColor(ctx, 0.45, 0.45, 0.45, 1.0);
	CGContextSetLineWidth(ctx, 2.0);
	CGContextStrokeRect(ctx, rect);
}

@end
