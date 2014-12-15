//
//  SecurtyStyleViewController.m
//  Delegate
//
//  Created by zhxf on 14-6-3.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "SecurtyStyleViewController.h"

@interface SecurtyStyleViewController ()
{
    UILabel *explainLab;
    UIView *userView;
    UITextField *pwdField;
    NSArray *securtyStyleArr,*explainArr;
}
@end

@implementation SecurtyStyleViewController

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
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 64)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    float backHeight;
    if (iOS7) {
        backHeight = kStatusbarHeight + 5;
    }else
    {
        backHeight = kStatusbarHeight + 25;
    }
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, backHeight, 180, 22);
    [backBtn setTitle:@"无线路由器认证方式" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(275, backHeight, 36, 22);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:finishBtn];

    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [self.view addGestureRecognizer:recognizer];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    [self.view addSubview:scrollView];
    
    explainArr = [NSArray arrayWithObjects:@"WPA/WPA2、WPA-PSk/WPA2-PSK是当前路由器无线认证常用的安全类型，安全性相对较高。",@"802.1x(EAP)常用于需要二次认证的无线路由器",@"WEP是比较老的路由器无线认证安全类型，安全性较低。",@"ESS是不需要认证的方式", nil];
    securtyStyleArr = [NSArray arrayWithObjects:@"WPA*",@"EAP",@"WEP",@"ESS", nil];
    UISegmentedControl *wepControl = [[UISegmentedControl alloc] initWithItems:securtyStyleArr];
    wepControl.frame = CGRectMake(10, 16, 300, 40);
    [wepControl addTarget:self action:@selector(selectWEBstyle:) forControlEvents:UIControlEventValueChanged];
    wepControl.selectedSegmentIndex = self.selectIndex;
    [scrollView addSubview:wepControl];
    
    userView = [[UIView alloc] initWithFrame:CGRectMake(20, 56, 280, 40)];
    [scrollView addSubview:userView];
    UILabel *userL = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 68, 30)];
    userL.text = @"用户名:";
    [userView addSubview:userL];
    pwdField = [[UITextField alloc] initWithFrame:CGRectMake(70, 10, 200, 30)];
    pwdField.borderStyle = UITextBorderStyleLine;
    pwdField.keyboardType = UIKeyboardTypeASCIICapable;
    pwdField.text = self.pwd;
    [userView addSubview:pwdField];
    if (1 == self.selectIndex) {
        userView.hidden = NO;
    }else
    {
        userView.hidden = YES;
    }
    explainLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 96, 280, 72)];
    explainLab.text = [explainArr objectAtIndex:self.selectIndex];
    explainLab.textColor = [UIColor grayColor];
    explainLab.numberOfLines = 3;
//    explainLab.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:explainLab];
}

- (void)selectWEBstyle:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    ////NSLog(@"segment.selectIndex:%d",segment.selectedSegmentIndex);
    self.selectIndex = segment.selectedSegmentIndex;
    explainLab.text = [explainArr objectAtIndex:self.selectIndex];

    switch (segment.selectedSegmentIndex) {
        case 0:
        {
//            explainLab.text = @"WPA/WPA2、WPA-PSk/WPA2-PSK是当前路由器无线认证常用的安全类型，安全性相对较高。";
            userView.hidden = YES;
            pwdField.text = @"";
        }
            break;
        case 1:
        {
//            explainLab.text = @"802.1x(EAP)常用于需要二次认证的无线路由器";
            userView.hidden = NO;
        }
            break;
        case 2:
            userView.hidden = YES;
            pwdField.text = @"";

//            explainLab.text = @"WEP是比较老的路由器无线认证安全类型，安全性较低。";

            break;
        case 3:
            userView.hidden = YES;
            pwdField.text = @"";

//            explainLab.text = @"ESS是不需要认证的方式";
            break;
       
        default:
            break;
    }
}
- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishBtnAction:(id)sender
{
    if (1 == self.selectIndex && [pwdField.text isEqual:@""]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"用户名不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(securtyStyleSelect:withIndex:withpwd:)]) {
        [self.delegate securtyStyleSelect:[securtyStyleArr objectAtIndex:self.selectIndex] withIndex:self.selectIndex withpwd:pwdField.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
 
@end
