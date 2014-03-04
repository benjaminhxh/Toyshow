//
//  ShowImageViewController.m
//  Toyshow
//
//  Created by zhxf on 14-3-3.
//  Copyright (c) 2014年 zhxf. All rights reserved.
//

#import "ShowImageViewController.h"
#import "iCarousel.h"

@interface ShowImageViewController ()<iCarouselDataSource,iCarouselDelegate>
{
    NSArray *_imageArray;
}
@end

@implementation ShowImageViewController

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
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(5, 20, 40, 20);
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn setTitle:@"返回" forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    UIImage *image1 = [UIImage imageNamed:@"310_268_02"];
    UIImage *image2 = [UIImage imageNamed:@"310_268_03"];
    UIImage *image3 = [UIImage imageNamed:@"310_268_04"];
    _imageArray = [NSArray arrayWithObjects:image1,image2,image3, nil];
    iCarousel *icaView = [[iCarousel alloc] initWithFrame:CGRectMake(0,20, 320, 460)];
    icaView.delegate = self;
    icaView.dataSource = self;
//    icaView.type = iCarouselTypeRotary;
    icaView.pagingEnabled = YES;
    [self.view addSubview:icaView];
}

- (void)backBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel{
    if (_imageArray.count) {
        return _imageArray.count;
    }else
    {
        return 0;
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view{
    
    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
        ((UIImageView *)view).image = [_imageArray objectAtIndex:index];
        view.contentMode = UIViewContentModeScaleAspectFit;
    }
    return view;}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
