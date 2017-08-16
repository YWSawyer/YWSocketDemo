//
//  ViewController.m
//  SocketClient
//
//  Created by BDHT-MAC on 25/11/2016.
//  Copyright © 2016 BDHT-MAC. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController () <GCDAsyncSocketDelegate>

@property (weak, nonatomic) IBOutlet UITextField *host;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextView *errorText;
@property (weak, nonatomic) IBOutlet UIButton *manualBtn;

@property (weak, nonatomic) IBOutlet UISwitch *isManual;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UITextField *sendText;
@property (weak, nonatomic) IBOutlet UISwitch *readToSwitch;
@property (weak, nonatomic) IBOutlet UITextField *readToStr;

@property (nonatomic) GCDAsyncSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    _host.text = @"localhost";
    _port.text = @"8808";
    _sendText.text = @"hi Sawyer";
    [self.isManual setOn:YES];
    [self.readToSwitch setOn:NO];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startConnectServer:(UIButton *)sender {
    
    NSError *error = nil;
    BOOL result;
    
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    result = [self.socket connectToHost:self.host.text onPort:[self.port.text integerValue] withTimeout:-1 error:&error];
    if (result) {
        self.errorText.text = [NSString stringWithFormat:@"start connect to %@...",self.host];
    }else {
        self.errorText.text = [NSString stringWithFormat:@"error:%@",[error localizedDescription]];
    }

}
- (IBAction)disconect:(id)sender {
    
    [self.socket disconnect];
    //断开连接仅仅是断开连接了，但socket的引用还是存在的，如果直接发送数据还是可以发送出去的，需要直接释放引用。
    self.socket = nil;
}
- (IBAction)sendData:(UIButton *)sender {
    
    NSData *data = [self.sendText.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:data withTimeout:-1 tag:999];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.errorText resignFirstResponder];
    [self.sendText resignFirstResponder];
    [self.host resignFirstResponder];
    [self.port resignFirstResponder];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
    self.errorText.text = [NSString stringWithFormat:@"didConnectToHost:%@",host];
    //使能后台socket
    [self.socket performBlock:^{
        BOOL enable = [self.socket enableBackgroundingOnSocket];
        NSLog(@"enableBackgroundingOnSocket is :%@",enable?@"true":@"false");
    }];
    
    //建立连接后，开始无超时的读取新Socket发送的数据，如果没有数据一直等待，如果有数据didReadData回调被吊起。（不主动读取socket数据是读不到任何数据的）
    if (!self.isManual.isOn) {
         [self.socket readDataWithTimeout:-1 tag:0];
    }
     NSLog(@"%@",self.errorText.text);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    self.errorText.text = [NSString stringWithFormat:@"DidDisconnect error:%@",[err localizedDescription]];
    NSLog(@"%@",self.errorText.text);
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSDateFormatter *format = [NSDateFormatter new];
    format.dateFormat = @"HH:mm:ss";
    NSString *time = [format stringFromDate:[NSDate date]];
    self.errorText.text = [NSString stringWithFormat:@"[%@]send data successfully",time];
    NSLog(@"%@",self.errorText.text);

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSDateFormatter *format = [NSDateFormatter new];
    format.dateFormat = @"HH:mm:ss";
    NSString *time = [format stringFromDate:[NSDate date]];
    NSString *receiveText = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    self.errorText.text = [NSString stringWithFormat:@"[%@]%@: %@",time,sock.connectedHost,receiveText];
    //读取完newSocket发送的数据后，需要再次主动读取数据，否则didReadData不会再次调起。
    if (!self.isManual.isOn) {
        [self.socket readDataWithTimeout:-1 tag:0];
    }
    NSLog(@"%@",self.errorText.text);
}

- (IBAction)manualReadAction:(UIButton *)sender {
    if (self.readToSwitch.isOn) {
        NSString *abc = self.readToStr.text;
        NSData *ddd = [abc dataUsingEncoding:NSUTF8StringEncoding];
        [self.socket readDataToData:ddd withTimeout:-1 tag:99];
    }else{
        [self.socket readDataWithTimeout:-1 tag:99];
    }
    
}


- (IBAction)manualSwitchAction:(UISwitch *)sender {
    
}
- (IBAction)readToSwitchAction:(UISwitch *)sender {
    
}


@end
