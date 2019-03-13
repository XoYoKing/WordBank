//
//  WordCollectionViewCell.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "WordCollectionViewCell.h"
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]


@interface WordCollectionViewCell()

@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;


@end

@implementation WordCollectionViewCell


- (void)configWithWord:(NSString *)word wordCount:(NSInteger)count type:(NSString *)type {
    if ([type isEqualToString:@"home"]) {
        self.wordLabel.font = [UIFont fontWithName:@"PingFangHK-Light" size:28];
    } else {
        self.wordLabel.font = [UIFont fontWithName:@"PingFangHK-Light" size:36];
    }
    self.wordLabel.layer.cornerRadius = 6;
    self.wordLabel.layer.masksToBounds = YES;
    self.wordLabel.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.wordLabel.layer.shadowOpacity = 0.05;
    self.wordLabel.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    self.wordLabel.text = word;
    if (count == 0) {
        self.countLabel.hidden = YES;
    } else {
        self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)count];
    }
}

@end
