//
//  ViewController.m
//  Operation
//
//  Created by archy on 16/6/29.
//  Copyright © 2016年 archy. All rights reserved.
//

#import "ViewController.h"
#import "DownloadNSOperation.h"
#import "OperationString.h"
#import <pthread.h>
@interface ViewController ()
@property (nonatomic,strong)UIImageView *image;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _image =[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:_image];
//    [self stringtest];
//    [self NSTHreadTest];
//    [self groupQueue];
    [self timerCount];
}
-(void)timerCount
{
    __block int timeout = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 每秒执行
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), 1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(timer, ^{
        if (timeout >= 30) {// 2. 最长停留时间：30秒。 30秒后无论是否领完，都会消失，
            dispatch_source_cancel(timer);
            dispatch_async(dispatch_get_main_queue(), ^{
               
            });
        } else if(timeout <=5) { //1. 最短停留时间：5秒。 5秒内无论是否领完，都不会消失。
            int seconds = timeout % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
               
                
            });
            timeout++;
        }
        else if (timeout>5 &&timeout<30) //2. 最长停留时间：30秒。 30秒后无论是否领完，都会消失，多余的小鱼不予退还。
        {
            if (@"如果领完就消失，不领完不消失") {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    
                });
            }
            timeout++;
        }
    });
    dispatch_resume(timer);
}
-(void)groupQueue
{
    dispatch_group_t group =dispatch_group_create();
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //执行一个耗时操作
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
       //执行另外一个耗时操作
    });
    
    //这个组的特点，是会等组里面所有的任务都执行完毕后，他会调用notify里面的这个block
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
       //等前面的异步操作都执行完毕后，回到主线程
    });
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //开启一条子线程下载图片
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}
-(void)downloadImage
{
    //计算代码的执行时间
    NSDate *start =[NSDate date];
    
    
    
    //1.确定要下载网络图片的URL地址，一个url对应着网络上的一个资源
    NSURL *url =[NSURL URLWithString:@"http://news.youth.cn/js/201606/W020160628560038227469.jpg"];
    //2.根据url地址下载图片数据到本地
    NSData *data =[NSData dataWithContentsOfURL:url];
    //3.把下载到本地的二进制数据转换成图片
    UIImage *image =[UIImage imageWithData:data];
    NSDate *end =[NSDate date];
    NSLog(@"操作花费了的时间为：%f",[end timeIntervalSinceDate:start]);
    //4.回到主线程刷新UI
    //1.方法一：
    [self performSelectorOnMainThread:@selector(showimage:) withObject:image waitUntilDone:YES];
    //2.方法二
    [self.image performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    //3.方法三
    [self.image performSelector:@selector(setImage:) onThread:[NSThread mainThread] withObject:image waitUntilDone:YES];
}
-(void)showimage:(UIImage *)image
{
    self.image.image  = image;
}
//线程pthread
-(void)pthreadTest
{
    pthread_t thread;
    NSString *name = @"archy";
//    pthread_create(&thread, NULL, run, (__bridge void *)(name));
}

-(void)run
{
    
}
//多线程NSTHread
-(void)NSTHreadTest
{
    //创建和启动线程
    //一个NSTHread对象就代表一条线程
    //创建启动线程
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(runtest) object:nil];
    //设置线程的名字
    [thread setName:@"dashabi"];
    //线程一启动，就会告诉CPU准备就绪，可以随时接受CPU调度！CPU调度当前线程之后，就会在线程thread中执行self的runtest方法
    [thread start];
    
    //阻塞（暂停）线程
    [NSThread sleepForTimeInterval:700];
    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
    
    //退出线程
    [NSThread exit];
//    [NSThread mainThread];//获取主线程
    
    if ([thread isMainThread]) { //判断时候是主线程
        NSLog(@"主线程");
    }
    NSThread *current =[NSThread currentThread];
    
    //创建并启动线程
    [NSThread detachNewThreadSelector:@selector(runtest) toTarget:self withObject:nil];
    
    //隐士创建并启动线程
    [self performSelectorInBackground:@selector(runtest) withObject:nil];
    
    
}
-(void)runtest
{
  
}
-(void)stringtest
{
 BOOL isorno =   [OperationString isOnlyContainLettersWithString:@"afasfsdf"];
    NSLog(@"ssss");
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
