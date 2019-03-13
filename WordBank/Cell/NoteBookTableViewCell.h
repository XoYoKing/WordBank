//
//  NoteBookTableViewCell.h
//  WordBank
//
//  Created by Peter on 2019/2/20.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoteBookTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *jpWordLabel;
@property (weak, nonatomic) IBOutlet UILabel *kanaLabel;
@property (weak, nonatomic) IBOutlet UILabel *meanLabel;
@property (weak, nonatomic) IBOutlet UILabel *sampleLabel;
@end

NS_ASSUME_NONNULL_END
