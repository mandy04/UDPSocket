//
//  ViewController.m
//  UDPSocketDemo
//
//  Created by llbt on 15/12/17.
//  Copyright © 2015年 llbt. All rights reserved.
//

#import "ViewController.h"
#import "AsyncUdpSocket.h"
#import "CommonClient.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *hostLable;
@property (weak, nonatomic) IBOutlet UILabel *portLabel;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;

@property (weak, nonatomic) IBOutlet UITextView *msgTextView;
@property (weak, nonatomic) IBOutlet UITableView *ipTableView;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UISwitch *switchStatus;
@property (nonatomic,strong)NSMutableArray* onLinePosts;

@property (nonatomic,strong)AsyncUdpSocket *mySocket;

@property (nonatomic,copy)NSString *host;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    [[CommonClient sharedInstance] connect:@"255.255.255.255" port:9000];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.onLinePosts = [NSMutableArray arrayWithCapacity:0];
    
    self.mySocket = [[AsyncUdpSocket alloc]initWithDelegate:self];
    //绑定端口
    [self.mySocket bindToPort:9000 error:nil];
    //开启广播
    [self.mySocket enableBroadcast:YES error:nil];
    //接收数据
    [self.mySocket receiveWithTimeout:-1 tag:0];
    
    self.hostLable.text = @"255.255.255.255";
    self.portLabel.text = @"9000";
    self.host = @"255.255.255.255";
    self.statusLabel.text = @"群发";
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkOnLine) userInfo:nil repeats:YES];
}


- (void)checkOnLine {
    
    NSString *sendInfo = @"谁在线";
    [self.mySocket sendData:[sendInfo dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:9000 withTimeout:-1 tag:0];
}

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    
    if (![host hasPrefix:@"::"]) {
    NSString *info = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"%@说：%@",host,info);
    if ([info isEqualToString:@"谁在线"]) {
        
        [self.mySocket sendData:[@"我在线" dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:9000 withTimeout:-1 tag:0];
    }else if ([info isEqualToString:@"我在线"]){
        //去除重复
        if (![self.onLinePosts containsObject:host]) {
            [self.onLinePosts addObject:host];
            [self.ipTableView reloadData];
        }
        
    }else{//如果接收到的是文本内容则显示
        
        self.msgTextView.text = [self.msgTextView.text stringByAppendingFormat:@"\n%@:%@",host,info];
       }
    }
    [self.mySocket receiveWithTimeout:-1 tag:0];

    return YES;

}

- (IBAction)sendBtn:(id)sender {
    
    [self.messageTF resignFirstResponder];
    NSString *sendInfo = self.messageTF.text;
    [self.mySocket sendData:[sendInfo dataUsingEncoding:NSUTF8StringEncoding] toHost:@"255.255.255.255" port:9000 withTimeout:-1 tag:0];
    
    if ([self.host isEqualToString:@"255.255.255.255"]) {
        self.msgTextView.text = [self.msgTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n对所有人说:%@",self.messageTF.text]];
    }else {
        self.msgTextView.text = [self.msgTextView.text stringByAppendingString:[NSString stringWithFormat:@"\n对%@说",self.host]];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.onLinePosts.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *showLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 300, 40)];
    showLabel.text = [NSString stringWithFormat:@"  显示IP个数：%d",self.onLinePosts.count];
    showLabel.textColor = [UIColor blackColor];
    return showLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSString *host = self.onLinePosts[indexPath.row];
    cell.textLabel.text = host;
    cell.textLabel.font = [UIFont systemFontOfSize:12.0f];
   // [[host componentsSeparatedByString:@"."]lastObject];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.host = self.onLinePosts[indexPath.row];
    self.switchStatus.on = NO;
    self.statusLabel.text = @"单聊中...";
    
}

- (IBAction)switchAction:(id)sender {
    
    UISwitch *sw = (UISwitch *)sender;
    
    if (sw.isOn) {
        self.host = @"255.255.255.255";
        self.statusLabel.text = @"群发";
    }else {
        self.statusLabel.text = @"单聊中...";
        [sw setOn:YES];
    }
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
