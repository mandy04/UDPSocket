//
//  CommonClient.m
//  UDPSocketDemo
//
//  Created by llbt on 15/12/17.
//  Copyright © 2015年 llbt. All rights reserved.
//

#import "CommonClient.h"

@implementation CommonClient

+(CommonClient *)sharedInstance {
    static CommonClient *__client = nil;
    dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __client = [[CommonClient alloc]init];
    });
    return __client;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        _socket = [[AsyncUdpSocket alloc]initWithDelegate:self];
        _onLinePosts = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)connect:(NSString *)host port:(NSInteger)port {
    _host = host;
    _port = port;
    [self start:port];
}

- (void)start:(NSInteger)port{
    _socket = [[AsyncUdpSocket alloc]initWithDelegate:self];

    //绑定端口
    [_socket bindToPort:port error:nil];
    //广播
    [_socket enableBroadcast:YES error:nil];
    //接收数据
    [_socket receiveWithTimeout:-1 tag:0];
    
    self.autoStartCheckTimer  = [NSTimer scheduledTimerWithTimeInterval:CHECK_SEND_INTERVAL target:self selector:@selector(checkOnLine) userInfo:nil repeats:YES];

}

- (void)checkOnLine {
    
    NSString *sendInfo = @"谁在线";

    [_socket sendData:[sendInfo dataUsingEncoding:NSUTF8StringEncoding] toHost:_host port:_port withTimeout:-1 tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    if (![host hasPrefix:@"::"]) {
        NSString *info = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

        if ([info isEqualToString:@"谁在线"]) {
            
            [_socket sendData:[@"我在线" dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:port withTimeout:-1 tag:0];
            
        }else if ([info isEqualToString:@"我在线"]){
            //去除重复
            if (![self.onLinePosts containsObject:host]) {
                [self.onLinePosts addObject:host];
            }
        }
    }
    [_socket receiveWithTimeout:-1 tag:0];
    
    return YES;
    
}

- (void)dealloc {
    [self.autoStartCheckTimer invalidate];
}



@end
