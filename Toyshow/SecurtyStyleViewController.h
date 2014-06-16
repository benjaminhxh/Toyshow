//
//  SecurtyStyleViewController.h
//  Delegate
//
//  Created by zhxf on 14-6-3.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SecurtyStyleViewController;
@protocol SecurtyStyleViewControllerDelegate <NSObject>

- (void)securtyStyleSelect:(NSString *)securtyStyle withIndex:(NSInteger)index withpwd:(NSString *)pwd;

@end
@interface SecurtyStyleViewController : UIViewController

@property (nonatomic,assign) NSInteger selectIndex;
@property (nonatomic, copy) NSString *pwd;

@property (nonatomic,assign) id<SecurtyStyleViewControllerDelegate> delegate;

@end
