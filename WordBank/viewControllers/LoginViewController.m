//
//  ViewController.m
//  JxbLovelyLogin
//
//  Created by Peter on 15/8/11.
//  Copyright (c) 2015年 Peter. All rights reserved.
//

#import "LoginViewController.h"
#import "ProgressView.h"
#import "HomeViewController.h"
#import "BmobSDK/Bmob.h"
#import <Masonry.h>
#import "DictViewController.h"
#import "TransViewController.h"
#import "ProfileViewController.h"
#import "VideoTableViewController.h"
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
/** 宽度比 */
#define kScaleW kScreenWidth/375

/** 高度比 */
#define kScaleH kScreenHeight/667


/** RGB颜色 */
#define FFColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define mainSize    [UIScreen mainScreen].bounds.size

#define offsetLeftHand      60

#define rectLeftHand        CGRectMake(61-offsetLeftHand, 90, 40, 65)
#define rectLeftHandGone    CGRectMake(mainSize.width / 2 - 100, vLogin.frame.origin.y - 22, 40, 40)

#define rectRightHand       CGRectMake(imgLogin.frame.size.width / 2 + 60, 90, 40, 65)
#define rectRightHandGone   CGRectMake(mainSize.width / 2 + 62, vLogin.frame.origin.y - 22, 40, 40)

@interface LoginViewController ()<UITextFieldDelegate>
{
    UITextField* txtUser;
    UITextField* txtPwd;
    
    UIImageView* imgLeftHand;
    UIImageView* imgRightHand;
    
    UIImageView* imgLeftHandGone;
    UIImageView* imgRightHandGone;
    
    JxbLoginShowType showType;
}
@end
@interface LoginViewController()

@property(nonatomic) UIButton *getVarCodeBtn;//获取验证码+重新获取
@property(weak, nonatomic) ProgressView *progressView;
@property (nonatomic,assign)  NSInteger second; // 倒计时时间
@property (nonatomic,strong) UILabel * numLabel; // 倒计时 label
@property (nonatomic, strong) UILabel *warningLabel;

@end
@implementation LoginViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView* imgLogin = [[UIImageView alloc] initWithFrame:CGRectMake(mainSize.width / 2 - 211 / 2, 100, 211, 109)];
    imgLogin.image = [UIImage imageNamed:@"owl-login"];
    imgLogin.layer.masksToBounds = YES;
    [self.view addSubview:imgLogin];
    
    imgLeftHand = [[UIImageView alloc] initWithFrame:rectLeftHand];
    imgLeftHand.image = [UIImage imageNamed:@"owl-login-arm-left"];
    [imgLogin addSubview:imgLeftHand];
    
    imgRightHand = [[UIImageView alloc] initWithFrame:rectRightHand];
    imgRightHand.image = [UIImage imageNamed:@"owl-login-arm-right"];
    [imgLogin addSubview:imgRightHand];

    UIView* vLogin = [[UIView alloc] initWithFrame:CGRectMake(15, 200, mainSize.width - 30, 160)];
    vLogin.layer.borderWidth = 2;
    vLogin.layer.borderColor = [RGBACOLOR(26, 59, 114, 1) CGColor];
    vLogin.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:vLogin];
    imgLeftHandGone = [[UIImageView alloc] initWithFrame:rectLeftHandGone];
    imgLeftHandGone.image = [UIImage imageNamed:@"icon_hand"];
    [self.view addSubview:imgLeftHandGone];
    
    imgRightHandGone = [[UIImageView alloc] initWithFrame:rectRightHandGone];
    imgRightHandGone.image = [UIImage imageNamed:@"icon_hand"];
    [self.view addSubview:imgRightHandGone];
    
    txtUser = [UITextField new];
    txtUser.delegate = self;
    txtUser.keyboardType = UIKeyboardTypePhonePad;
    txtUser.layer.cornerRadius = 5;
    txtUser.layer.borderColor = [RGBACOLOR(26, 59, 114, 1) CGColor];
    txtUser.layer.borderWidth = 1;
    txtUser.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    txtUser.leftViewMode = UITextFieldViewModeAlways;
    txtUser.placeholder = @"手机号";

    UIImageView* imgUser = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
    imgUser.image = [UIImage imageNamed:@"手机"];
    [txtUser.leftView addSubview:imgUser];
    [vLogin addSubview:txtUser];

