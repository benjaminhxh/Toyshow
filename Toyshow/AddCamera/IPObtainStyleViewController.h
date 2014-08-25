//
//  IPObtainStyleViewController.h
//  Delegate
//
//  Created by zhxf on 14-6-3.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IPObtainStyleViewController;
@protocol  IPObtainStyleViewControllerDelegate<NSObject>

- (void)ipObtainStyle:(NSInteger)integer withStaticParameter:(NSDictionary*)ipParameter;

@end

@interface IPObtainStyleViewController : UIViewController

@property(nonatomic,assign) NSInteger selectedIndex;
@property(nonatomic,copy) NSDictionary *ipParameter;

@property(nonatomic,assign) id<IPObtainStyleViewControllerDelegate> delegate;

@end
