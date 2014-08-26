//
//  ImageResolutionViewController.m
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "ImageResolutionViewController.h"

@interface ImageResolutionViewController ()
{
    NSArray *resolurationArr;
}
@end

@implementation ImageResolutionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 86, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"分辨率" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    resolurationArr = [NSArray arrayWithObjects:@"1080P",@"720P",@"4CIF",@"640*480",@"352*288", nil];
    UISegmentedControl *imageResolution = [[UISegmentedControl alloc] initWithItems:resolurationArr];
    imageResolution.frame = CGRectMake(5, 80, 310, 30);
    [self.view addSubview:imageResolution];
    imageResolution.selectedSegmentIndex = self.imageResolutionIndex-1;
    [imageResolution addTarget:self action:@selector(imageResolutionAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)backAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageResolution:withIndex:)]) {
        [self.delegate imageResolution:[resolurationArr objectAtIndex:self.imageResolutionIndex - 1] withIndex:self.imageResolutionIndex];
    }else{
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"设置不成功" message:@"设置失败，请重新设置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
    }
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];

}


//图像分辨率
- (void)imageResolutionAction:(id)sender
{
    UISegmentedControl *imageRerolut = (UISegmentedControl *)sender;
    self.imageResolutionIndex = imageRerolut.selectedSegmentIndex+1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
