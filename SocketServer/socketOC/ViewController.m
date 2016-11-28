//
//  ViewController.m
//  socketOC
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
    _host.text = @"localhost";
    _port.text = @"8080";
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startListenning:(id)sender {
    
    NSError *error = nil;
    BOOL result;
    
    result = [self.socket acceptOnInterface:self.host.text port:[self.port.text integerValue] error:&error];
    self.errorText.text = [NSString stringWithFormat:@"result:%d, error:%@",result,[error localizedDescription]];
    
}
- (IBAction)disconncet:(UIButton *)sender {
    
    [self.socket disconnect];
}


- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    
    self.errorText.text = [NSString stringWithFormat:@"new socket:%@",newSocket.localHost];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err{
    
    self.errorText.text = [NSString stringWithFormat:@"disconnect error:%@",[err localizedDescription]];
    NSLog(@"%@",self.errorText.text);
}

@end
