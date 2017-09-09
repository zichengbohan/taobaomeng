//
//  XBMProductInfoController.m
//  excelRever
//
//  Created by 胥佰淼 on 2016/11/13.
//  Copyright © 2016年 胥佰淼. All rights reserved.
//

#import "XBMProductInfoController.h"

@interface XBMProductInfoController ()
@property (weak, nonatomic) IBOutlet UIWebView *myWebVIew;
@property (nonatomic, copy) NSString *url;

@end

@implementation XBMProductInfoController

- (instancetype)initWithUrl:(NSString *)url {
    self = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    if (self) {
        self.url = url;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"领券购买";
    self.automaticallyAdjustsScrollViewInsets = NO;

    NSURL *url = [NSURL URLWithString:_url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.myWebVIew loadRequest:request];
    // Do any additional setup after loading the view.
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
