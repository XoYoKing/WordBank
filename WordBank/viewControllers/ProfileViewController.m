//
//  ProfileViewController.m
//  WordBank
//
//  Created by Peter on 2019/2/19.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "ProfileViewController.h"
#import "NoteBookTableViewController.h"
#import "LoginViewController.h"
#import "WordTestViewController.h"
#import <Masonry.h>
#import "SCLAlertView.h"

#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define JPVideoPlayerDemoRowHei 220
@interface ProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *infoView;
@property (weak, nonatomic) IBOutlet UIButton *testBtn;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UIButton *noteBookBtn;
@property (weak, nonatomic) IBOutlet UILabel *notebookLabel;
@property (weak, nonatomic) IBOutlet UILabel *testLabel;
@property (weak, nonatomic) IBOutlet UILabel *quitLabel;
@property (weak, nonatomic) IBOutlet UIButton *quitBtn;
@end

@implementation ProfileViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self layoutUI];
    [self masonryLayout];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPhoto)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tapGesture];
}
-(void)didTapPhoto{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user objectForKey:@"userID"]) {
        
    }else{
        [self login];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if (![user objectForKey:@"userID"]) {
        self.IDLabel.text = @"USER:尚未登录";
    }else{
        self.IDLabel.text = [NSString stringWithFormat:@"USER:%@",[user objectForKey:@"userID"]];
    }
}

#pragma Masonry Layout
-(void)masonryLayout
{
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.infoView.mas_top).with.offset(40);
        make.centerX.equalTo(self.infoView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    
    [self.IDLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).with.offset(10);
        make.centerX.equalTo(self.imageView.mas_centerX);
        make.left.equalTo(self.infoView.mas_left).with.offset(20);
        make.right.equalTo(self.infoView.mas_right).with.offset(-20);
        make.height.mas_equalTo(22);
    }];
    [self.noteBookBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.IDLabel.mas_bottom).with.offset(40);
        make.left.equalTo(self.infoView.mas_left).with.offset((self.infoView.frame.size.width - 3 * 50) / 4);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    [self.quitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.IDLabel.mas_bottom).with.offset(40);
        make.right.equalTo(self.infoView.mas_right).with.offset(-(self.infoView.frame.size.width - 3 * 50) / 4);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    [self.testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.quitBtn.mas_centerY);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(50);
    }];
    [self.infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(370);
        make.centerY.equalTo(self.view.mas_centerY);
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
    }];
    [self.notebookLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.noteBookBtn);
        make.top.equalTo(self.noteBookBtn.mas_bottom).with.offset(10);
    }];
    [self.testLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.testBtn.mas_centerX);
        make.top.equalTo(self.testBtn.mas_bottom).with.offset(10);
    }];
    [self.quitLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.quitBtn.mas_centerX);
        make.top.equalTo(self.quitBtn.mas_bottom).with.offset(10);
    }];
}




-(void)layoutUI
{
    self.imageView.layer.cornerRadius = 50;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.borderWidth = 2;
    self.imageView.layer.borderColor = RGBACOLOR(26, 59, 114, 1).CGColor;
    
    self.infoView.layer.cornerRadius = 20;
    self.infoView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.infoView.layer.shadowOpacity = 0.2;
    self.infoView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    
}
#pragma 点击词汇量测试
- (IBAction)didClickTestBtn:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"WordTestView" bundle:[NSBundle mainBundle]];
    WordTestViewController *testVC = [storyboard instantiateViewControllerWithIdentifier:@"testVC"];
    [self.navigationController pushViewController:testVC animated:YES];
}

#pragma 点击我的生词本进入 NoteBookTableView
- (IBAction)didClickNoteBookBtn:(id)sender {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user objectForKey:@"userID"]) {
        NoteBookTableViewController *noteVC = [[NoteBookTableViewController alloc] init];
        [self.navigationController pushViewController:noteVC animated:YES];
    }else{
        self.navigationController.navigationBar.hidden = YES;
        self.tabBarController.tabBar.hidden = YES;
        SCLAlertView *alert = [[SCLAlertView alloc] init];
        alert.backgroundType = SCLAlertViewBackgroundBlur;
        alert.cornerRadius = 15;
        [alert addButton:@"登录" target:self selector:@selector(login)];
        [alert showNotice:self title:@"您当前未登录" subTitle:@"是否现在登录？" closeButtonTitle:@"取消" duration:0.0f];
        [alert alertIsDismissed:^{
            self.tabBarController.tabBar.hidden = NO;
            self.navigationController.navigationBar.hidden = NO;
        }];
    }
}

-(void)login {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}

#pragma 点击退出按钮执行的操作
- (IBAction)didClickQuitBtn:(id)sender {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.cornerRadius = 15;
    if ([user objectForKey:@"userID"]) {
        [alert addButton:@"退出" target:self selector:@selector(quit)];
        [alert showWarning:self title:@"确认退出？" subTitle:@"退出之后我们依旧会为您保留您的生词本" closeButtonTitle:@"取消" duration:0.0f];
    }else{
        [alert showWarning:self title:@"错误提示" subTitle:@"您当前并未登录哦" closeButtonTitle:@"取消" duration:0.0f];
    }
    [alert alertIsDismissed:^{
        self.tabBarController.tabBar.hidden = NO;
        self.navigationController.navigationBar.hidden = NO;
    }];
}
-(void)quit{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:@"userID"];
    self.IDLabel.text = @"USER:尚未登录";
}
@end
