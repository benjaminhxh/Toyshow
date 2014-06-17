//
//  ImageResolutionViewController.h
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageResolutionViewController;
@protocol ImageResolutionViewControllerDelegate <NSObject>

- (void)imageResolution:(NSString *)resolution withIndex:(NSInteger )index;

@end

@interface ImageResolutionViewController : UIViewController

@property (nonatomic, copy) NSString *resolution;
@property (nonatomic, assign) NSInteger imageResolutionIndex;
@property (nonatomic, assign) id<ImageResolutionViewControllerDelegate> delegate;

@end
