//
//  ViewController.m
//  SocketServer
//
//  Created by BDHT-MAC on 28/11/2016.
//  Copyright © 2016 BDHT-MAC. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController()
@property (weak) IBOutlet NSTextField *host;
@property (weak) IBOutlet NSTextField *port;
@property (weak) IBOutlet NSTextView *statusTips;
@property (weak) IBOutlet NSButton *lisBtn;
@property (weak) IBOutlet NSTextField *sendText;

@property (nonatomic) GCDAsyncSocket *socket;
@property (nonatomic) GCDAsyncSocket *serverSocket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _host.stringValue = @"nil";
    _port.stringValue = @"8808";
    _statusTips.string = @"socket is ready";
    _sendText.stringValue = @"how are you ?";
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)listennnigOrStop:(NSButton *)sender {
    
    NSError *error = nil;
    BOOL result;
    
    result = [self.socket acceptOnInterface:nil port:[self.port.stringValue integerValue] error:&error];
    
    self.statusTips.string = [NSString stringWithFormat:@"result:%d, error:%@",result,[error localizedDescription]];
    if (result) {
        self.statusTips.string = @"start listenning...";
    }
}
- (IBAction)disconnect:(NSButton *)sender {
    
    //断开连接需要使用newSocket断开，
    [self.serverSocket disconnect];
}
- (IBAction)sendData:(NSButton *)sender {
    
    NSData *data = [self.sendText.stringValue dataUsingEncoding:NSUTF8StringEncoding];
    if (self.serverSocket) {
        //发送数据使用新连接的serverSocket
        [self.serverSocket writeData:data withTimeout:-1 tag:0];
    }else{
        self.statusTips.string = @"no retain client socket!";
    }
    
}
//服务端开始在特定端口侦听后还没有真正的socket，直到和客户端建立连接后才会创建真正的newSocket即服务端socket。
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    self.statusTips.string = [NSString stringWithFormat:@"new socket:%@",newSocket.connectedHost];
    //持有新创建的server端newSocket，不持有新连接的Socket，新的socket会自动被系统释放。详细说明看didAcceptNewSocket这个回调的说明。
    self.serverSocket = newSocket;
    //给新连接的Socket设置代理，共用代理。
    self.serverSocket.delegate = self;
    //建立连接后，开始无超时的读取新Socket发送的数据，如果没有数据一直等待，如果有数据didReadData回调被吊起。（不主动读取socket数据是读不到任何数据的）
    [self.serverSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"%@",self.statusTips.string);

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    self.statusTips.string = [NSString stringWithFormat:@"DidDisconnect error:%@",[err localizedDescription]];
    NSLog(@"%@",self.statusTips.string);
}


- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    
    NSDateFormatter *format = [NSDateFormatter new];
    format.dateFormat = @"HH:mm:ss";
    NSString *time = [format stringFromDate:[NSDate date]];
    self.statusTips.string = [NSString stringWithFormat:@"[%@]:send data successfully",time];
    NSLog(@"%@",self.statusTips.string);
    
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSDateFormatter *format = [NSDateFormatter new];
    format.dateFormat = @"HH:mm:ss";
    NSString *time = [format stringFromDate:[NSDate date]];
    NSString *receiveText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.statusTips.string = [NSString stringWithFormat:@"[%@]%@: %@",time,self.serverSocket.connectedHost,receiveText];
    //读取完newSocket发送的数据后，需要再次主动读取数据，否则didReadData不会再次调起。
    [self.serverSocket readDataWithTimeout:-1 tag:0];
    NSLog(@"%@",self.statusTips.string);
}




@end
