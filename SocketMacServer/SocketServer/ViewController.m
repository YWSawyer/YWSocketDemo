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

@property (nonatomic) GCDAsyncSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    
    _socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    _host.stringValue = @"localhost";
    _port.stringValue = @"8080";
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}
- (IBAction)listennnigOrStop:(NSButton *)sender {
    
    NSError *error = nil;
    BOOL result;
    
    result = [self.socket acceptOnInterface:self.host.stringValue port:[self.port.stringValue integerValue] error:&error];
    self.statusTips.contentView. = [NSString stringWithFormat:@"result:%d, error:%@",result,[error localizedDescription]];

}


@end
