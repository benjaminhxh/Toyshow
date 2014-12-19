//
//  ManageAuthorViewController.m
//  Joyshow
//
//  Created by xiaohuihu on 14/12/19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ManageAuthorViewController.h"
#import "AddAuthorViewController.h"

@interface ManageAuthorViewController ()
{
    UIScrollView *scrollView;
}
@end

@implementation ManageAuthorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 25, 130, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn setTitle:@"管理授权用户" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIButton *addUserBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addUserBtn.frame = CGRectMake(kWidth-65, 25-3, 55, 35);
    [addUserBtn setTitle:@"新增" forState:UIControlStateNormal];
    [addUserBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addUserBtn setBackgroundImage:[UIImage imageNamed:@"lishijilu@2x"] forState:UIControlStateNormal];
    [addUserBtn addTarget:self action:@selector(addUserClick) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:addUserBtn];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight-44);
    [self.view addSubview:scrollView];
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
}

- (void)backBtn{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)addUserClick
{
    AddAuthorViewController *addAuthorVC = [[AddAuthorViewController alloc] init];
    [[SliderViewController sharedSliderController].navigationController pushViewController:addAuthorVC animated:YES];
}

-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
