//
//  SceneModeViewController.m
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "SceneModeViewController.h"

@interface SceneModeViewController ()
{
    NSArray *lightmodeArr;
}
@end

@implementation SceneModeViewController

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
    backBtn.frame = CGRectMake(5, 25, 102, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"拍摄模式" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    lightmodeArr = [NSArray arrayWithObjects:@"自动",@"白天",@"夜间", nil];
    UISegmentedControl *modeControl = [[UISegmentedControl alloc] initWithItems:lightmodeArr];
    modeControl.frame = CGRectMake(10, 80, 300, 30);
    modeControl.selectedSegmentIndex = self.lightFilterIndex - 1;
    [modeControl addTarget:self action:@selector(cameraModeAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:modeControl];
    
}

- (void)backAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(scenceMode:withIndex:)]) {
        [self.delegate scenceMode:[lightmodeArr objectAtIndex:self.lightFilterIndex - 1] withIndex:self.lightFilterIndex];
    }else{
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"设置不成功" message:@"设置失败，请重新设置" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [errorView show];
    }
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}
//自动、白天。夜间
- (void)cameraModeAction:(id)sender
{
    UISegmentedControl *cameraModecontrol = (UISegmentedControl *)sender;
    self.lightFilterIndex = cameraModecontrol.selectedSegmentIndex+1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
