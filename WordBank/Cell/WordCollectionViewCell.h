//
//  WordCollectionViewCell.h
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WordCollectionViewCell : UICollectionViewCell

- (void)configWithWord:(NSString *)word wordCount:(NSInteger)count type:(NSString *)type;

@end
