//
//  IPObtainStyleViewController.m
//  Delegate
//
//  Created by zhxf on 14-6-3.
//  Copyright (c) 2014年 hxh. All rights reserved.
//

#import "IPObtainStyleViewController.h"

@interface IPObtainStyleViewController ()<UITextFieldDelegate>
{
    UIView *staticView;
    UILabel *dhcpLab;
    UITextField *ipAddressF,*subnetmaskF,*routerF;
    UIScrollView *scrollView;
}
@end

@implementation IPObtainStyleViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
	// Do any additional setup after loading the view.
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 162, 22);
    [backBtn setTitle:@"IP地址获取方式" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
    
    UIButton *finishBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(275, [UIApplication sharedApplication].statusBarFrame.size.height+5, 36, 22);
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:finishBtn];
    
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
    scrollView.contentSize = CGSizeMake(kWidth, kHeight);
    [self.view addSubview:scrollView];
    
    NSArray *ipArr = [NSArray arrayWithObjects:@"自动获取",@"手动设置", nil];
    UISegmentedControl *IPControl = [[UISegmentedControl alloc] initWithItems:ipArr];
    IPControl.frame = CGRectMake(20, 16, 280, 40);
    IPControl.selectedSegmentIndex = self.selectedIndex;
    [IPControl addTarget:self action:@selector(ipstyleAction:) forControlEvents:UIControlEventValueChanged];
    [scrollView addSubview:IPControl];

    dhcpLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 66, 280, 114)];
    dhcpLab.numberOfLines = 3;
    dhcpLab.textColor = [UIColor grayColor];
    dhcpLab.text = @"默认为\"自动获取\"，如您更改为\"手动设置\"，可能出现配置不成功的情况，请谨慎选择！";
    [scrollView addSubview:dhcpLab];
    
    staticView = [[UIView alloc] initWithFrame:CGRectMake(0, 66, 320, 114)];
    [scrollView addSubview:staticView];
    staticView.layer.cornerRadius = 1;
    staticView.layer.borderWidth = 1;
    staticView.layer.borderColor = [UIColor grayColor].CGColor;
    UILabel *ipAddress = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 100, 24)];
    ipAddress.text = @"IP地址:";
    [staticView addSubview:ipAddress];
    ipAddressF = [[UITextField alloc] initWithFrame:CGRectMake(140, 10, 160, 24)];
    ipAddressF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    
    ipAddressF.delegate = self;
    [staticView addSubview:ipAddressF];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 38, 320, 1)];
    lineView1.backgroundColor = [UIColor grayColor];
    [staticView addSubview:lineView1];
    UILabel *subnetMask = [[UILabel alloc] initWithFrame:CGRectMake(20, 46, 100, 24)];
    subnetMask.text = @"子网掩码:";
    [staticView addSubview:subnetMask];
    
    subnetmaskF = [[UITextField alloc] initWithFrame:CGRectMake(140, 46, 160, 24)];
    subnetmaskF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    subnetmaskF.delegate = self;
    [staticView addSubview:subnetmaskF];
    
    UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 76, 320, 1)];
    lineView2.backgroundColor = [UIColor grayColor];
    [staticView addSubview:lineView2];

    UILabel *router = [[UILabel alloc] initWithFrame:CGRectMake(20, 82, 100, 24)];
    router.text = @"路由器:";
    [staticView addSubview:router];
    
    routerF = [[UITextField alloc] initWithFrame:CGRectMake(140, 82, 160, 24)];
    routerF.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    routerF.delegate = self;
    [staticView addSubview:routerF];

    if (self.selectedIndex) {
        ipAddressF.text = [self.ipParameter objectForKey:@"ipadrr"];
        subnetmaskF.text = [self.ipParameter objectForKey:@"mask"];
        routerF.text = [self.ipParameter objectForKey:@"gateway"];
        staticView.hidden = NO;
        dhcpLab.hidden = YES;
    }else
    {
        ipAddressF.text = @"192.168.1.20";
        subnetmaskF.text = @"255.255.255.0";
        routerF.text = @"192.168.1.1";
        staticView.hidden = YES;
        dhcpLab.hidden = NO;
    }

}

#pragma mark - isLegaIP
- (BOOL)isLegalIP:(NSString *)ipString
{
    NSArray *ipArr = [ipString componentsSeparatedByString:@"."];
    if (ipArr.count == 4) {
        for (NSString *ips in ipArr) {
            int i = [ips intValue];
            if([[NSString stringWithFormat:@"%d",i] isEqualToString:ips])
            {
                NSLog(@"i:%d",i);
                if (i<=255&&i>=0) {
                }else
                {
//                    NSLog(@"不合法");
                    return NO;
                }
            }else{
//                NSLog(@"不合法");
                return NO;
            }
        }
    }else
    {
        NSLog(@"不合法");
        return NO;
    }
    return YES;
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)finishBtnAction:(id)sender
{
    NSInteger inter;
    NSDictionary *dict;
    if (staticView.hidden) {
        inter = 0;
        dict = nil;
    }else
    {
        //判断ip是否合法
        if(![self isLegalIP:ipAddressF.text]||![self isLegalIP:subnetmaskF.text]||![self isLegalIP:routerF.text])
       {
           NSLog(@"不合法的IP");
           UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入合法的地址" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
           [view show];
           return;
       }
        inter = 1;
        dict = [NSDictionary dictionaryWithObjectsAndKeys:ipAddressF.text,@"ipadrr",subnetmaskF.text,@"mask",routerF.text,@"gateway", nil];
    }
    //通过代理传递参数回去
    if (self.delegate && [self.delegate respondsToSelector:@selector(ipObtainStyle:withStaticParameter:)]) {
        [self.delegate ipObtainStyle:inter withStaticParameter:dict];
    }
    
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)ipstyleAction:(id)sender
{
    UISegmentedControl *segment = (UISegmentedControl *)sender;
    if (segment.selectedSegmentIndex) {
        NSLog(@"1111111111");
        staticView.hidden = NO;
        dhcpLab.hidden = YES;
    }else
    {
        NSLog(@"0000000000");
        staticView.hidden = YES;
        dhcpLab.hidden = NO;
    }
}

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
//{
//    return NO;
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (ipAddressF == textField) {
        [subnetmaskF becomeFirstResponder];
    }else if (subnetmaskF == textField)
    {
        [routerF becomeFirstResponder];
    }else
    {
        [self.view endEditing:YES];
    }
    return YES;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [scrollView endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
