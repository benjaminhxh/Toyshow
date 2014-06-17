//
//  NtscOrpalViewController.h
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NtscOrpalViewController;
@protocol  NtscOrpalViewControllerDelegate<NSObject>

- (void)ntscOrpalMode:(NSString *)mode withIndex:(NSInteger )index;

@end
@interface NtscOrpalViewController : UIViewController

@property(nonatomic, copy) NSString *ntscOrpalMode;
@property(nonatomic, assign) NSInteger ntscOrpalIndex;//NTSC/PAL
@property(nonatomic, assign) id<NtscOrpalViewControllerDelegate> delegate;

@end
