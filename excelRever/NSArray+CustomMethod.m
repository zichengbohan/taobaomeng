//
//  NSArray+CustomMethod.m
//  excelRever
//
//  Created by 胥佰淼 on 2016/11/16.
//  Copyright © 2016年 胥佰淼. All rights reserved.
//

#import "NSArray+CustomMethod.h"
#import "XBMProductModel.h"

@implementation NSArray (CustomMethod)

- (NSArray *)searchArrayWithStr:(NSString *)str type:(NSString *)type {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (XBMProductModel *model in self) {
        if ([type isEqualToString:@"全部"]) {
            if (str.length == 0) {
                [array addObject:model];
                continue;
            }
            if ([model.proName containsString:str]) {
                [array addObject:model];
            }
        } else {
            if (str.length == 0) {
                if ([model.type isEqualToString:type]) {
                    [array addObject:model];
                    continue;
                }
            }
            if ([model.proName containsString:str] && [model.type isEqualToString:type]) {
                [array addObject:model];
            }
        
            
        }
        
    }
    return array;
}

//- (NSArray *)getStyleClass {
//    
//}

@end
