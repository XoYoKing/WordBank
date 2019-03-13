//
//  WordModel.h
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "JSONModel.h"

@interface WordModel : JSONModel

@property (nonatomic, copy) NSString *prefix;
@property (nonatomic, copy) NSString *word;
@property (nonatomic, copy) NSString *jpword;
@property (nonatomic, copy) NSString *kana;
@property (nonatomic, copy) NSString *mean;
@property (nonatomic, copy) NSString *sample;

- (NSString *)desc;

@end
