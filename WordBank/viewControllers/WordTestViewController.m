//
//  WordTestViewController.m
//  WordBank
//
//  Created by Peter on 2019/2/27.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "WordTestViewController.h"
#import <BmobSDK/Bmob.h>
#import <Masonry.h>
#import "XLPaymentLoadingHUD.h"
#import "XLPaymentSuccessHUD.h"
#import "SCLAlertView.h"

#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
@interface WordTestViewController ()
{
    int numberOfQues;
    int score;
}
@property (strong, nonatomic) IBOutlet UIView *testView;
@property (strong, nonatomic) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *choiceA;
@property (weak, nonatomic) IBOutlet UILabel *choiceB;
@property (weak, nonatomic) IBOutlet UILabel *choiceC;
@property (weak, nonatomic) IBOutlet UILabel *choiceD;
@property (weak, nonatomic) IBOutlet UILabel *dontKnowLabel;
@property (strong, nonatomic) UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end

@implementation WordTestViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    numberOfQues = 0;
    score = 0;
    [self addStartTestBtn];
    self.testView.hidden = YES;
    self.countLabel.hidden = YES;
    [self layoutUI];
    [self configDataWithClas:@"N4"];
    [self configDataWithClas:@"N3"];
    [self configDataWithClas:@"N2"];
    [self configDataWithClas:@"N1"];
#pragma 为label添加点击事件
    UITapGestureRecognizer *labelTapGestureRecognizer_1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickChoiceALabel)];
    UITapGestureRecognizer *labelTapGestureRecognizer_2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickChoiceBLabel)];
    UITapGestureRecognizer *labelTapGestureRecognizer_3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickChoiceCLabel)];
    UITapGestureRecognizer *labelTapGestureRecognizer_4 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickChoiceDLabel)];
    UITapGestureRecognizer *labelTapGestureRecognizer_5 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickDontKnowLabel)];
    
    [self.choiceA addGestureRecognizer:labelTapGestureRecognizer_1];
    [self.choiceB addGestureRecognizer:labelTapGestureRecognizer_2];
    [self.choiceC addGestureRecognizer:labelTapGestureRecognizer_3];
    [self.choiceD addGestureRecognizer:labelTapGestureRecognizer_4];
    [self.dontKnowLabel addGestureRecognizer:labelTapGestureRecognizer_5];
    
}

#pragma 添加一个开始测试的按钮
-(void)addStartTestBtn
{
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"开始测试"];
    [self.startBtn setTitleColor:RGBACOLOR(26, 59, 114, 1) forState:UIControlStateNormal];
    
    [self.startBtn setAttributedTitle:str forState:UIControlStateNormal];
    self.startBtn.layer.cornerRadius = 25;
    self.startBtn.backgroundColor = [UIColor whiteColor];
    self.startBtn.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.startBtn.layer.shadowOpacity = 0.2;
    self.startBtn.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    [self.startBtn addTarget:self action:@selector(didClickStartBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.startBtn];
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.width.mas_equalTo(200);
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
}

