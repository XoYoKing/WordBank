//
//  ProgressView.m
//  JxbLovelyLogin
//
//  Created by Peter on 2019/2/15.
//  Copyright © 2019年 Peter. All rights reserved.
//

#import "ProgressView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
/** 宽度比 */
#define kScaleW kScreenWidth/375

/** 高度比 */
#define kScaleH kScreenHeight/667
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
@implementation ProgressView

- (void)drawRect:(CGRect)rect {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    [path
     addArcWithCenter:CGPointMake(rect.size.width * 0.5, rect.size.width * 0.5)
     radius:self.radius
     startAngle:2 * M_PI - M_PI_2
     endAngle:(2 * M_PI) * self.progress - M_PI_2
     clockwise:0];
    [path setLineWidth:2*kScaleW];
    [RGBACOLOR(26, 59, 114, 1) set];
    [path stroke];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
