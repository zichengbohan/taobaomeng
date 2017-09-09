//
//  ViewController.m
//  excelRever
//
//  Created by 胥佰淼 on 2016/11/13.
//  Copyright © 2016年 胥佰淼. All rights reserved.
//

#import "ViewController.h"
#import <XlsxReaderWriter/XlsxReaderWriter-swift-bridge.h>
#import "XBMProductModel.h"
#import "XBMCouponProCell.h"
#import "XBMProductInfoController.h"
#import <AFNetworking/AFNetworking.h>
#import "NSArray+CustomMethod.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <MJRefresh/MJRefresh.h>

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableVIew;
@property (nonatomic, strong) NSMutableArray *InfoArray;
@property (weak, nonatomic) IBOutlet UISearchBar *mySearchBar;
@property (nonnull, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (nonatomic, strong) NSArray *pickerArray;
@property (nonatomic, strong) UIPickerView *myPicker;
@property (nonatomic, strong) UIView *pickerBgView;
@property (nonatomic, strong) UIView *pickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"首页";
    self.mySearchBar.delegate = self;
    self.myTableVIew.dataSource = self;
    self.myTableVIew.delegate = self;
    self.myTableVIew.tableFooterView=[[UIView alloc] init];
    self.automaticallyAdjustsScrollViewInsets = NO;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self reverexcel];
    });
    
    self.myTableVIew.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //Call this Block When enter the refresh status automatically
        [self download];
    }];
    
    [self createPicke];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)reverexcel {
    [SVProgressHUD showWithStatus:@"正在获取数据..."];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    _InfoArray=[[NSMutableArray alloc]init];
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateStyle:NSDateFormatterMediumStyle];
    [formatter1 setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr1 = [formatter1 stringFromDate:now];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    docDir = [docDir stringByAppendingString:[NSString stringWithFormat:@"/%@poducrList.xlsx", dateStr1]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [self.myTableVIew.header endRefreshing];

//    if([fileManager fileExistsAtPath:docDir]) {
        docDir = [[NSBundle mainBundle] pathForResource:@"poducrList" ofType:@"xlsx"];
        BRAOfficeDocumentPackage *spreadsheet = [BRAOfficeDocumentPackage open:docDir];
        BRAWorksheet *firstWorksheet = spreadsheet.workbook.worksheets[0];
        if (firstWorksheet == nil) {
            [fileManager removeItemAtPath:docDir error:NULL];
//            [self download];
            [SVProgressHUD showErrorWithStatus:@"没有获取到数据，请稍后重试"];
            return;
        }
        NSArray *rows = firstWorksheet.rows;
        int i = 0;
        for (BRARow *row in rows) {
            if (i != 0) {
                //            if (i < 100) {
                XBMProductModel *model = [[XBMProductModel alloc] init];
                model.proName = [row.cells[1] stringValue];
                model.imgUrl = [row.cells[2] stringValue];
                model.proUrl = [row.cells[21] stringValue];
                model.proCouponInfo = [row.cells[17] stringValue];
                model.price = [row.cells[6] stringValue];
                model.type = [row.cells[13] stringValue];
                [_InfoArray addObject:model];
                
                //            } else {
                //                break;
                //            }
            }
            i++;
        }
        firstWorksheet = nil;
        NSLog(@"infoArray:%@", _InfoArray);
        _dataArray = _InfoArray;
        [_myTableVIew reloadData];
//    }

}

- (void)download {
    
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    [formatter1 setDateStyle:NSDateFormatterMediumStyle];
    [formatter1 setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr1 = [formatter1 stringFromDate:now];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    docDir = [docDir stringByAppendingString:[NSString stringWithFormat:@"/%@poducrList.xlsx", dateStr1]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDateComponents *resultComps = [[NSDateComponents alloc] init];
    
    if([fileManager fileExistsAtPath:docDir] || [resultComps hour] <= 10) //如果存在
    {
        [self reverexcel];
        return;
    }

    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString: [NSString stringWithFormat:@"http://www.xubaimiao.com/uploads/%@poducrList.xlsx", dateStr1]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    __weak typeof(self) weakSelf = self;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
//        docDir = [docDir stringByAppendingString:[NSString stringWithFormat:@"/poducrList.xlsx"]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *extension = @"xlsx";
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:docDir error:NULL];
        NSEnumerator *e = [contents objectEnumerator];
        NSString *filename;
        while ((filename = [e nextObject])) {
            
            if ([[filename pathExtension] isEqualToString:extension]) {
                
                [fileManager removeItemAtPath:[docDir stringByAppendingPathComponent:filename] error:NULL];
            }
        }
        
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        [weakSelf reverexcel];
        
        NSLog(@"File downloaded to: %@", filePath);
    }];
    [downloadTask resume];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD dismiss];

    static NSString *cellStr = @"ProCell";
    XBMCouponProCell *cell = [tableView dequeueReusableCellWithIdentifier:cellStr];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"XBMCouponProCell" owner:self options:nil].firstObject;
    }
    [cell setInfoSHow:_dataArray[indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    XBMProductInfoController *vc = [[XBMProductInfoController alloc] initWithUrl:((XBMProductModel *)_dataArray[indexPath.row]).proUrl];
    [self.navigationController pushViewController:vc animated:YES];
    [self.view endEditing:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [XBMCouponProCell cellHeight:_dataArray[indexPath.row]];
}

#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *searchStr = searchBar.text;
    _dataArray = [_InfoArray searchArrayWithStr:searchStr type:self.selectButton.titleLabel.text];
    [self.myTableVIew reloadData];
    [self.view endEditing:YES];
}
- (IBAction)selectButtonCliced:(id)sender {
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = [UIScreen mainScreen].bounds;
        self.self.pickerView.frame = CGRectMake(0, frame.size.height - 130, frame.size.width, 130);
        self.pickerBgView.hidden = NO;
    }];
}

