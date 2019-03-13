//
//  WordDetailViewCell.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//
#import "WordDetailViewCell.h"
#import "WordModel.h"
#import <BmobSDK/Bmob.h>
#import "VBFPopFlatButton.h"
#import "SCLAlertView.h"
#import "LoginViewController.h"
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]


@interface WordDetailViewCell()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *jpWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *kanaLabel;
@property (weak, nonatomic) IBOutlet UILabel *meanLabel;
@property (weak, nonatomic) IBOutlet UILabel *sampleLabel;
@property (strong, nonatomic) VBFPopFlatButton *flatRoundedButton;
//@property (weak, nonatomic) IBOutlet UIView *cintainerView;



@end

@implementation WordDetailViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addBtn];
}

-(void)addBtn
{
    CGFloat kContainerViewWidth = [UIScreen mainScreen].bounds.size.width - 30;
    NSLog(@"%f",self.containerView.superview.frame.size.width);
    self.flatRoundedButton = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(kContainerViewWidth-30, 15, 15, 15)
                                                         buttonType:buttonAddType
                                                        buttonStyle:buttonRoundedStyle
                                              animateToInitialState:YES];
    self.flatRoundedButton.roundBackgroundColor = RGBACOLOR(26, 59, 114, 1);
    self.flatRoundedButton.lineThickness = 2;
//    self.flatRoundedButton.tintColor = [UIColor flatPeterRiverColor];
    [self.flatRoundedButton addTarget:self
                               action:@selector(didClickAddBtn)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.flatRoundedButton];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)configWithWordModel:(WordModel *)wordModel {
    self.containerView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.containerView.layer.shadowOpacity = 0.2;
    self.containerView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    
    self.jpWordLabel.text = wordModel.jpword;
    self.kanaLabel.text = wordModel.mean;
    self.meanLabel.text = [NSString stringWithFormat:@"\"%@\"", wordModel.kana];
    self.sampleLabel.text = wordModel.sample;
}


#pragma 点击添加按钮 将该词添加进生词本
-(void)didClickAddBtn
{
    NSLog(@"点击添加按钮");
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user objectForKey:@"userID"]) {
        NSLog(@"上传单词到生词本。。。");
        BmobObject *newWord = [BmobObject objectWithClassName:@"words"];
        [newWord setObject:self.jpWordLabel.text forKey:@"jpWordLabel"];
        [newWord setObject:self.kanaLabel.text forKey:@"kanaLabel"];
        [newWord setObject:self.meanLabel.text forKey:@"meanLabel"];
        [newWord setObject:self.sampleLabel.text forKey:@"sampleLabel"];
        NSString *userID = [user objectForKey:@"userID"];
        [newWord setObject:userID forKey:@"userID"];
        [newWord saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            //进行操作
            if (isSuccessful) {
                [self.flatRoundedButton animateToType:buttonOkType];
                [self performSelector:@selector(backToAddStatus) withObject:nil afterDelay:0.5];
            }else{
                if ([error code] == 401) {
                    if (self.WordDetailViewCellDelegate && [self.WordDetailViewCellDelegate respondsToSelector:@selector(popAlert)]) {
                        NSLog(@"用户之前添加过该词");
                        [self.WordDetailViewCellDelegate popAlert];
                    }
                }
            }
        }];
    }else{
        if (self.WordDetailViewCellDelegate && [self.WordDetailViewCellDelegate respondsToSelector:@selector(pushToLoginView)]) {
            NSLog(@"用户未登录，跳转到登录界面");
            [self.WordDetailViewCellDelegate pushToLoginView];
        }
    }
}
-(void)backToAddStatus
{
    [self.flatRoundedButton animateToType:buttonAddType];
}
@end
