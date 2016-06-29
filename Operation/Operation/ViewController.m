//
//  ViewController.m
//  Operation
//
//  Created by archy on 16/6/29.
//  Copyright © 2016年 archy. All rights reserved.
//

#import "ViewController.h"
#import "DownloadNSOperation.h"
@interface ViewController ()
@property (nonatomic,strong)UIImageView *image;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _image =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:_image];
    [self test3];

}
-(void)test3
{
  DownloadNSOperation *operation =[[DownloadNSOperation alloc]initwithUrl:@"http://news.youth.cn/js/201606/W020160628560038227469.jpg" completion:^(UIImage *image) {
      self.image.image = image;
  }];
    NSOperationQueue *queue =[[NSOperationQueue alloc]init];
//    [operation start];
    [queue addOperation:operation];
//    []
    
}
-(void)test2
{
    NSBlockOperation *operation =[NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"这是第一个任务在线程：%@执行，isMainThread:%d,isAaync:%d",[NSThread currentThread],[NSThread isMainThread],[operation isAsynchronous]);
    }];
    
    __weak typeof(operation)  weakOperation = operation;
    [operation addExecutionBlock:^{
        NSLog(@"这是第二个任务在线程：%@执行，isMainThread:%d,isAync:%d",[NSThread currentThread],[NSThread isMainThread],[weakOperation isAsynchronous]);
    }];
    [operation addExecutionBlock:^{
        NSLog(@"这是第三个任务在线程：%@执行，isMainThread:%d,isAync:%d",[NSThread currentThread],[NSThread isMainThread],[weakOperation isAsynchronous]);
    }];
    [operation addExecutionBlock:^{
        NSLog(@"这是第四个任务在线程：%@执行，isMainThread:%d,isAync:%d",[NSThread currentThread],[NSThread isMainThread],[weakOperation isAsynchronous]);
    }];
    [operation addExecutionBlock:^{
       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"这是第五个任务在线程：%@执行，isMainThread:%d,isAync:%d",[NSThread currentThread],[NSThread isMainThread],[weakOperation isAsynchronous]);
       });
    }];
    [operation addExecutionBlock:^{
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"这是第六个任务在线程：%@执行，isMainThread:%d,isAync:%d",[NSThread currentThread],[NSThread isMainThread],[weakOperation isAsynchronous]);
        });
    }];
//    [operation start];
    NSOperationQueue *queue =[[NSOperationQueue alloc]init];
    [queue addOperation:operation];
    [queue setMaxConcurrentOperationCount:2];
}
-(void)test1
{
    NSInvocationOperation *opertation = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(click) object:nil];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [queue addOperation:opertation];
    //任务执行完成回调
    opertation.completionBlock = ^(){
        NSLog(@"任务执行完毕completionBlock");
    };
    
    [opertation setCompletionBlock:^{
        NSLog(@"任务执行完毕setCompletionBlock");
    }];
    
    //    if (!opertation.isExecuting) { //判断是否正在执行
    //        //NSOperation提供了start方法开启任务执行操作
    //        //默认按照同步方式执行
    //        [opertation start];
    //    }
    //   isCancelled 判断是否被取消
    //    - (void)cancel; 取消
    //    isExecuting 判断是否正在执行
    //    isFinished   判断是否完成
    //   isConcurrent  判断是否是异步
    //    isAsynchronous  判断是否是异步
    //   isReady   判断是否是为执行做好了准备
    
    if([UIDevice currentDevice].systemVersion.intValue >=7.0)
    {
        if (opertation.isAsynchronous) {
            NSLog(@"异步");
        }
        else
        {
            NSLog(@"同步");
        }
    }
    else
    {
        if (opertation.isConcurrent) {
            NSLog(@"异步");
        }
        else
        {
            NSLog(@"同步");
        }
    }
}
-(void)click
{

    NSURL *nsUrl = [NSURL URLWithString:@"http://news.youth.cn/js/201606/W020160628560038227469.jpg"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:nsUrl];
    UIImage *image = [[UIImage alloc] initWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image.image = image;
        NSLog(@"图片加载完毕");
    });
//    [self performSelectorOnMainThread:@selector(updateUi:) withObject:image waitUntilDone:YES];
    
}
-(void)updateUi:(UIImage *)image
{
    self.image.image =image;
    
}

@end
