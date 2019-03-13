//
//  DictViewController.m
//  WordBank
//
//  Created by Peter on 2019/2/19.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "DictViewController.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFNetworking.h"
#import <Masonry.h>

#define kBaiduTranslationAPPID @"20190215000267267"
#define kBaiduTranslationSalt @"20"
#define kBaiduTranslationKey @"txAIm3A6YEFM1545REt7"
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@interface DictViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (strong, nonatomic) UITextView *inputTextView;
@property (strong, nonatomic) UITextView *outputTextView;
@property (weak, nonatomic) IBOutlet UIView *inputView;
@property (weak, nonatomic) IBOutlet UIView *outputView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *chineseBtn;
@property (weak, nonatomic) IBOutlet UIButton *japaneseBtn;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (nonatomic, strong) NSString *fromLanguage;
@property (nonatomic, strong) NSString *toLanguage;

@end

@implementation DictViewController

- (void)viewDidLoad {
    //默认中译日
    _fromLanguage = @"zh";
    _toLanguage = @"jp";
    
    [super viewDidLoad];
    [self layoutUI];
    [self masonryLayout];
}

# pragma 初始化UI界面
-(void)layoutUI
{
    self.clearBtn.hidden = YES;
    
//    self.japaneseBtn.layer.cornerRadius = 10;
    self.japaneseBtn.userInteractionEnabled = NO;
    self.japaneseBtn.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.japaneseBtn.layer.shadowOpacity = 0.2;
    self.japaneseBtn.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
//    self.chineseBtn.layer.cornerRadius = 10;
    self.chineseBtn.userInteractionEnabled = NO;
    self.chineseBtn.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.chineseBtn.layer.shadowOpacity = 0.2;
    self.chineseBtn.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    self.chineseBtn.userInteractionEnabled = NO;
    
    self.exchangeBtn.layer.cornerRadius = 17.5;
    self.exchangeBtn.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.exchangeBtn.layer.shadowOpacity = 0.2;
    self.exchangeBtn.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    
    _inputTextView = [[UITextView alloc] init];
    _inputTextView.font = [UIFont systemFontOfSize:18];
    _inputTextView.layer.cornerRadius = 20;
    _inputTextView.delegate = self;
    _inputTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _inputTextView.backgroundColor = [UIColor clearColor];
    self.inputView.layer.cornerRadius = 20;
    self.inputView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.inputView.layer.shadowOpacity = 0.2;
    self.inputView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    [self.inputView addSubview:_inputTextView];
    
    _outputTextView = [[UITextView alloc] init];
    _outputTextView.font = [UIFont systemFontOfSize:18];
    _outputTextView.layer.cornerRadius = 20;
    _outputTextView.delegate = self;
    _outputTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.outputView.layer.cornerRadius = 20;
//    self.outputView.layer.masksToBounds = YES;
    self.outputView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.outputView.layer.shadowOpacity = 0.2;
    self.outputView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    [self.outputView addSubview:_outputTextView];
    
//    self.outputView.hidden = YES;
    self.outputView.alpha = 0;
    [self.outputTextView setEditable:NO];
}

# pragma Masonry 布局
-(void)masonryLayout
{
    [self.exchangeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerView.mas_centerX);
        make.centerY.equalTo(self.headerView.mas_centerY);
        make.height.mas_equalTo(35);
        make.width.mas_equalTo(35);
    }];
    
    [self.japaneseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.exchangeBtn.mas_centerY);
        make.right.mas_equalTo(self.headerView.mas_right).with.offset(-10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
    
    [self.chineseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.exchangeBtn.mas_centerY);
        make.left.mas_equalTo(self.headerView.mas_left).with.offset(10);
        make.height.mas_equalTo(30);
        make.width.mas_equalTo(50);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset([self kNavigationBarHeight] + [self kStatusBarHeight] + 20);
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.mas_equalTo([UIScreen mainScreen].bounds.size.height * 0.3);
    }];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputView.mas_bottom).with.offset(5);
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.height.mas_equalTo(40);
    }];

    [self.outputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).with.offset(10);
        make.right.equalTo(self.view.mas_right).with.offset(-10);
        make.top.equalTo(self.headerView.mas_bottom).with.offset(5);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-([self kTabbarHeight] + 20));
    }];
    [_inputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.inputView.mas_left).with.offset(10);
        make.right.equalTo(self.inputView.mas_right).with.offset(-10);
        make.top.equalTo(self.inputView.mas_top).with.offset(10);
        make.bottom.equalTo(self.inputView.mas_bottom).with.offset(-10);
    }];
    [_outputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.outputView.mas_left).with.offset(10);
        make.right.equalTo(self.outputView.mas_right).with.offset(-10);
        make.top.equalTo(self.outputView.mas_top).with.offset(10);
        make.bottom.equalTo(self.outputView.mas_bottom).with.offset(-10);
    }];
    
    [self.clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(20);
        make.right.equalTo(self.inputView.mas_right).with.offset(-10);
        make.bottom.equalTo(self.inputView.mas_bottom).with.offset(-10);
    }];
}

