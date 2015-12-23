//
//  CommonClient.h
//  UDPSocketDemo
//
//  Created by llbt on 15/12/17.
//  Copyright © 2015年 llbt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"

#define CHECK_SEND_INTERVAL 1


@interface CommonClient : NSObject

@property (nonatomic,copy)NSString *host;
@property (nonatomic,assign)NSInteger port;

@property (nonatomic,strong)AsyncUdpSocket *socket;
@property (nonatomic,strong)NSTimer *autoStartCheckTimer;
@property (nonatomic,strong)NSMutableArray *onLinePosts;

+(CommonClient *)sharedInstance;

- (void)connect:(NSString *)host port:(NSInteger)port;

- (void)readData:(NSData *)data tag:(NSUInteger)tag;

@end
