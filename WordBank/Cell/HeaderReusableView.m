//
//  HeaderReusableView.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "HeaderReusableView.h"

@interface HeaderReusableView()

@property (weak, nonatomic) IBOutlet UILabel *prefixLabel;

@end

@implementation HeaderReusableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configWithPrefix:(NSString *)prefix {
    self.prefixLabel.text = prefix;
}

@end
