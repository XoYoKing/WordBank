//
//  ProgressView.h
//  JxbLovelyLogin
//
//  Created by Peter on 2019/2/15.
//  Copyright © 2019年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressView : UIView
@property(assign, nonatomic) CGFloat progress; // 白色部分比例 0~1

@property(assign, nonatomic) CGFloat radius;
@end

NS_ASSUME_NONNULL_END