-(void)didClickStartBtn
{
    self.testView.hidden = NO;
    self.startBtn.hidden = YES;
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = pathArray[0];
    NSString *filePathName = [cachePath stringByAppendingPathComponent:@"data.plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePathName];
    self.dataArray = array;
    array = @[];
    [array writeToFile:filePathName atomically:YES];
    [self layouTestView];
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
    self.testView.layer.cornerRadius = 20;
    self.testView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.testView.layer.shadowOpacity = 0.3;
    self.testView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
}

-(void)configDataWithClas:(NSString *)class
{
    BmobQuery* query = [BmobQuery queryWithClassName:@"wordTest"];
    [query whereKey:@"class" equalTo:class];
    [query setLimit:10];
    __block NSMutableArray *mutalArray = [NSMutableArray array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        for (BmobObject *obj in array) {
            NSMutableDictionary *mutalDict = [[NSMutableDictionary alloc] init];
            [mutalDict setObject:[obj objectForKey:@"word"] forKey:@"word"];
            [mutalDict setObject:[obj objectForKey:@"TrueAns"] forKey:@"TrueAns"];
            [mutalDict setObject:[obj objectForKey:@"fakeAns1"] forKey:@"fakeAns1"];
            [mutalDict setObject:[obj objectForKey:@"fakeAns2"] forKey:@"fakeAns2"];
            [mutalDict setObject:[obj objectForKey:@"fakeAns3"] forKey:@"fakeAns3"];
            [mutalDict setObject:[obj objectForKey:@"class"] forKey:@"class"];
            [mutalArray addObject:mutalDict];
        }
        NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachePath = pathArray[0];
        NSString *filePathName = [cachePath stringByAppendingPathComponent:@"data.plist"];
        NSArray *tempArray = [NSArray arrayWithContentsOfFile:filePathName];
        [mutalArray addObjectsFromArray:tempArray];
        self.dataArray = mutalArray;
        [self.dataArray writeToFile:filePathName atomically:YES];
        NSLog(@"\n self.dataArray: \n %ld",self.dataArray.count);
    }];
}

-(void)layouTestView
{
    self.countLabel.text = [NSString stringWithFormat:@"得到较准确的结果至少需要测试%lu个词\n%d/%lu",(unsigned long)self.dataArray.count,numberOfQues + 1,(unsigned long)self.dataArray.count];
    self.countLabel.hidden = NO;
    self.wordLabel.text = [self.dataArray[numberOfQues] objectForKey:@"word"];
    NSString *fakeAns1 = [self.dataArray[numberOfQues] objectForKey:@"fakeAns1"];
    NSString *fakeAns2 = [self.dataArray[numberOfQues] objectForKey:@"fakeAns2"];
    NSString *fakeAns3 = [self.dataArray[numberOfQues] objectForKey:@"fakeAns3"];
    NSString *TrueAns = [self.dataArray[numberOfQues] objectForKey:@"TrueAns"];
    NSArray *array = @[fakeAns1,fakeAns2,fakeAns3,TrueAns];
#pragma 数组乱序
    array = [array sortedArrayUsingComparator:^NSComparisonResult(NSString *str1, NSString *str2) {
        int seed = arc4random_uniform(2);
        if (seed) {
            return [str1 compare:str2];
        } else {
            return [str2 compare:str1];
        }
    }];
    self.choiceA.userInteractionEnabled = YES;
    self.choiceB.userInteractionEnabled = YES;
    self.choiceC.userInteractionEnabled = YES;
    self.choiceD.userInteractionEnabled = YES;
    self.dontKnowLabel.userInteractionEnabled = YES;
    
    self.choiceA.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    self.choiceB.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    self.choiceC.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    self.choiceD.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    self.dontKnowLabel.backgroundColor = RGBACOLOR(242, 242, 242, 1);
    
    self.choiceA.layer.cornerRadius = 10;
    self.choiceA.layer.masksToBounds = YES;
    self.choiceB.layer.cornerRadius = 10;
    self.choiceB.layer.masksToBounds = YES;
    self.choiceC.layer.cornerRadius = 10;
    self.choiceC.layer.masksToBounds = YES;
    self.choiceD.layer.cornerRadius = 10;
    self.choiceD.layer.masksToBounds = YES;
    self.dontKnowLabel.layer.cornerRadius = 10;
    self.dontKnowLabel.layer.masksToBounds = YES;
    
    self.choiceA.text = array[0]; //[NSString stringWithFormat:@"A. %@",array[0]];
    self.choiceB.text = array[1];//[NSString stringWithFormat:@"B. %@",array[1]];
    self.choiceC.text = array[2];//[NSString stringWithFormat:@"C. %@",array[2]];
    self.choiceD.text = array[3];//[NSString stringWithFormat:@"D. %@",array[3]];
    NSLog(@"word:%@\n",self.wordLabel.text);
    NSLog(@"choiceA:%@\n",array[0]);
    NSLog(@"choiceB:%@\n",array[1]);
    NSLog(@"choiceC:%@\n",array[2]);
    NSLog(@"choiceD:%@\n",array[3]);
}
//当一个labele背点击之后立即禁用所有label的交互
-(void)setLabelsStatus:(BOOL)isUserinteractionEnable
{
    self.choiceA.userInteractionEnabled = isUserinteractionEnable;
    self.choiceB.userInteractionEnabled = isUserinteractionEnable;
    self.choiceC.userInteractionEnabled = isUserinteractionEnable;
    self.choiceD.userInteractionEnabled = isUserinteractionEnable;
    self.dontKnowLabel.userInteractionEnabled = isUserinteractionEnable;
}

