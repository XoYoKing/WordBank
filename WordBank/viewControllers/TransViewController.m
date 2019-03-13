//
//  TransViewController.m
//  WordBank
//
//  Created by Peter on 2019/2/23.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "TransViewController.h"
#import "NoteBookTableViewCell.h"
#import "WordModel.h"
#import <BmobSDK/Bmob.h>
#import <Masonry.h>

#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
@interface TransViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (nonatomic, strong) NSDictionary *wordDataSource;
@property (nonatomic, strong) NSDictionary *rawWordDataSource;
@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) UILabel *label;
@end

@implementation TransViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.searchBtn addTarget:self action:@selector(didClickSearchBtn) forControlEvents:UIControlEventTouchUpInside];
    [self layoutUI];
    
}
-(NSArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}
-(void)layoutUI
{
    self.searchView.layer.cornerRadius = 20;
    self.searchView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.searchView.layer.shadowOpacity = 0.2;
    self.searchView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.delegate = self;
    
    self.backView.layer.cornerRadius = 20;
    self.tableView.clipsToBounds = YES;
    self.backView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.backView.layer.shadowOpacity = 0.2;
    self.backView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    self.tableView .separatorStyle = UITableViewCellEditingStyleNone;
    self.textField.borderStyle = UITextBorderStyleNone;
    [self masonryLayout];
}
-(void)masonryLayout
{
    self.backView.layer.opacity = 0;
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.left.equalTo(self.view.mas_left).with.offset(30);
        make.right.equalTo(self.view.mas_right).with.offset(-30);
        make.height.mas_equalTo(40);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.searchView.mas_centerY);
        make.left.equalTo(self.searchView.mas_left).with.offset(20);
        make.height.mas_equalTo(30);
        make.right.equalTo(self.searchBtn.mas_left).with.offset(-20);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(30);
        make.right.equalTo(self.searchView.mas_right).with.offset(-8);
        make.centerY.equalTo(self.searchView.mas_centerY);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backView.mas_top).with.offset(10);
        make.left.equalTo(self.backView.mas_left).with.offset(10);
        make.right.equalTo(self.backView.mas_right).with.offset(-10);
        make.bottom.equalTo(self.backView.mas_bottom).with.offset(-10);
    }];
    
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.top.equalTo(self.searchView.mas_bottom).with.offset(20);
        make.bottom.mas_equalTo(-([self kTabbarHeight] + 20));
    }];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteBookTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"noteCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NoteBookTableViewCell" owner:nil options:nil] lastObject];
    }
    WordModel *model = self.dataArray[indexPath.row];
    cell.kanaLabel.text = model.kana;
    cell.sampleLabel.text = model.sample;
    cell.jpWordLabel.text = model.jpword;
    cell.meanLabel.text = model.mean;
    return cell;
}

-(void)didClickSearchBtn
{
    [self.tableView reloadData];
    if ([self.textField.text isEqualToString:@""]) {
        [self showNoResult:@"请输入假名以搜索"];
    }else{
        [self.textField resignFirstResponder];
        __block NSMutableArray *mutalArray = [NSMutableArray array];
        BmobQuery* query = [BmobQuery queryWithClassName:@"wordAll"];
        [query whereKey:@"kana_adition" equalTo:self.textField.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            NSLog(@"%lu",(unsigned long)array.count);
            for (BmobObject *obj in array) {
                WordModel *model = [[WordModel alloc] init];
                model.sample = [obj objectForKey:@"sample"];
                model.mean = [obj objectForKey:@"mean"];
                model.kana = [obj objectForKey:@"kana_adition"];
                model.jpword = [obj objectForKey:@"jpword"];
                [mutalArray addObject:model];
            }
            self.dataArray = mutalArray;
            [self.tableView reloadData];
            NSLog(@")(%@",self.dataArray);
            if (mutalArray.count == 0) {
                [self showNoResult:@"未搜索到结果"];
            }
        }];
    }
}
-(void)showNoResult:(NSString *)result
{
    self.label = [[UILabel alloc] init];
    self.label.text = result;
    self.label.font = [UIFont systemFontOfSize:20];
    self.label.textAlignment = NSTextAlignmentCenter;;
    self.label.textColor = [UIColor lightGrayColor];
    [self.tableView addSubview:self.label];
    
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.tableView.mas_centerX);
        make.centerY.equalTo(self.tableView.mas_centerY);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(200);
    }];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.label.hidden = YES;
    self.dataArray = @[];
    [self.view setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.5 animations:^{
        [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top).with.offset([self kStatusBarHeight] + [self kNavigationBarHeight] + 20);
            make.left.equalTo(self.view.mas_left).with.offset(30);
            make.right.equalTo(self.view.mas_right).with.offset(-30);
            make.height.mas_equalTo(40);
        }];
        self.backView.layer.opacity = 1;
        [self.searchView.superview layoutIfNeeded];
    }];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self didClickSearchBtn];
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.textField.text isEqualToString:@""]) {
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.5 animations:^{
            [self.searchView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.view.mas_centerY);
                make.left.equalTo(self.view.mas_left).with.offset(30);
                make.right.equalTo(self.view.mas_right).with.offset(-30);
                make.height.mas_equalTo(40);
            }];
            self.backView.layer.opacity = 0;
            [self.searchView.superview layoutIfNeeded];
        }];
    }
    [self.textField resignFirstResponder];
}

//返回TabBar高度
-(float)kTabbarHeight{
    return self.tabBarController.tabBar.bounds.size.height;
}
//返回NavigationBar高度
-(float)kNavigationBarHeight{
    return self.navigationController.navigationBar.bounds.size.height;
}
//返回StatusBar高度
-(float)kStatusBarHeight{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}
@end
