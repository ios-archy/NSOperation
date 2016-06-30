

//
//  OperationString.m
//  Operation
//
//  Created by archy on 16/6/30.
//  Copyright © 2016年 archy. All rights reserved.
//

#import "OperationString.h"

@interface OperationString ()

@end

@implementation OperationString
+(BOOL)isOnlyContainLettersWithString:(NSString *)string
{
    NSCharacterSet *letterCharacterset =[[NSCharacterSet letterCharacterSet]invertedSet];
    return ([string rangeOfCharacterFromSet:letterCharacterset].location==NSNotFound);
}
+(BOOL)isOnlyContainNumbersWithString:(NSString *)string
{
    NSCharacterSet *numset =[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
    return ([string rangeOfCharacterFromSet:numset].location==NSNotFound);
}
+(BOOL)isOnlyContainLettersAndNumberWithString:(NSString *)string
{
    NSCharacterSet *numAndLettersCharSet =[[NSCharacterSet alphanumericCharacterSet]invertedSet];
    return ([string rangeOfCharacterFromSet:numAndLettersCharSet].location==NSNotFound);
}
@end
