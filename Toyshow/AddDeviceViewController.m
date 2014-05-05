//
//  AddDeviceViewController.m
//  NewProject
//
//  Created by zhxf on 14-3-5.
//  Copyright (c) 2014年 Steven. All rights reserved.
//

#import "AddDeviceViewController.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CFNetwork/CFNetwork.h>
#import <arpa/inet.h>
#import <netdb.h>
#import "JSONKit.h"
#import "NetworkRequest.h"
#import "NetworkRequest.h"
#import "AFNetworking.h"

#define kTestHost @"telnet://towel.blinkenlights.nl"
#define kTestPort 23

@interface AddDeviceViewController ()<UIAlertViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate,UITextFieldDelegate>
{
    UITextField *deviceDetailF,*SSIDPWF,*SSIDF,*SSIDPWFconfirm;
    UIAlertView *nextAlertview,*loginAlterView,*configurationTipView;
}
@end

@implementation AddDeviceViewController

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
    UIImageView *background = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    background.image = [UIImage imageNamed:backGroundImage];
    [self.view addSubview:background];
    background.userInteractionEnabled = YES;
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44+[UIApplication sharedApplication].statusBarFrame.size.height)];
    topView.image = [UIImage imageNamed:navigationBarImageiOS7];
    topView.userInteractionEnabled = YES;
    [self.view addSubview:topView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, [UIApplication sharedApplication].statusBarFrame.size.height+5, 120, 22);
    [backBtn setTitle:@"配置摄像头" forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:backBtnImage] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backBtn];
//    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 160, 24)];
//    titleL.text = @"配置";
//    titleL.textColor = [UIColor whiteColor];
//    titleL.textAlignment = NSTextAlignmentCenter;
//    [topView addSubview:titleL];
    
    UILabel *deviceL = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 80, 30)];
    deviceL.text = @"设备ID:";
    [self.view addSubview:deviceL];
    UITextField *deviceF = [[UITextField alloc] initWithFrame:CGRectMake(120, 100, 180, 30)];
    deviceF.text = self.deviceID;
    deviceF.enabled = NO;
    deviceF.allowsEditingTextAttributes = YES;
    deviceF.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:deviceF];
    
    UILabel *deviceDetail = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 80, 30)];
    deviceDetail.text = @"设备描述:";
    [self.view addSubview:deviceDetail];
    deviceDetailF = [[UITextField alloc] initWithFrame:CGRectMake(120, 140, 180, 30)];
    deviceDetailF.borderStyle = UITextBorderStyleRoundedRect;
    deviceDetailF.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:deviceDetailF];
    
    UILabel *SSIDL = [[UILabel alloc] initWithFrame:CGRectMake(10, 180, 80, 30)];
    SSIDL.text = @"WiFi名称:";
    [self.view addSubview:SSIDL];
    SSIDF = [[UITextField alloc] initWithFrame:CGRectMake(120, 180, 180, 30)];
    SSIDF.borderStyle = UITextBorderStyleRoundedRect;
    SSIDF.text = [self fetchSSIDInfo];
    SSIDF.enabled = NO;
    [self.view addSubview:SSIDF];
    
    UILabel *SSIDPW = [[UILabel alloc] initWithFrame:CGRectMake(10, 220, 80, 30)];
    SSIDPW.text = @"WiFi密码:";
    [self.view addSubview:SSIDPW];
    SSIDPWF = [[UITextField alloc] initWithFrame:CGRectMake(120, 220, 180, 30)];
    SSIDPWF.borderStyle = UITextBorderStyleRoundedRect;
    SSIDPWF.returnKeyType = UIReturnKeyNext;
    [self.view addSubview:SSIDPWF];
    
    UILabel *SSIDPWconfirm = [[UILabel alloc] initWithFrame:CGRectMake(10, 260, 80, 30)];
    SSIDPWconfirm.text = @"确认密码:";
    [self.view addSubview:SSIDPWconfirm];
    SSIDPWFconfirm = [[UITextField alloc] initWithFrame:CGRectMake(120, 260, 180, 30)];
    SSIDPWFconfirm.borderStyle = UITextBorderStyleRoundedRect;
    SSIDPWFconfirm.returnKeyType = UIReturnKeyDone;
    [self.view addSubview:SSIDPWFconfirm];
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = CGRectMake(80, 360, 160, 40);
//    startBtn.backgroundColor = [UIColor blueColor];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"kaishipeizhi_anniu@2x"] forState:UIControlStateNormal];
    [startBtn setTitle:@"开始配置" forState:UIControlStateNormal];
    [startBtn addTarget:self action:@selector(startConfigure) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startBtn];
    
}

