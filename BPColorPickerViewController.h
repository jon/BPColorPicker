//
//  BPColorPickerViewController.h
//  Skates
//
//  Created by Jon Olson on 2/4/10.
//  Copyright 2010 Ballistic Pigeon, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BPColorWell;
@class BPHueSliderView;
@class BPLuminanceSaturationView;

@protocol BPColorPickerViewControllerDelegate;

@interface BPColorPickerViewController : UIViewController {
	BPColorWell *colorWell;
	BPHueSliderView *hueSliderView;
	BPLuminanceSaturationView *luminanceSaturationView;
	
	id <BPColorPickerViewControllerDelegate> delegate;
	
	UIColor *pickedColor;
}

@property (nonatomic, retain) IBOutlet BPColorWell *colorWell;
@property (nonatomic, retain) IBOutlet BPHueSliderView *hueSliderView;
@property (nonatomic, retain) IBOutlet BPLuminanceSaturationView *luminanceSaturationView;

@property (nonatomic, assign) id <BPColorPickerViewControllerDelegate> delegate;

@property (nonatomic, retain) UIColor *pickedColor;

- (IBAction)updateHue:(id)sender;
- (IBAction)updateLuminanceAndSaturation:(id)sender;

@end

@protocol BPColorPickerViewControllerDelegate

- (void)colorPicker:(BPColorPickerViewController *)colorPicker didSelectColor:(UIColor *)color;

@end

