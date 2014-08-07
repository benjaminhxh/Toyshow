//
//  CBViewController.h
//  Joyshow
//
//  Created by zhxf on 14-8-7.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBViewController : UIViewController
//@property (retain, nonatomic) IBOutlet UIButton *playButtontext;
@property (retain, nonatomic) IBOutlet UIView *cbPlayerView;
@property (retain, nonatomic) IBOutlet UILabel *currentProgress;
@property (retain, nonatomic) IBOutlet UILabel *remainsProgress;
@property (retain, nonatomic) IBOutlet UISlider *sliderProgress;
@property (retain, nonatomic) IBOutlet UITextField *playContentText;
@property (retain, nonatomic) IBOutlet UIButton *playButtonText;

- (IBAction)onClickStop:(id)sender;
- (IBAction)onClickPlay:(id)sender;
- (IBAction)onDragSlideValueChanged:(id)sender;
- (IBAction)onDragSlideStart:(id)sender;

- (IBAction)onDragSlideDone:(id)sender;
- (IBAction)back:(id)sender;
@end
