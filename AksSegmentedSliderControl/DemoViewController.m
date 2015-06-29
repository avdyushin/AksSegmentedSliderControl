//
//  DemoViewController.m
//  AksSegmentedSliderControl
//
//  Created by Alok on 29/06/13.
//  Copyright (c) 2013 Konstant Info Private Limited. All rights reserved.
//

#import "DemoViewController.h"
#import "AKSSegmentedSliderControl.h"

@interface DemoViewController () <AKSSegmentedSliderControlDelegate>
{
    AKSSegmentedSliderControl *sliderControl;
}
@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
	[self prepareSlider];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)prepareSlider
{
    sliderControl = [AKSSegmentedSliderControl new];
    sliderControl.frame = CGRectMake(20, CGRectGetMidY(self.view.bounds) - 22/2, CGRectGetWidth(self.view.bounds) - 40, 22);
    sliderControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    sliderControl.delegate = self;
    sliderControl.radiusPoint = 4;
    sliderControl.heightLine = 2;
    sliderControl.tintColor = [UIColor colorWithRed:(CGFloat)0x27/0xff green:(CGFloat)0xea/0xff blue:(CGFloat)0x60/0xff alpha:1.0f];
    sliderControl.disabledBackgroundColor = [UIColor colorWithRed:(CGFloat)0x2e/0xff green:(CGFloat)0xcc/0xff blue:(CGFloat)0x71/0xff alpha:0.75f];
	[sliderControl moveToIndex:2];
    [self.view addSubview:sliderControl];
}

- (void)timeSlider:(AKSSegmentedSliderControl *)timeSlider didSelectPointAtIndex:(int)index
{
    NSLog(@"Index selected -> %zd", index);
}

@end
