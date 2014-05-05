//
//  MainViewController.h
//  LeftRightSlider
//
//  Created by Zhao Yiqi on 13-11-27.
//  Copyright (c) 2013年 Zhao Yiqi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "ViewController1.h"
@interface MainViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *cameraHead;
@property (weak, nonatomic) IBOutlet UILabel *cameraName;
@property (weak, nonatomic) IBOutlet UILabel *cameraId;
@property (weak, nonatomic) IBOutlet UILabel *cameraStatus;
@property (nonatomic,assign) NSInteger index;
//@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
//- (void)reloadTableViewDataSource;
//- (void)doneLoadingTableViewData;
//- (IBAction)clickMOreAction:(id)sender;
//@property (strong, nonatomic) IBOutlet UITableViewCell *tableView;

@end