- (void)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//获取WiFi名称
- (id)fetchSSIDInfo {
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
//    NSLog(@"Supported interfaces: %@", ifs);
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
//        NSLog(@"%@ => %@", ifnam, info);
//        NSData *ssiddata = [info objectForKey:@"SSIDDATA"];
//        NSString *ssidda = [NSString stringWithFormat:@"%@",ssiddata ];
//        NSLog(@"ssiddata:%@",ssidda);
        if (info && [info count]) { break; }
    }
    NSString *SSID = [info objectForKey:@"SSID"];
    return SSID;
}

//开始配置
- (void)startConfigure
{
    //判断扫描到的二维码是否符合设备ID
    if ([self.deviceID hasPrefix:@"1100"]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备ID不合法" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }
    else if ([deviceDetailF.text isEqualToString:@""]||[SSIDPWF.text isEqualToString:@""]||[SSIDPWFconfirm.text isEqualToString:@""]) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备描述或密码不能为空" message:@"设备描述或密码不能为空" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }else if (![SSIDPWF.text isEqualToString:SSIDPWFconfirm.text])
    {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"密码输入不一致" message:@"密码输入不一致" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return ;
    }else if (deviceDetailF.text.length > 12) {
        UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"设备名称不能超过12个字符" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [view show];
        return;
    }
    //向Baidu服务器注册设备
//    NSData *data = [URLstr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *desc = [deviceDetailF.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *descc = [NSString stringWithUTF8String:[desc UTF8String]];

    NSString *URLstr = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=register&deviceid=%@&access_token=%@&device_type=1&desc=%@&Need_stream_id_when_exists=1",self.deviceID,self.access_token,descc];
    
    NSString *URLWithUTF8=(__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)URLstr, NULL,  CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [[AFHTTPSessionManager manager] GET:URLWithUTF8 parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        //--------------------向Baidu注册成功，隐藏loginAlterView-------------------------
        [loginAlterView dismissWithClickedButtonIndex:0 animated:YES];
        
        NSDictionary *dict = (NSDictionary *)responseObject;
        NSLog(@"dict:%@",dict);
        NSString *error_code = [dict objectForKey:@"error_code"];
        if (error_code) {
        NSLog(@"注册失败了:%@error_code",error_code);
            NSString *error_msg = [dict objectForKey:@"error_msg"];
            NSLog(@"error_msg:%@",error_msg);
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[NSString stringWithFormat:@"注册失败：%@",error_msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorView show];
            return ;
        }
        [self connectToWifi];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"==========访问服务器失败===============");
        //--------------------向Baidu注册成功，隐藏loginAlterView-------------------------
        [loginAlterView dismissWithClickedButtonIndex:0 animated:YES];
        NSLog(@"task:%@",task);
       NSDictionary *errorDict = [error userInfo];
        NSLog(@"dict:%@",errorDict);
        NSString *error_code = [errorDict objectForKey:@"error_code"];
        
        NSString *NSLocalizedDescription = [errorDict objectForKey:@"NSLocalizedDescription"];
        NSLog(@"NSLocalizedDescription:%@",NSLocalizedDescription);
        NSString *NSUnderlyingError = [errorDict objectForKey:@"NSUnderlyingError"];
        NSLog(@"NSUnderlyingError:%@",NSUnderlyingError);

        NSString *NSErrorFailingURLStringKey = [errorDict objectForKey:@"NSErrorFailingURLStringKey"];
        NSLog(@"NSErrorFailingURLStringKey:%@",NSErrorFailingURLStringKey);

//        NSDictionary *NSErrorFailingURLStringKey = [errorDict objectForKey:@"NSErrorFailingURLStringKey"];

        if (error_code) {
            NSLog(@"注册失败了:%@error_code",error_code);
            NSString *error_msg = [errorDict objectForKey:@"error_msg"];
            NSLog(@"error_msg:%@",error_msg);
            UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[NSString stringWithFormat:@"注册失败：%@",error_msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [errorView show];
            return ;
        }

        NSString *errorStr = [NSString stringWithFormat:@"%@",error];
        UIAlertView *failView = [[UIAlertView alloc] initWithTitle:@"连接失败"
                                                           message:errorStr
                                                          delegate:nil
                                                 cancelButtonTitle:@"OK"
                                                 otherButtonTitles:nil, nil];
        [failView show];
        return ;

    }];
//    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(loginAlterViewDismiss:) userInfo:nil repeats:NO];
    loginAlterView = [[UIAlertView alloc] initWithTitle:nil message:@"载入中\n请稍后……" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [loginAlterView show];
//    NSURL *requestURL = [NSURL URLWithString:URLstr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL];
//    [request setHTTPMethod:@"POST"];
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        if (connectionError||!data.length) {
//            NSString *errorStr = [NSString stringWithFormat:@"%@",connectionError];
//            UIAlertView *failView = [[UIAlertView alloc] initWithTitle:@"连接失败"
//                                                               message:errorStr
//                                                              delegate:nil
//                                                     cancelButtonTitle:@"OK"
//                                                     otherButtonTitles:nil, nil];
//            [failView show];
//            return ;
//        }
//        //解析Data，判断是否请求成功
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
//                                                       options:NSJSONReadingMutableLeaves
//                                                         error:nil];
////        NSLog(@"dict:%@",dict);
//        NSString *error_code = [dict objectForKey:@"error_code"];
////        if (error_code) {
//            NSLog(@"注册失败了:%@error_code",error_code);
////            dispatch_async(dispatch_get_main_queue(), ^{
//                NSString *error_msg = [dict objectForKey:@"error_msg"];
//        NSLog(@"error_msg:%@",error_msg);
////                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"错误信息" message:[NSString stringWithFormat:@"注册失败：%@",error_msg] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
////                [errorView show];
////                [self.view setNeedsDisplay];
////            });
//        
////            return;
////        }
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            nextAlertview = [[UIAlertView alloc] initWithTitle:@"连接设备AP" message:@"1.请切换到“系统设置”>>“无线局域网”\n2.连接joyshow,(密码为joyshow)\n3.切换回此页面，点击下一步" delegate:self cancelButtonTitle:@"下一步" otherButtonTitles:nil, nil];
//            nextAlertview.delegate = self;
//            [nextAlertview show];
////            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 200, 40)];
////            label.text = @"下一步";
////            [nextAlertview addSubview:label];
//            
//            //            [self.view setNeedsDisplay];
//        });
//    }];


//    NSDictionary *dict = [[NetworkRequest shareInstance]requestWithURL:URLstr setHTTPMethod:@"POST"];
    
}

- (void)connectToWifi
{
    nextAlertview = [[UIAlertView alloc] initWithTitle:@"连接设备AP" message:@"1.请切换到“系统设置”>>“无线局域网”\n2.连接joyshow,(密码为joyshow)\n3.切换回此页面，点击下一步" delegate:self cancelButtonTitle:@"下一步" otherButtonTitles:nil, nil];
    nextAlertview.delegate = self;
    [nextAlertview show];
}
//- (void)loginAlterViewDismiss:(id)sender
//{
//
//}
#pragma mark - alertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"下一步");
    [self.view setNeedsDisplay];

    //判断WiFi名是否以joyshow开头
    if ([[self fetchSSIDInfo]hasPrefix:@"joyshow" ]) {
        [self openUDPServer];
        NSDictionary *headDict = [NSDictionary dictionaryWithObjectsAndKeys:@"62",@"length",@"23130",@"verify", nil];
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:@"IOS",@"OS",SSIDF.text,@"SSID",SSIDPWF.text,@"PWD",self.userID,@"USERID",headDict,@"HEAD", nil];
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:dataDict,@"DATA", nil];
        NSString *jsonStr = [dict JSONString];
        [self sendMassage:jsonStr];
        configurationTipView = [[UIAlertView alloc] initWithTitle:@"nil" message:@"正在配置，请稍后……" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [configurationTipView show];
        return;
    }
    if (nextAlertview == alertView ) {
        [self connectToWifi];
    }
}



