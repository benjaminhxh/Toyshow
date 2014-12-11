//
//  UINavigationController+Autorotate.h
//  TestLandscape
//
//  Created by zhxf on 14-2-27.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationController (Autorotate)

- (BOOL)shouldAutorotate   ;
- (NSUInteger)supportedInterfaceOrientations;

@end
