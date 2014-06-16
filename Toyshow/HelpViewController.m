//
//  HelpViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-12.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "HelpViewController.h"
#import "SliderViewController.h"
#import "TransformViewController.h"
#import "NetworkRequest.h"
#import "AFNetworking.h"
#import "HowToUseViewController.h"

@interface HelpViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation HelpViewController

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

//    background.image = [UIImage imageNamed:backGroundImage];
//    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 62, 22);
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn) forControlEvents:UIControlEventTouchUpInside];
    [backBtn setTitle:@"帮助" forState:UIControlStateNormal];
//    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 180, 22);
//    [backBtn setTitle:@"无线路由器认证方式" forState:UIControlStateNormal];
    [topView addSubview:backBtn];

    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(275, [UIApplication sharedApplication].statusBarFrame.size.height+5, 36, 22);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:finishBtn];
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(30, 25, 120, 24)];
//    title.textColor = [UIColor whiteColor];
//    title.text = @"帮助";
////    title.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:title];
    
//    UIButton *nextBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
//    nextBtn.frame = CGRectMake(260, 25, 50, 24);
//    [nextBtn addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:nextBtn];
    
    UITableView *tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64) style:UITableViewStylePlain];
    tabView.delegate = self;
    tabView.dataSource = self;
    [self.view addSubview:tabView];
}

- (void)backBtn{
//    [self dismissViewControllerAnimated:YES completion:^{
//    }];
    [[SliderViewController sharedSliderController]leftItemClick];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellI = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellI];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellI];
        cell.imageView.image = [UIImage imageNamed:@"dingshi_h@2x"];
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.textLabel.text = @"如何使用乐现";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    HowToUseViewController *howUseVC = [[HowToUseViewController alloc] init];
    [self presentViewController:howUseVC animated:YES completion:nil];
}

//强制不允许转屏
- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
