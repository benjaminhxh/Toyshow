//
//  NtscOrpalViewController.m
//  Delegate
//
//  Created by zhxf on 14-6-13.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "NtscOrpalViewController.h"

@interface NtscOrpalViewController ()
{
    NSArray *ntsOrPalArr;
}
@end

@implementation NtscOrpalViewController

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
    backBtn.frame = CGRectMake(5, 25, 162, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"NTSC或PAL制式" forState:UIControlStateNormal];
    [topView addSubview:backBtn];
    
    ntsOrPalArr = [NSArray arrayWithObjects:@"NTSC",@"PAL", nil];
    UISegmentedControl *ntscOrpal = [[UISegmentedControl alloc] initWithItems:ntsOrPalArr];
    ntscOrpal.frame = CGRectMake(60, 80, 200, 30);
    [self.view addSubview:ntscOrpal];
    ntscOrpal.selectedSegmentIndex = self.ntscOrpalIndex - 1;
    [ntscOrpal addTarget:self action:@selector(ntscOrpalAction:) forControlEvents:UIControlEventValueChanged];
}

- (void)backAction:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ntscOrpalMode:withIndex:)]) {
        [self.delegate ntscOrpalMode:[ntsOrPalArr objectAtIndex:self.ntscOrpalIndex - 1] withIndex:self.ntscOrpalIndex];
    }else{
        UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"设置不成功" message:@"设置失败，请重新设置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [errorView show];
    }
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}


//NTSC、PAL制式
- (void)ntscOrpalAction:(id)sender
{
    UISegmentedControl *ntscorpal = (UISegmentedControl *)sender;
    self.ntscOrpalIndex = ntscorpal.selectedSegmentIndex+1;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
