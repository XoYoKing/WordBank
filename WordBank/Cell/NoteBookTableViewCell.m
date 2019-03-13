//
//  NoteBookTableViewCell.m
//  WordBank
//
//  Created by Peter on 2019/2/20.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "NoteBookTableViewCell.h"
@interface NoteBookTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@end
@implementation NoteBookTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
