//
//  ModifyViewController.h
//  Toyshow
//
//  Created by zhxf on 14-4-15.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class ModifyViewController;
//@protocol ModifyViewControllerDelegate <NSObject>
//
//- (void)modifySuccessWith:(NSString *)newName;
//
//@end
@interface ModifyViewController : UIViewController

@property (nonatomic,weak)NSString *deviceId;
@property (nonatomic,weak)NSString *deviceName;
@property (nonatomic,weak)NSString *accessToken;
//@property (nonatomic,assign) id <ModifyViewControllerDelegate>delegate;

@end
