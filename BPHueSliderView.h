//
//  BPHueSliderView.h
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BPHueSliderView : UIControl {
	UIImage *huesImage;
	UIImage *thumbImage;
	
	CGFloat selectedHue;
	
	UITouch *activeTouch;
}

@property (nonatomic, assign) CGFloat selectedHue;

@end
