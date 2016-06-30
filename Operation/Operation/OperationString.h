//
//  OperationString.h
//  Operation
//
//  Created by archy on 16/6/30.
//  Copyright © 2016年 archy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationString : NSObject
+(BOOL)isOnlyContainLettersWithString:(NSString *)string;
+(BOOL)isOnlyContainNumbersWithString:(NSString *)string;
+(BOOL)isOnlyContainLettersAndNumberWithString:(NSString *)string;
@end
