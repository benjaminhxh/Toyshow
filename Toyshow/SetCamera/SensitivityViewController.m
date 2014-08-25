//
//  SensitivityViewController.m
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "SensitivityViewController.h"

@interface SensitivityViewController ()
{
    NSArray *sensitivityArr;
}
@end

@implementation SensitivityViewController

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
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 92, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"灵敏度" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    sensitivityArr = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",nil];
    UISegmentedControl *sensitity = [[UISegmentedControl alloc] initWithItems:sensitivityArr];
    sensitity.frame = CGRectMake(0, 80, 320, 30);
    [self.view addSubview:sensitity];
    sensitity.selectedSegmentIndex = self.index;
    [sensitity addTarget:self action:@selector(sensitivityAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)backAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(SensitivityleWithIndex:)]) {
        [self.delegate SensitivityleWithIndex:self.index];
    }else{
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"设置不成功" message:@"设置失败，请重新设置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
    }
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}


//灵敏度检测
- (void)sensitivityAction:(id)sender
{
    UISegmentedControl *sensitivityAction = (UISegmentedControl *)sender;
    self.index = sensitivityAction.selectedSegmentIndex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
