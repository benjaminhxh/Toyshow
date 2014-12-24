//
//  ManageAuthorViewController.m
//  Joyshow
//
//  Created by xiaohuihu on 14/12/19.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ManageAuthorViewController.h"
#import "AddAuthorViewController.h"
#import "MJRefreshHeaderView.h"
#import "MJRefreshFooterView.h"

@interface ManageAuthorViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *scrollView;
    NSMutableArray *_fakeData,*downloadArr;
    UITableView *_tabview;
    MBProgressHUD *badInternetHub;
    NSInteger index;
    MJRefreshHeaderView *_headerView;
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
    
//    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64)];
//    scrollView.contentSize = CGSizeMake(kWidth, kHeight-44);
//    [self.view addSubview:scrollView];
    
    _tabview = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, kWidth, kHeight-64) style:UITableViewStylePlain];
    _tabview.delegate = self;
    _tabview.dataSource = self;
    _tabview.backgroundColor = [UIColor clearColor];
    _tabview.separatorStyle = UITableViewCellSelectionStyleNone;
    [self.view addSubview:_tabview];
    
    
    //右滑回到上一个页面
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(backBtn)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_tabview addGestureRecognizer:recognizer];
    
    //2、初始化数据
    _fakeData = [NSMutableArray array];
    [self addheader];
}

- (void)addheader{
    __unsafe_unretained ManageAuthorViewController *vc = self;
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = _tabview;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        // 进入刷新状态就会回调这个Block
        //向服务器发起请求
        NSString *urlSTR = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=listgrantuser&access_token=%@&deviceid=%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken],self.deviceID];
//        NSLog(@"urlSTR:%@",urlSTR);
        [[AFHTTPRequestOperationManager manager] GET:urlSTR parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSDictionary *dict = (NSDictionary *)responseObject;
            //            //NSLog(@"收藏的dict:%@",dict);
            //2、初始化数据
            _fakeData = [NSMutableArray array];
            downloadArr = [NSMutableArray array];
            downloadArr = [[dict objectForKey:@"list"] mutableCopy];
            if (downloadArr.count == 0) {
                [self MBprogressViewHubLoading:@"无授权用户" withMode:4];
                [badInternetHub hide:YES afterDelay:1];
            }else
            {
                vc->_fakeData = downloadArr;
            }
            [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self MBprogressViewHubLoading:@"网络延时" withMode:4];
            [badInternetHub hide:YES afterDelay:1];
            [vc performSelector:@selector(doneWithView:) withObject:refreshView afterDelay:KdurationSuccess];
        }];
        // 模拟延迟加载数据，因此2秒后才调用）
        // 这里的refreshView其实就是header
        [vc performSelector:@selector(doneWithViewWithNoInterNet:) withObject:refreshView afterDelay:KdurationFail];
        //NSLog(@"%@----开始进入刷新状态", refreshView.class);
    };
    [header beginRefreshing];
    _headerView = header;
}

- (void)doneWithView:(MJRefreshBaseView*)sender
{
    //刷新表格
    [_tabview reloadData];
    [sender endRefreshing];
}

- (void)doneWithViewWithNoInterNet:(MJRefreshBaseView*)sender
{
    //刷新表格
    [sender endRefreshing];
}

- (void)MBprogressViewHubLoading:(NSString *)labtext withMode:(int)mode
{
    if (badInternetHub) {
        badInternetHub.labelText = labtext;
        //        badInternetHub.mode = mode;
        [badInternetHub show:YES];
        return;
    }
    badInternetHub = [[MBProgressHUD alloc] initWithView:_tabview];
    badInternetHub.labelText = labtext;
    //    badInternetHub.mode = mode;
    badInternetHub.square = YES;
    [_tabview addSubview:badInternetHub];
    [badInternetHub show:YES];
}

- (void)backBtn{
    [[SliderViewController sharedSliderController].navigationController popViewControllerAnimated:YES];
}

- (void)addUserClick
{
    AddAuthorViewController *addAuthorVC = [[AddAuthorViewController alloc] init];
    addAuthorVC.deviceID = self.deviceID;
    [[SliderViewController sharedSliderController].navigationController pushViewController:addAuthorVC animated:YES];
}

#pragma mark - tableViewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_fakeData.count) {
        return _fakeData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentf = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentf];
    if (cell==nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ManageAuthor" owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary *dict = [_fakeData objectAtIndex:indexPath.row];
    self.authorCode.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"uk"]];
    self.accountName.text = [dict objectForKey:@"name"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"取消授权";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertView *deleteVodView = [[UIAlertView alloc] initWithTitle:nil message:@"取消授权之后该用户将不能再访问该摄像头"
                                                           delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"取消授权", nil];
    [deleteVodView show];
    index = indexPath.row;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSString *uk = [[_fakeData objectAtIndex:index] objectForKey:@"uk"];
        NSString *deleteURL = [NSString stringWithFormat:@"https://pcs.baidu.com/rest/2.0/pcs/device?method=dropgrantuser&access_token=%@&deviceid=%@&uk=%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserAccessToken],self.deviceID,uk];
        [[AFHTTPRequestOperationManager manager] POST:deleteURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSMutableArray *mutabArr = [[NSMutableArray arrayWithArray:_fakeData] mutableCopy];
            [mutabArr removeObjectAtIndex:index];
            _fakeData = mutabArr;
                [_tabview reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //            NSLog(@"errror:%@",error);
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_headerView beginRefreshing];
}

-(NSUInteger)supportedInterfaceOrientations
{
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
