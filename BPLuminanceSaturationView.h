//
//  BPLuminanceSaturationView.h
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BPLuminanceSaturationView : UIControl {
	CGFloat baseHue;
	
	CGFloat luminance;
	CGFloat saturation;
	
	UITouch *activeTouch;
}

@property (nonatomic, assign) CGFloat baseHue;

@property (nonatomic, assign) CGFloat luminance;
@property (nonatomic, assign) CGFloat saturation;

@end
