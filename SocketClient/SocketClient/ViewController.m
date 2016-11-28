//
//  ViewController.m
//  SocketClient
//
//  Created by BDHT-MAC on 25/11/2016.
//  Copyright © 2016 BDHT-MAC. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *host;
@property (weak, nonatomic) IBOutlet UITextField *port;
@property (weak, nonatomic) IBOutlet UITextView *errorText;

@property (nonatomic) GCDAsyncSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _host.text = @"23.33.22";
    _port.text = @"8080";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)startConnectServer:(UIButton *)sender {
    
    NSError *error = nil;
    BOOL result;
    
    result = [self.socket connectToHost:self.host.text onPort:[self.port.text integerValue] error:&error];
    self.errorText.text = [NSString stringWithFormat:@"result:%d, error:%@",result,[error localizedDescription]];
}
- (IBAction)disconect:(id)sender {
    
    [self.socket disconnect];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    
     self.errorText.text = [NSString stringWithFormat:@"new socket:%@",host];
     NSLog(@"%@",self.errorText.text);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    self.errorText.text = [NSString stringWithFormat:@"disconnect error:%@",[err localizedDescription]];
    NSLog(@"%@",self.errorText.text);
}



@end
