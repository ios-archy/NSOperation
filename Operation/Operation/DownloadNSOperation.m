//
//  DownloadNSOperation.m
//  Operation
//
//  Created by archy on 16/6/29.
//  Copyright © 2016年 archy. All rights reserved.
//

#import "DownloadNSOperation.h"
#import <UIKit/UIKit.h>
@interface DownloadNSOperation ()
{
    BOOL _isFinished;
    BOOL _isExecuting;
}
@end

@implementation DownloadNSOperation
-(instancetype)initwithUrl:(NSString *)url completion:(DownloadBlock)completion
{
    if (self == [super init]) {
        self.url = url;
        self.responseBlock = completion;
    }
    return self;
}
//必须重写此方法
-(void)main
{
    //新建一个自动释放池，如果是异步执行操作，那么将无法访问到主线程的自动释放池
    @autoreleasepool {
        BOOL taskIsFinished =NO;
        UIImage *image = nil;
        
        while (taskIsFinished==NO &&[self isCancelled]==NO) {
            //获取图片资源
            NSURL *url =[NSURL URLWithString: self.url];
            NSData *imagedata =[NSData dataWithContentsOfURL:url];
            image = [UIImage imageWithData:imagedata];
            NSLog(@"Current Thread=%@",[NSThread currentThread]);
            taskIsFinished = YES;
        }
        
        
        [self willChangeValueForKey:@"isFinishede"];
        [self willChangeValueForKey:@"isExecuting"];
        _isFinished =YES;
        _isExecuting = NO;
        [self didChangeValueForKey:@"isFinishde"];
        [self didChangeValueForKey:@"isExecuting"];
        
        if (self.responseBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.responseBlock(image);
            });
        }
    }
}
-(BOOL)isExecuting
{
    return _isExecuting;
}
-(BOOL)isFinished
{
    return _isFinished;
}
//-(BOOL)isAsynchronous
//{
//    return YES;
//}
@end
