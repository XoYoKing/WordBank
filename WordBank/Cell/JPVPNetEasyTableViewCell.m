//
//  JPVPNetEasyTableViewCell.m
//  JPVideoPlayerDemo
//
//  Created by Memet on 2018/4/24.
//  Copyright © 2018 NewPan. All rights reserved.
//

#import "JPVPNetEasyTableViewCell.h"
#import <Masonry.h>
@implementation JPVPNetEasyTableViewCell
//#define kWidth [UIScreen mainScreen].bounds.size.width

- (IBAction)playButtonDidClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellPlayButtonDidClick:)]) {
        [self.delegate cellPlayButtonDidClick:self];
    }
}
- (void)awakeFromNib
{
    
    [super awakeFromNib];
    [self.videoPlayView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView.mas_centerX);
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.width.mas_equalTo([self kScreenWith] - 20);
        make.height.mas_equalTo(([self kScreenWith] - 20) * 9 / 16);
    }];
}
-(CGFloat)kScreenWith
{
    NSLog(@"%f",[[UIApplication sharedApplication] statusBarFrame].size.width);
    return [[UIApplication sharedApplication] statusBarFrame].size.width;
}
@end