-(void)didClickChoiceCLabel
{
    [self setLabelsStatus:NO];
    self.dontKnowLabel.userInteractionEnabled = NO;
    if ([self.choiceC.text isEqualToString:[self.dataArray[numberOfQues] objectForKey:@"TrueAns"]]) {
        NSLog(@"bingo");
        self.choiceC.backgroundColor = [UIColor greenColor];
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score ++;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score += 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score += 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score += 4;
        }
    }
    else
    {
        self.choiceC.backgroundColor = [UIColor redColor];
        NSLog(@"ops");
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score --;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score -= 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score -= 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score -= 4;
        }
    }
    NSLog(@"\n 当前是第%d题",numberOfQues + 1);
    NSLog(@"\n目前得分：%d",score);
    numberOfQues ++;
    if (numberOfQues > 39) {
        [self performSelector:@selector(showLoadingAnimation) withObject:nil afterDelay:2];
    }
    else
    {
        [self performSelector:@selector(layouTestView) withObject:nil afterDelay:1];
    }
}
-(void)didClickChoiceBLabel
{
    [self setLabelsStatus:NO];
    if ([self.choiceB.text isEqualToString:[self.dataArray[numberOfQues] objectForKey:@"TrueAns"]]) {
        NSLog(@"bingo");
        self.choiceB.backgroundColor = [UIColor greenColor];
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score ++;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score += 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score += 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score += 4;
        }
    }
    else
    {
        self.choiceB.backgroundColor = [UIColor redColor];
        NSLog(@"ops");
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score --;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score -= 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score -= 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score -= 4;
        }
    }
    NSLog(@"\n 当前是第%d题",numberOfQues + 1);
    NSLog(@"\n目前得分：%d",score);
    numberOfQues ++;
    if (numberOfQues > 39) {
        [self performSelector:@selector(showLoadingAnimation) withObject:nil afterDelay:2];
    }
    else
    {
        [self performSelector:@selector(layouTestView) withObject:nil afterDelay:1];
    }
}
-(void)didClickChoiceALabel
{
    [self setLabelsStatus:NO];
    if ([self.choiceA.text isEqualToString:[self.dataArray[numberOfQues] objectForKey:@"TrueAns"]]) {
        NSLog(@"bingo");
        self.choiceA.backgroundColor = [UIColor greenColor];
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score ++;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score += 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score += 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score += 4;
        }
    }
    else
    {
        self.choiceA.backgroundColor = [UIColor redColor];
        NSLog(@"ops");
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score --;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score -= 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score -= 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score -= 4;
        }
    }
    NSLog(@"\n 当前是第%d题",numberOfQues + 1);
    NSLog(@"\n目前得分：%d",score);
    numberOfQues ++;
    if (numberOfQues > 39) {
        [self performSelector:@selector(showLoadingAnimation) withObject:nil afterDelay:2];
    }
    else
    {
        [self performSelector:@selector(layouTestView) withObject:nil afterDelay:1];
    }
}
-(void)didClickChoiceDLabel
{
    [self setLabelsStatus:NO];
    if ([self.choiceD.text isEqualToString:[self.dataArray[numberOfQues] objectForKey:@"TrueAns"]]) {
        NSLog(@"bingo");
        self.choiceD.backgroundColor = [UIColor greenColor];
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score ++;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score += 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score += 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score += 4;
        }
    }
    else
    {
        self.choiceD.backgroundColor = [UIColor redColor];
        NSLog(@"ops");
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N4"]) {
            score --;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N3"]) {
            score -= 2;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N2"]) {
            score -= 3;
        }
        if ([[self.dataArray[numberOfQues] objectForKey:@"class"] isEqualToString:@"N1"]) {
            score -= 4;
        }
    }
    NSLog(@"\n 当前是第%d题",numberOfQues + 1);
    NSLog(@"\n目前得分：%d",score);
    numberOfQues ++;
    if (numberOfQues > 39) {
        [self performSelector:@selector(showLoadingAnimation) withObject:nil afterDelay:2];
    }
    else
    {
        [self performSelector:@selector(layouTestView) withObject:nil afterDelay:1];
    }
}
-(void)didClickDontKnowLabel
{
    [self setLabelsStatus:NO];
    NSLog(@"不认识");
    numberOfQues++;
    self.dontKnowLabel.backgroundColor = [UIColor orangeColor];
    if (numberOfQues > 39) {
        [self performSelector:@selector(showLoadingAnimation) withObject:nil afterDelay:2];
    }
    else
    {
        [self performSelector:@selector(layouTestView) withObject:nil afterDelay:1];
    }
}

