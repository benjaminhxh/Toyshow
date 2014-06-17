//
//  SensitivityViewController.h
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SensitivityViewController;
@protocol SensitivityViewControllerDelegate <NSObject>

- (void)SensitivityleWithIndex:(NSInteger) index;

@end

@interface SensitivityViewController : UIViewController

@property(nonatomic, assign) NSInteger index;//检测灵敏度
@property (nonatomic, assign) id<SensitivityViewControllerDelegate> delegate;

@end
