//
//  DownloadNSOperation.h
//  Operation
//
//  Created by archy on 16/6/29.
//  Copyright © 2016年 archy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIView.h>
typedef void(^DownloadBlock) (UIImage *image);
@interface DownloadNSOperation : NSOperation

@property (nonatomic,copy)NSString *url;

@property (nonatomic,copy)DownloadBlock responseBlock;

-(instancetype)initwithUrl:(NSString *)url completion:(DownloadBlock )completion;

@end
