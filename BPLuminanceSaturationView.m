//
//  BPLuminanceSaturationView.m
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import "BPLuminanceSaturationView.h"


@interface BPLuminanceSaturationView (Private)

@end

@implementation BPLuminanceSaturationView

#pragma mark -
#pragma mark Construction and deallocation

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)dealloc {
	[activeTouch release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize baseHue;
@synthesize luminance, saturation;

- (void)setBaseHue:(CGFloat)hue {
	baseHue = hue;
	[self setNeedsDisplay];
}

- (void)setLuminance:(CGFloat)aLuminance {
	luminance = aLuminance;
	[self setNeedsDisplay];
}

- (void)setSaturation:(CGFloat)aSaturation {
	saturation = aSaturation;
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark Drawing

#define SIZE 256

#define THUMB_SIZE 5

- (void)drawRect:(CGRect)rect {
	uint8_t pixels[SIZE*SIZE*4];
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef bitmapCtx = CGBitmapContextCreate(pixels, 256, 256, 8, SIZE*4, colorSpace, kCGImageAlphaPremultipliedLast);
	
	NSInteger quadrant = ((NSInteger)floor(baseHue * 6)) % 6;
	CGFloat f = (baseHue * 6) - floor(baseHue * 6);
	
	uint8_t *pixel = pixels;
	for (NSUInteger row = 0; row < SIZE; row++) {
		CGFloat v = (CGFloat)row / (CGFloat)SIZE;
		for (NSUInteger col = 0; col < SIZE; col++) {
			CGFloat s = (CGFloat)col / 255.0f;
			
			CGFloat p = v * (1 - s);
			CGFloat q = v * (1 - f * s);
			CGFloat t = v * (1 - (1 - f) * s);
			
			CGFloat red, green, blue;
			
			switch (quadrant) {
				case 0: red = v; green = t; blue = p; break;
				case 1: red = q; green = v; blue = p; break;
				case 2: red = p; green = v; blue = t; break;
				case 3: red = p; green = q; blue = v; break;
				case 4: red = t; green = p; blue = v; break;
				case 5: red = v; green = p; blue = q; break;
			}
			
			*pixel++ = 255 * red;
			*pixel++ = 255 * green;
			*pixel++ = 255 * blue;
			*pixel++ = 255;
		}
		
	}
	CGImageRef image = CGBitmapContextCreateImage(bitmapCtx);
	
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextDrawImage(ctx, CGRectInset(rect, -1.0, -1.0), image);
	
	const CGFloat x = saturation * self.bounds.size.width + self.bounds.origin.x - (THUMB_SIZE / 2.0);
	const CGFloat y = (1.0 - luminance) * self.bounds.size.height + self.bounds.origin.y - (THUMB_SIZE / 2.0);
	CGContextAddEllipseInRect(ctx, CGRectMake(x, y, THUMB_SIZE, THUMB_SIZE));
	CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 0.75);
	CGContextSetLineWidth(ctx, 2.0);
	CGContextStrokePath(ctx);
	CGContextAddEllipseInRect(ctx, CGRectInset(CGRectMake(x, y, THUMB_SIZE, THUMB_SIZE), 1.0, 1.0));
	CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.75);
	CGContextSetLineWidth(ctx, 1.0);
	CGContextStrokePath(ctx);
	
	
	CGContextSetShouldAntialias(ctx, NO);
	CGContextSetRGBStrokeColor(ctx, 0.45, 0.45, 0.45, 1.0);
	CGContextSetLineWidth(ctx, 2.0);
	CGContextStrokeRect(ctx, rect);
	
	CFRelease(image);
	CFRelease(bitmapCtx);
	CFRelease(colorSpace);
}

#pragma mark -
#pragma mark Responding to touch events

#define CLAMP(number, min, max) number < min ? min : (number > max ? max : number)

- (void)updateThumbWithTouch:(UITouch *)touch {
	CGPoint point = [touch locationInView:self];
	CGPoint location = {
		.x = point.x - self.bounds.origin.x,
		.y = point.y - self.bounds.origin.y
	};
	
	luminance = (self.bounds.size.height - location.y) / self.bounds.size.height;
	saturation = location.x / self.bounds.size.width;
	
	luminance = CLAMP(luminance, 0.0, 1.0);
	saturation = CLAMP(saturation, 0.0, 1.0);
	
	[self setNeedsDisplay];
	[self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!activeTouch) {
		activeTouch = [[touches anyObject] retain];
		[self updateThumbWithTouch:activeTouch];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (activeTouch && [touches containsObject:activeTouch])
		[self updateThumbWithTouch:activeTouch];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (activeTouch && [touches containsObject:activeTouch]) {
		[activeTouch release];
		activeTouch = nil;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (activeTouch && [touches containsObject:activeTouch]) {
		[activeTouch release];
		activeTouch = nil;
	}	
}

@end
