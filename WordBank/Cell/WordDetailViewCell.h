//
//  WordDetailViewCell.h
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WordModel;
@protocol WordDetailViewCellDelegate <NSObject>

-(void)pushToLoginView;
-(void)popAlert;

@end
@interface WordDetailViewCell : UITableViewCell
@property (nonatomic, weak)id<WordDetailViewCellDelegate> WordDetailViewCellDelegate;
- (void)configWithWordModel:(WordModel *)wordModel;
//@property(nonatomic,strong) NSString* userID;
@end