# pragma http 请求
-(void)TransStr:(NSString *) str FromLanguage:(NSString *)fLanguage ToLanguage:(NSString *)Tlanguage
{
    if (str == nil || str.length ==0) {
    return;
 }
    //百度API
    NSString *httpStr = @"https://fanyi-api.baidu.com/api/trans/vip/translate";
    
    //将APPID q salt key 拼接一起
    NSString *appendStr = [NSString stringWithFormat:@"%@%@%@%@",kBaiduTranslationAPPID,self.inputTextView.text,kBaiduTranslationSalt,kBaiduTranslationKey];

    NSString *appendEncoding = [appendStr stringByRemovingPercentEncoding];

    //加密 生成签名
    NSLog(@"%@",appendEncoding);
    NSString *md5Str = [self md5:appendEncoding];

    //将待翻译的文字机型urf-8转码
    NSString *qEncoding = [self.inputTextView.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    //使用get请求
    NSString *urlStr = [NSString stringWithFormat:@"%@?q=%@&from=%@&to=%@&appid=%@&salt=%@&sign=%@",httpStr,qEncoding,fLanguage,Tlanguage,kBaiduTranslationAPPID,kBaiduTranslationSalt,md5Str];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //添加共有参数
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    manager.requestSerializer.timeoutInterval = 20.f;
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    [manager GET:urlStr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject == nil) {
            return ;
        }
        //获取翻译后的字符串
        NSString *resStr = [[responseObject objectForKey:@"trans_result"] firstObject][@"dst"];
        self.outputTextView.text = resStr;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.outputTextView.text = @"网络错误，请重试！";
    }];
}

# pragma MD5加密
- (NSString *) md5:(NSString *) str{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

# pragma mark - UITextView Delegate Methods
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"按下回车");
        if ([_inputTextView.text isEqualToString:@""]) {
            return NO;
        }else{
            [self TransStr:self.inputTextView.text FromLanguage:_fromLanguage ToLanguage:_toLanguage];
//            [self TransStr:self.inputTextView.text ToLanguage:_toLanguage];
            [textView resignFirstResponder];
            [UIView animateWithDuration:0.5 animations:^{
                self.outputView.alpha = 1;
            }];
            return NO;
        }
    }else{
        self.outputView.alpha = 0;
    }
    
    if (text) {
        self.clearBtn.hidden = NO;
    }
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.inputTextView resignFirstResponder];
}

# pragma 清楚输入框内容
- (IBAction)didClickClearBtn:(id)sender {
    [_inputTextView setText:@""];
    self.clearBtn.hidden = YES;
    _outputTextView.text = @"";
    [UIView animateWithDuration:0.5 animations:^{
        self.outputView.alpha = 0;
    }];
}

# pragma 点击交换 中译日 -> 日译中
- (IBAction)didClickExchangeBtn:(id)sender {
    if ([_fromLanguage isEqualToString:@"zh"] && [_toLanguage isEqualToString:@"jp"]) {
        self.chineseBtn.titleLabel.text = @"日语";
        self.japaneseBtn.titleLabel.text = @"中文";
        _toLanguage = @"zh";
        _fromLanguage = @"jp";
    }else if ([_fromLanguage isEqualToString:@"jp"] && [_toLanguage isEqualToString:@"zh"]){
        self.chineseBtn.titleLabel.text = @"中文";
        self.japaneseBtn.titleLabel.text = @"日语";
        _toLanguage = @"jp";
        _fromLanguage = @"zh";
    }else{
        return;
    }
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