#pragma mark - HTTPrequest
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
//{
//    //失败
//    NSString *errorStr = [NSString stringWithFormat:@"%@",error];
//    UIAlertView *failView = [[UIAlertView alloc] initWithTitle:@"连接失败" message:errorStr delegate:nil
//    cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [failView show];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    //数据接收完成
//    UIAlertView *finishView = [[UIAlertView alloc] initWithTitle:@"配置完成" message:@"成功配置摄像头" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [finishView show];
//}
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    //接收数据
//    
//}

#pragma mark - UDP Socket
//建立基于UDP的Socket连接
-(void)openUDPServer{
	//初始化udp
	AsyncUdpSocket *tempSocket=[[AsyncUdpSocket alloc] initWithDelegate:self];
	self.udpSocket=tempSocket;
    //	[tempSocket release];
	//绑定端口
	NSError *error = nil;
	[self.udpSocket bindToPort:7860 error:&error];
    
    //绑定地址
    //    [self.udpSocket bindToAddress:@"192.168.8.1" port:7860 error:&error];
    
    //发送广播设置
    //    [self.udpSocket enableBroadcast:YES error:&error];
    
    //加入群里，能接收到群里其他客户端的消息
    //    [self.udpSocket joinMulticastGroup:@"224.0.0.2" error:&error];
    
   	//启动接收线程
	[self.udpSocket receiveWithTimeout:-1 tag:0];
    
}