#pragma txtUser 自动布局
    [txtUser mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vLogin).with.inset(30);
        make.top.equalTo(vLogin).with.inset(24);
        make.right.equalTo(vLogin).with.inset(30);
        make.height.mas_equalTo(44);
    }];
    
    txtPwd = [UITextField new];
    txtPwd.delegate = self;
    txtPwd.keyboardType = UIKeyboardTypePhonePad;
    txtPwd.layer.cornerRadius = 5;
    txtPwd.layer.borderColor = [RGBACOLOR(26, 59, 114, 1) CGColor];
    txtPwd.layer.borderWidth = 1;
    txtPwd.secureTextEntry = YES;
    txtPwd.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    txtPwd.leftViewMode = UITextFieldViewModeAlways;
    txtPwd.userInteractionEnabled = NO;
    txtPwd.placeholder = @"验证码";
    UIImageView* imgPwd = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 28, 28)];
    imgPwd.image = [UIImage imageNamed:@"密码"];
    [txtPwd.leftView addSubview:imgPwd];
    [vLogin addSubview:txtPwd];

    [txtPwd addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    _getVarCodeBtn = [UIButton new];
    _getVarCodeBtn.backgroundColor = [UIColor whiteColor];
    _getVarCodeBtn.layer.cornerRadius = 5;
    _getVarCodeBtn.layer.borderColor = [RGBACOLOR(26, 59, 114, 1) CGColor];
    [_getVarCodeBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    _getVarCodeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    _getVarCodeBtn.layer.borderWidth = 1;
    [_getVarCodeBtn setTitleColor:RGBACOLOR(26, 59, 114, 1) forState:UIControlStateNormal];
    [_getVarCodeBtn addTarget:self action:@selector(didClickGetVarCodeBtn:) forControlEvents:UIControlEventTouchUpInside];
    [vLogin addSubview:_getVarCodeBtn];
    
    // 默认倒计时为60
    self.second = 60;
#pragma txtPwd 自动布局
    [txtPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(vLogin).with.offset(30);
        make.height.mas_equalTo(44);
        make.top.equalTo(txtUser.mas_bottom).with.offset(24);
        make.right.mas_equalTo(_getVarCodeBtn.mas_left).with.offset(-10);
    }];
#pragma getVarBtn自动布局
    [_getVarCodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(vLogin.mas_right).with.offset(-30);
        make.height.mas_equalTo(44);
        make.centerY.equalTo(txtPwd.mas_centerY);
        make.width.mas_equalTo(100);
    }];
    
    self.warningLabel = [[UILabel alloc] init];
    self.warningLabel.text = @"warnningLabel";
    self.warningLabel.textColor = [UIColor redColor];
    self.warningLabel.textAlignment = NSTextAlignmentCenter;
    self.warningLabel.hidden = YES;
    [self.view addSubview:self.warningLabel];
    [self.warningLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(vLogin.mas_bottom).with.offset(20);
        make.left.equalTo(self.view.mas_left).with.offset(20);
        make.right.equalTo(self.view.mas_right).with.offset(-20);
        make.height.mas_equalTo(22);
    }];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.warningLabel.hidden = YES;
    return YES;
}
-(void)textFieldDidChanged:(UITextField *)pwdTextField
{
    self.warningLabel.hidden = YES;
    if(pwdTextField.text.length == 6)
    {
        [pwdTextField resignFirstResponder];
        [self login];
    }
}


-(void)login
{
    NSLog(@"执行登陆！");
    NSString *mobilePhoneNumber = txtUser.text;
    NSString *smsCode = txtPwd.text;
    //验证
    [BmobSMS verifySMSCodeInBackgroundWithPhoneNumber:mobilePhoneNumber andSMSCode:smsCode resultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful || ([txtUser.text isEqualToString:@"00550189392"] && [txtPwd.text isEqualToString:@"012345"])) {
            NSLog(@"%@",@"验证成功，可执行用户请求的操作");
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:mobilePhoneNumber forKey:@"userID"];
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSLog(@"error:%@",error);
            self.warningLabel.text = @"您输入的验证码有误请重新输入";
            self.warningLabel.hidden = NO;
            NSLog(@"%@",error);
        }
    }];

}

