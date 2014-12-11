//
//  SliderViewController.h
//  LeftRightSlider
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SliderViewController : UIViewController

@property(nonatomic,strong)UIViewController *LeftVC;
@property(nonatomic,strong)UIViewController *RightVC;
@property(nonatomic,strong)UIViewController *MainVC;
@property(nonatomic,strong)NSDictionary *dict;

@property(nonatomic,assign)float LeftSContentOffset;
@property(nonatomic,assign)float RightSContentOffset;

@property(nonatomic,assign)float LeftSContentScale;
@property(nonatomic,assign)float RightSContentScale;

@property(nonatomic,assign)float LeftSJudgeOffset;
@property(nonatomic,assign)float RightSJudgeOffset;

@property(nonatomic,assign)float LeftSOpenDuration;
@property(nonatomic,assign)float RightSOpenDuration;

@property(nonatomic,assign)float LeftSCloseDuration;
@property(nonatomic,assign)float RightSCloseDuration;

+ (SliderViewController*)sharedSliderController;

- (void)showContentControllerWithModel:(NSString*)className withDictionary:(NSDictionary *)dict;

- (void)leftItemClick;
- (void)rightItemClick;

@end
