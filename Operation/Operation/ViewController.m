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
    [self testGCD];

}

-(void)testGCD
{
    
//   1. dispatch_get_current_queue();  ios6.0后已经废弃
//   2. dispatch_get_main_queue(); 最常用的，用于获取应用主线程关联的串行调度队列
//   3. dispatch_get_global_queue(, );最常用的，用于获取应用全局共享的并发队列
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
    //此行里的代码只执行一次
        NSLog(@"哈哈哈，只执行了一次！！！！");
    });
    
    //1.获取全局并发调度队列
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //迭代次数
    size_t gcount = 10;
    //如果迭代执行的任务与其他迭代任务是独立无关的，而且迭代执行顺序也不相关的话，可以用dispatch_apply或者dispatch_apply_f
    dispatch_apply(gcount, globalQueue, ^(size_t i) {
        NSLog(@"并发循环迭代%zu,当前线程：%@",i,[NSThread currentThread]);
    });
    
    
    //2.创建串行调度队列  :串行队列确保任务按指定的顺数执行
    dispatch_queue_t sequelQueue =dispatch_queue_create("com.uthing.hellowold", NULL);
    
    dispatch_async(sequelQueue, ^{
        NSLog(@"开启了一个异步任务，当前线程：%@",[NSThread currentThread]);
    });
    dispatch_sync(sequelQueue, ^{
        NSLog(@"开启了一个同步任务，当前线程：%@",[NSThread currentThread]);
    });
    
    
    //3.暂停和继续queue
    dispatch_suspend(sequelQueue);  //挂起sequelQueue
    dispatch_resume(sequelQueue);   //继续sequelQueue
    
    //4.图片下载及刷新
    //先将异步下载图片的任务放在dispatch_get_global_queue全局共享并发队列中执行，在完成之后，需要放在dispatch_get_main_queue回到主线程更新UI
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *ulr =[NSURL URLWithString:@"http://news.youth.cn/js/201606/W020160628560038227469.jpg"];
        UIImage *image =[UIImage imageWithData:[NSData dataWithContentsOfURL:ulr]];
        //回到主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image.image = image;
        });
    });
    
     //5.调度组（dispatch group）
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //异步下载图片
    dispatch_async(queue, ^{
        //创建一个数组
        dispatch_group_t group = dispatch_group_create();
        __block UIImage *image1 = nil;
        __block UIImage *image2 = nil;
        
        //分别将任务添加到数组
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            image1 =[self doownimage:@"http://news.youth.cn/js/201606/W020160628560038227469.jpg"];
        });
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            image2 = [self doownimage:@"http://news.cnr.cn/gjxw/tpjj/20160629/W020160629701599620948.jpg"];
        });
        
        //等待数组中的任务执行完毕，回到主线程执行block回调
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            self.image.image = image1;
            self.image.image = image2;
        });
    });
    
    //6.延迟执行
    [self performSelector:@selector(test3) withObject:nil afterDelay:5.0]; //NSObject 的 API
    CGFloat time =5.0f;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //此处time秒后执行操作
    });

}
-(UIImage *)doownimage:(NSString *)url
{
    NSURL *URL =[NSURL URLWithString:url];
    NSData *data =[NSData dataWithContentsOfURL:URL];
    UIImage *image =[UIImage imageWithData:data];
    return image;
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
void click(void)
{
    printf("hahahaha");
}
-(void)click
{

    NSURL *nsUrl = [NSURL URLWithString:@"http://news.youth.cn/js/201606/W020160628560038227469.jpg"];
    NSData *data = [[NSData alloc] initWithContentsOfURL:nsUrl];
    UIImage *image = [[UIImage alloc] initWithData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.image.image = image;
        NSLog(@"图片加载完毕");
        click();
    });
//    [self performSelectorOnMainThread:@selector(updateUi:) withObject:image waitUntilDone:YES];
    
}
-(void)updateUi:(UIImage *)image
{
    self.image.image =image;
    
}

@end
