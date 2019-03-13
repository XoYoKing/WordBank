//
//  WordModel.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "WordModel.h"

@implementation WordModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (NSString *)prefix {
    return _prefix.lowercaseString;
}

- (NSString *)desc {
    if (self.prefix == nil) {
        //转成了可变字符串
        NSMutableString *str = [NSMutableString stringWithString:self.word];
        //先转换为带声调的拼音
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
        //再转换为不带声调的拼音
        CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
        //转化为大写拼音
        NSString *pinYin = [str capitalizedString];
        //获取并返回首字母
        self.prefix = [pinYin substringToIndex:1];
    }
    return [NSString stringWithFormat:@"{\n\t\"prefix\": \"%@\",\n\t\"word\": \"%@\",\n\t\"jpword\": \"%@\",\n\t\"kana\": \"%@\",\n\t\"mean\": \"%@\",\n\t\"sample\": \"%@\"\n\t},\n", self.prefix, self.word, self.jpword, self.kana, self.mean, self.sample];
}

@end
