//
//  BPColorPickerViewController.m
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import "BPColorPickerViewController.h"
#import "BPColorWell.h"
#import "BPHueSliderView.h"
#import "BPLuminanceSaturationView.h"

@interface BPColorPickerViewController (Private)

- (void)updatePickedColor;

@end

@implementation BPColorPickerViewController

#pragma mark -
#pragma mark Construction and deallocation

- (id)init {
	if (self = [super initWithNibName:@"BPColorPickerViewController" bundle:nil]) {
		self.title = @"Color Picker";
	}

	return self;
}

- (void)dealloc {
	[colorWell release];
	[hueSliderView release];
	[luminanceSaturationView release];
	[pickedColor release];
    [super dealloc];
}

#pragma mark -
#pragma mark Accessors

@synthesize colorWell, hueSliderView, luminanceSaturationView;
@synthesize delegate;
@synthesize pickedColor;

- (void)setPickedColor:(UIColor *)aColor {
	if (aColor != pickedColor) {
		[pickedColor release];
		pickedColor = [aColor retain];
		[self updatePickedColor];
	}
}

#pragma mark -
#pragma mark View loading and unloading

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];
	[self updatePickedColor];
}

- (void)viewDidUnload {
	self.colorWell = nil;
	self.hueSliderView = nil;
	self.luminanceSaturationView = nil;
}

#pragma mark -
#pragma mark Setting a new color externally

- (void)updatePickedColor {
	if (!hueSliderView || !colorWell || !luminanceSaturationView)
		return;
	if (!pickedColor) {
		self.pickedColor = [UIColor colorWithHue:0.0 saturation:1.0 brightness:1.0 alpha:1.0];
		return;
	}
	
	const CGFloat *c = CGColorGetComponents(pickedColor.CGColor);
	
	// Colors come in RGB. We want them in HSV. Do some converstion work per Wikipedia :)
	NSUInteger min, max;
	if (c[0] >= c[1] && c[0] >= c[2])
		max = 0;
	else if (c[1] >= c[0] && c[1] >= c[2])
		max = 1;
	else
		max = 2;
		
	if (c[0] <= c[1] && c[0] <= c[2])
		min = 0;
	else if (c[1] <= c[0] && c[1] <= c[2])
		min = 1;
	else
		min = 2;
	
	CGFloat h;
	CGFloat scale = c[max] - c[min];
	if (min == max)
		h = 0.0;
	else if (max == 0) {
		h = 60.0 * ((c[1] - c[2]) / scale) + 360.0;
		if (h > 360.0)
			h -= 360.0;
	}
	else if (max == 1)
		h = 60.0 * ((c[2] - c[0]) / scale) + 120.0;
	else
		h = 60.0 * ((c[0] - c[1]) / scale) + 240.0;
	
	h /= 360.0;
	
	CGFloat s = c[max] == 0.0 ? 0.0 : 1.0 - (c[min] / c[max]);
	CGFloat v = c[max];
	
	colorWell.color = pickedColor;
	hueSliderView.selectedHue = h;
	luminanceSaturationView.saturation = s;
	luminanceSaturationView.luminance = v;
}

#pragma mark -
#pragma mark Sending color updates

- (void)updatedColor {
	[pickedColor release];
	pickedColor = [[UIColor colorWithHue:self.hueSliderView.selectedHue saturation:self.luminanceSaturationView.saturation brightness:self.luminanceSaturationView.luminance alpha:1.0] retain];
	self.colorWell.color = pickedColor;
	[delegate colorPicker:self didSelectColor:pickedColor];
}

#pragma mark -
#pragma mark UI actions

- (IBAction)updateHue:(id)sender {
	BPHueSliderView *slider = sender;
	luminanceSaturationView.baseHue = slider.selectedHue;
	[self updatedColor];
}

- (IBAction)updateLuminanceAndSaturation:(id)sender {
	[self updatedColor];
}

@end
