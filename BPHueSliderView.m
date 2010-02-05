//
//  BPHueSliderView.m
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import "BPHueSliderView.h"


@interface BPHueSliderView (Private)

- (UIImage *)huesImage;
- (UIImage *)thumbImage;

@end

@implementation BPHueSliderView

#pragma mark -
#pragma mark Construction and deallocation

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}

- (void)dealloc {
	[huesImage release];
	[thumbImage release];
	[activeTouch release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize selectedHue;

- (void)setSelectedHue:(CGFloat)hue {
	selectedHue = hue;
	[self setNeedsDisplay];
}

#define STATES 6

- (UIImage *)huesImage {
	if (!huesImage) {
		uint8_t pixels[STATES*256*4];
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(pixels, STATES*256, 1, 8, STATES*256*4, colorSpace, kCGImageAlphaPremultipliedLast);
		
		uint8_t red = 255;
		uint8_t green = 0;
		uint8_t blue = 0;
		
		uint8_t *pixel = pixels;
		NSInteger state = 0;
		while (state < STATES) {
			*pixel++ = red;
			*pixel++ = green;
			*pixel++ = blue;
			*pixel++ = 255;

			switch (state) {
				case 0: green++; break;
				case 1: red--;   break;
				case 2: blue++;  break;
				case 3: green--; break;
				case 4: red++;   break;
				case 5: blue--;  break;
			}
			if (red + green + blue == 510 || red + green + blue == 255)
				state++;
		}
		
		CGImageRef image = CGBitmapContextCreateImage(context);
		huesImage = [[UIImage imageWithCGImage:image] retain];
		
		CFRelease(image);
		CFRelease(context);
		CFRelease(colorSpace);
	}
	
	return huesImage;
}

- (UIImage *)thumbImage {
	if (!thumbImage) {
		const NSUInteger w = 11;
		const NSUInteger h = 15;
		
		uint32_t pixels[w*h];
		memset(pixels, 0, sizeof(pixels));
		
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(pixels, w, h, 8, w*4, colorSpace, kCGImageAlphaPremultipliedLast);
		
		for (int r = 0; r < h / 2; r++) {
			for (int c = r; c < w - r; c++) {
				NSUInteger topPixel = r*w+c;
				NSUInteger bottomPixel = (h-r-1)*w+c;
				uint32_t *pixel = &pixels[topPixel];
				uint32_t color = 0x9f000000; //(r == c) || (w - r == c)? 0xffffffff : 0x7f000000;
				
				*pixel = color;
				
				pixel = &pixels[bottomPixel];
				*pixel = color;				
			}
		}
		
		
		CGImageRef image = CGBitmapContextCreateImage(context);
		UIImage *thumbBase = [UIImage imageWithCGImage:image];
		thumbImage = [[thumbBase stretchableImageWithLeftCapWidth:0 topCapHeight:h/2] retain];

		CFRelease(image);
		CFRelease(context);
		CFRelease(colorSpace);
	}
	
	return thumbImage;
}

#pragma mark -
#pragma mark Drawing

- (void)drawThumb {
	const CGFloat imageWidth = [[self thumbImage] size].width;
	const CGFloat x = (self.bounds.size.width * selectedHue) + self.bounds.origin.x - imageWidth / 2.0;
	[[self thumbImage] drawInRect:CGRectMake(x, 0, imageWidth, self.bounds.size.height)];
}

- (void)drawRect:(CGRect)rect {
	[[self huesImage] drawInRect:CGRectInset(rect, -1.0, -1.0)];
	[self drawThumb];

	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShouldAntialias(ctx, NO);
	CGContextSetRGBStrokeColor(ctx, 0.45, 0.45, 0.45, 1.0);
	CGContextSetLineWidth(ctx, 2.0);
	CGContextStrokeRect(ctx, rect);
}

#pragma mark -
#pragma mark Handling touches

#define CLAMP(number, min, max) number < min ? min : (number > max ? max : number)

- (void)updateThumbWithTouch:(UITouch *)touch {
	CGPoint location = [activeTouch locationInView:self];
	CGRect bounds = self.bounds;
	
	float position = location.x - bounds.origin.x;
	
	self.selectedHue = CLAMP(position / bounds.size.width, 0.0, 1.0);
	
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