- (void)createPicke {
    CGRect frame = [UIScreen mainScreen].bounds ;
    
    self.pickerBgView = [[UIView alloc] initWithFrame:frame];
    self.pickerBgView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    self.pickerArray = @[@"全部", @"淘宝", @"天猫"];
    self.myPicker = [[UIPickerView alloc] init];
    
    self.myPicker.frame = CGRectMake(0,31, frame.size.width, 100);
    self.myPicker.backgroundColor = [UIColor whiteColor];
    self.myPicker.dataSource = self;
    self.myPicker.delegate = self;
    self.myPicker.showsSelectionIndicator = YES;
//    [self.pickerBgView addSubview:self.myPicker];
    self.pickerBgView.hidden = YES;
    
    UIButton *headerButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 80, 0, 80, 30)];
    [headerButton setTitle:@"确定" forState:UIControlStateNormal];
    [headerButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [headerButton addTarget:self action:@selector(pickerSure:) forControlEvents:UIControlEventTouchUpInside];
    [headerButton setBackgroundColor:[UIColor whiteColor]];

    
    self.pickerView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, 130)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    [self.pickerView addSubview:headerButton];
    [self.pickerView addSubview:self.myPicker];
    
    [self.pickerBgView addSubview:self.pickerView];
    
    [self.view addSubview:self.pickerBgView];
}

- (void)pickerSure:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frame = [UIScreen mainScreen].bounds;
        self.self.pickerView.frame = CGRectMake(0, frame.size.height, frame.size.width, 130);
    } completion:^(BOOL finished) {
        self.pickerBgView.hidden = YES;
    }];
}

#pragma mark - Picker View Data source

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerArray count];
}

#pragma mark- Picker View Delegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:
(NSInteger)row inComponent:(NSInteger)component{
    self.selectButton.titleLabel.text = [self.pickerArray objectAtIndex:row];
    _dataArray =  [_InfoArray searchArrayWithStr:self.mySearchBar.text type:[self.pickerArray objectAtIndex:row]];
    [self.myTableVIew reloadData];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:
(NSInteger)row forComponent:(NSInteger)component{
    return [self.pickerArray objectAtIndex:row];
}

@end