-(void)showTestResult
{
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
    NSString *notice = @"";
    if (score < 0) {
        notice = @"还需要加油啊！";
    }
    if (score >= 0 && score <25) {
        notice = @"您的词汇量已经达到了N1水平！";
    }
    if (score >= 25 && score <50) {
        notice = @"您的词汇量已经达到了N2水平！";
    }
    if (score >= 50 && score <75) {
        notice = @"您的词汇量已经达到了N3水平！";
    }
    if (score >=75) {
        notice = @"您的词汇量已经达到了N4水平！";
    }
    NSLog(@"as");
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    [alert showNotice:self title:[NSString stringWithFormat:@"您的得分为:%d",score] subTitle:notice closeButtonTitle:@"完成" duration:0.0f];
    [alert alertIsDismissed:^{
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        self.startBtn.hidden = NO;
        score = 0;
        numberOfQues = 0;
        //为新一轮测试加载数据
        [self configDataWithClas:@"N4"];
        [self configDataWithClas:@"N3"];
        [self configDataWithClas:@"N2"];
        [self configDataWithClas:@"N1"];
    }];
}

-(void)showLoadingAnimation{
    self.countLabel.hidden = YES;
    self.testView.hidden = YES;
    //隐藏支付完成动画
    [XLPaymentSuccessHUD hideIn:self.view];
    //显示支付中动画
    [XLPaymentLoadingHUD showIn:self.view];
    [self performSelector:@selector(showSuccessAnimation) withObject:nil afterDelay:1];
}

-(void)showSuccessAnimation{
    //隐藏支付中成动画
    [XLPaymentLoadingHUD hideIn:self.view];
    //显示支付完成动画
    [XLPaymentSuccessHUD showIn:self.view];
    [self performSelector:@selector(Done) withObject:nil afterDelay:1];
}
-(void)Done
{
    NSLog(@"Done");
    [XLPaymentSuccessHUD hideIn:self.view];
    [self showTestResult];
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSArray *pathArray =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = pathArray[0];
    NSString *filePathName = [cachePath stringByAppendingPathComponent:@"data.plist"];
    NSArray *array = [NSArray arrayWithContentsOfFile:filePathName];
    array = @[];
    [array writeToFile:filePathName atomically:YES];
}
@end
