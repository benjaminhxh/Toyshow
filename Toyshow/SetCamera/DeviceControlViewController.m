//
//  DeviceControlViewController.m
//  DelegateTest
//
//  Created by zhxf on 14-6-16.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "DeviceControlViewController.h"

@interface DeviceControlViewController ()
{
    NSArray *deviceControlArr;
}
@end

@implementation DeviceControlViewController

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
    [backBtn setTitle:@"设备控制" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    deviceControlArr = [NSArray arrayWithObjects:@"睡眠",@"唤醒",@"关闭", nil];
    UISegmentedControl *deviceControl = [[UISegmentedControl alloc] initWithItems:deviceControlArr];
    deviceControl.frame = CGRectMake(10, 80, 300, 30);
    [self.view addSubview:deviceControl];
    deviceControl.selectedSegmentIndex = self.index-1;
    [deviceControl addTarget:self action:@selector(deviceControlAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)backAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceControlMode:withIndex:)]) {
        [self.delegate deviceControlMode:[deviceControlArr objectAtIndex:self.index - 1] withIndex:self.index];
    }else{
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"设置不成功" message:@"设置失败，请重新设置" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [errorView show];
    }
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}


//睡眠、唤醒、关闭
- (void)deviceControlAction:(id)sender
{
    UISegmentedControl *imageRerolut = (UISegmentedControl *)sender;
    self.index = imageRerolut.selectedSegmentIndex+1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
