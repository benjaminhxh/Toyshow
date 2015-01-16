//
//  MainViewController.h
//  LeftRightSlider
//
//  Created by zhxf on 14-3-19.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface MainViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *cameraHead;
@property (weak, nonatomic) IBOutlet UILabel *cameraName;
//@property (weak, nonatomic) IBOutlet UILabel *cameraId;
@property (weak, nonatomic) IBOutlet UILabel *cameraStatus;
@property (nonatomic,assign) NSInteger index;
//@property (nonatomic, weak) NSString *sign;
//@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
//- (void)reloadTableViewDataSource;
//- (void)doneLoadingTableViewData;
//- (IBAction)clickMOreAction:(id)sender;
@end