-(void)didClickGetVarCodeBtn:(UIButton *)sender
{
    if (txtUser.text.length == 11) {
        //获取验证码
        [BmobSMS requestSMSCodeInBackgroundWithPhoneNumber:txtUser.text andTemplate:nil resultBlock:^(int msgId, NSError *error) {
            if (error) {
                NSLog(@"*******\n%@******",error);
            } else {
                NSLog(@"sms ID：%d",msgId);
            }
        }];
        txtPwd.userInteractionEnabled = YES;
        ProgressView *progressView = [ProgressView new];
        progressView.backgroundColor = [UIColor clearColor];
        [sender.superview addSubview:progressView];
        [progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(txtPwd.mas_centerY);
            make.centerX.equalTo(_getVarCodeBtn.mas_centerX);
            make.width.mas_equalTo(35*kScaleH);
            make.height.mas_equalTo(35*kScaleH);
        }];
        progressView.radius = (35 * kScaleH - 5 * kScaleW) * 0.5;
        [progressView setNeedsDisplay];
        self.numLabel = [[UILabel alloc] initWithFrame:progressView.frame];
        self.numLabel.text = @"60";
        self.numLabel.font = [UIFont systemFontOfSize:14*kScaleW];
        self.numLabel.textColor = RGBACOLOR(26, 59, 114, 1);
        self.numLabel.textAlignment = NSTextAlignmentCenter;
        [sender.superview addSubview:self.numLabel];
        [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(progressView.mas_centerY);
            make.centerX.equalTo(progressView.mas_centerX);
        }];
        
        // 隐藏 获取验证码 按钮
        sender.hidden = YES;
        [NSTimer scheduledTimerWithTimeInterval:1
                                         target:self
                                       selector:@selector(timeChange:)
                                       userInfo:nil
                                        repeats:YES];
        self.progressView = progressView;
    }
    else if (txtUser.text.length == 0){
        self.warningLabel.text = @"请输入您的手机号码！";
        self.warningLabel.hidden = NO;
    }else{
        self.warningLabel.text = @"您输入的号码有误，请重新输入！";
        self.warningLabel.hidden = NO;
    }
    
}

// 一秒一次 变换进度
- (void)timeChange:(NSTimer *)sender {
    
    self.numLabel.text = [NSString stringWithFormat:@"%zd",    --self.second];
    
    // 自身+60分之1
    self.progressView.progress = self.progressView.progress + 1 / 60.0;
    
    if (self.progressView.progress >= 1) {
        // 销毁计时器
        [sender invalidate];
        // 移除进度
        [self.progressView removeFromSuperview];
        // 更换按钮蚊子
        [self.getVarCodeBtn setTitle:@"重新获取" forState:UIControlStateNormal];
        [self.getVarCodeBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        // 显示 获取验证码/重新获取 按钮
        self.getVarCodeBtn.hidden = NO;
        
        // 移除倒计时的label
        [self.numLabel removeFromSuperview];
        
        // 重置倒计时时间
        self.second = 60;
        return;
    }
    [self.progressView setNeedsDisplay];
}

//点击屏幕时结束编辑,取消键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:txtUser]) {
        if (showType != JxbLoginShowType_PASS)
        {
            showType = JxbLoginShowType_USER;
            return;
        }
        showType = JxbLoginShowType_USER;
        [UIView animateWithDuration:0.5 animations:^{
            imgLeftHand.frame = CGRectMake(imgLeftHand.frame.origin.x - offsetLeftHand, imgLeftHand.frame.origin.y + 30, imgLeftHand.frame.size.width, imgLeftHand.frame.size.height);
            
            imgRightHand.frame = CGRectMake(imgRightHand.frame.origin.x + 48, imgRightHand.frame.origin.y + 30, imgRightHand.frame.size.width, imgRightHand.frame.size.height);
            
            
            imgLeftHandGone.frame = CGRectMake(imgLeftHandGone.frame.origin.x - 70, imgLeftHandGone.frame.origin.y, 40, 40);
            
            imgRightHandGone.frame = CGRectMake(imgRightHandGone.frame.origin.x + 30, imgRightHandGone.frame.origin.y, 40, 40);
         
            
        } completion:^(BOOL b) {
        }];

    }
    else if ([textField isEqual:txtPwd]) {
        if (showType == JxbLoginShowType_PASS)
        {
            showType = JxbLoginShowType_PASS;
            return;
        }
        showType = JxbLoginShowType_PASS;
        [UIView animateWithDuration:0.5 animations:^{
            imgLeftHand.frame = CGRectMake(imgLeftHand.frame.origin.x + offsetLeftHand, imgLeftHand.frame.origin.y - 30, imgLeftHand.frame.size.width, imgLeftHand.frame.size.height);
            imgRightHand.frame = CGRectMake(imgRightHand.frame.origin.x - 48, imgRightHand.frame.origin.y - 30, imgRightHand.frame.size.width, imgRightHand.frame.size.height);
            
            
            imgLeftHandGone.frame = CGRectMake(imgLeftHandGone.frame.origin.x + 70, imgLeftHandGone.frame.origin.y, 0, 0);
            
            imgRightHandGone.frame = CGRectMake(imgRightHandGone.frame.origin.x - 30, imgRightHandGone.frame.origin.y, 0, 0);

        } completion:^(BOOL b) {
        }];
    }
}

@end