//通过UDP,发送消息
-(void)sendMassage:(NSString *)message
{
    
    //	NSDate *nowTime = [NSDate date];
	
	NSMutableString *sendString=[NSMutableString stringWithCapacity:100];
	[sendString appendString:message];
	//开始发送
	BOOL res = [self.udpSocket sendData:[sendString dataUsingEncoding:NSUTF8StringEncoding]
								 toHost:@"192.168.8.1"
								   port:7860
							withTimeout:-1
                
                                    tag:0];
    
    
   	if (!res) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
														message:@"发送失败"
													   delegate:self
											  cancelButtonTitle:@"取消"
											  otherButtonTitles:nil];
		[alert show];
        //		[alert release];
	}
	
    //	if ([self.chatArray lastObject] == nil) {
    //		self.lastTime = nowTime;
    //		[self.chatArray addObject:nowTime];
    //	}
    //
    //	NSTimeInterval timeInterval = [nowTime timeIntervalSinceDate:self.lastTime];
    //	if (timeInterval >5) {
    //		self.lastTime = nowTime;
    //		[self.chatArray addObject:nowTime];
    //	}
}

#pragma mark -
#pragma mark UDP Delegate Methods
- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port
{
    
    [self.udpSocket receiveWithTimeout:-1 tag:0];
    NSLog(@"host---->%@",host);
    
    //    //收到自己发的广播时不显示出来
    //    NSMutableString *tempIP = [NSMutableString stringWithFormat:@"::ffff:%@",myIP];
    //    if ([host isEqualToString:self.myIP]||[host isEqualToString:tempIP])
    //    {
    //        //        return YES;
    //    }
    
   	//接收到数据回调，用泡泡VIEW显示出来
	
	NSString *info=[[NSString alloc] initWithData:data encoding: NSUTF8StringEncoding];
	NSLog(@"UDP代理接收到的数据：%@",info);
	//已经处理完毕
    //configurationTipView 消失
    [configurationTipView dismissWithClickedButtonIndex:0 animated:YES];
	return YES;
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法发送时,返回的异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
    //	[alert release];
	
}

- (void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error
{
	//无法接收时，返回异常提示信息
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
													message:[error description]
												   delegate:self
										  cancelButtonTitle:@"取消"
										  otherButtonTitles:nil];
	[alert show];
    //	[alert release];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

////强制不允许转屏
//- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait);
//}
//
//- (NSUInteger)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskPortrait;
//}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (deviceDetailF == textField) {
        [SSIDPWF becomeFirstResponder];
    }else if(SSIDPWF == textField)
    {
        [SSIDPWFconfirm becomeFirstResponder];
    }
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.view setNeedsDisplay];
}

@end
