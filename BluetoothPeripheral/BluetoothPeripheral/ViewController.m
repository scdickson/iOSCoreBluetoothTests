//
//  ViewController.m
//  BluetoothPeripheral
//
//  Created by Sam Dickson on 5/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"
#define MTU 20

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *console;
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UIButton *send;
@property (weak, nonatomic) IBOutlet UIButton *stop_advertising;
@property (weak, nonatomic) IBOutlet UILabel *status;

@end

@implementation ViewController

static NSString* const KServiceUUID = @"DFE668D5-CE9A-4C72-86FE-3291242F7564";
static NSString* const KCharacteristicReadableUUID = @"EC0D2E22-3C43-45BB-9F4A-169B8681F64B";
static NSString* const KCharacteristicWriteableUUID = @"828EE34B-7521-4A38-AA32-B64F97789FAF";
static NSString* const KCharacteristicDataUUID = @"35B51187-03C5-4974-B30E-24D750F92321";

static NSString *const RANDOM = @"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";

CBMutableCharacteristic *customCharacteristic;
CBMutableCharacteristic *writebackCharacteristic;
CBMutableCharacteristic *dataCharacteristic;
NSMutableData *recvData;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    switch(peripheral.state)
    {
        case CBPeripheralManagerStatePoweredOn:
            //self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Advertising..."];
            NSLog(@"Advertising...");
            [self setupService];
            break;
        default:
            NSLog(@"Bluetooth LE unsupported.");
            //self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Bluetooth LE is unsupported."];
            break;
    }
    
}

- (void)setupService
{
    CBUUID *characteristicUUID = [CBUUID UUIDWithString:KCharacteristicReadableUUID];
    customCharacteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    CBUUID *writebackUUID = [CBUUID UUIDWithString:KCharacteristicWriteableUUID];
    writebackCharacteristic = [[CBMutableCharacteristic alloc] initWithType:writebackUUID properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    
    CBUUID *dataUUID = [CBUUID UUIDWithString:KCharacteristicDataUUID];
    dataCharacteristic = [[CBMutableCharacteristic alloc] initWithType:dataUUID properties:CBCharacteristicPropertyWrite|CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsWriteable];
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:KServiceUUID];
    CBMutableService *customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    //[customService setCharacteristics:@[customCharacteristic, writebackCharacteristic]];
    customService.characteristics = [[NSArray alloc] initWithObjects:customCharacteristic, writebackCharacteristic, dataCharacteristic, nil];
    [self.manager addService:customService];
}

- (void)peripheralManager:(CBPeripheralManager*)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if(error == nil)
    {
        //self.console.text = [NSString stringWithFormat:@"%@\n%@",  self.console.text, @"Beginning advertisement..."];
        NSLog(@"Beginning advertisement...");
        [self.manager startAdvertising:@{CBAdvertisementDataLocalNameKey : @"SCD Peripheral", CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:KServiceUUID]]}];
    }
    else
    {
        //self.console.text = [NSString stringWithFormat:@"%@\n%@ %@",  self.console.text, @"Error: ", [error localizedDescription]];
        NSLog(@"Error: %@", [error localizedDescription]);
        
    }
}

- (void)peripheralManager:(CBPeripheralManager*)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Someone subscribed to my characteristic: %@", [central description]);
    self.status.text = [NSString stringWithFormat:@"Connected to %@", [central.identifier UUIDString]];
    //self.console.text = [NSString stringWithFormat:@"%@\n%@ %@",  self.console.text, @"Someone subscribed to my characteristic: ", [characteristic UUID]];
}

- (IBAction)sendClicked:(id)sender
{
    if(self.message.text != nil)
    {
        self.data = [self.message.text dataUsingEncoding:NSUTF8StringEncoding];
        self.dataIndex = 0;
        [self sendData];
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"[Out]: ", self.message.text];
        self.message.text = @"";
    }
}

- (IBAction)stopAdvertisingClicked:(id)sender
{
    if([self.manager isAdvertising])
    {
        [self.manager stopAdvertising];
        [self.stop_advertising setTitle:@"Start Advertising" forState:UIControlStateNormal];
        [self.stop_advertising setBackgroundColor:[UIColor greenColor]];
        //self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Stopped advertising."];
    }
    else
    {
        [self setupService];
        [self.stop_advertising setTitle:@"Stop Advertising" forState:UIControlStateNormal];
        [self.stop_advertising setBackgroundColor:[UIColor redColor]];
        self.console.text = @"";
        //self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Advertising..."];
    }
}

- (IBAction)sendDataClicked:(id)sender
{
    self.data = [RANDOM dataUsingEncoding:NSUTF8StringEncoding];
    self.console.text = [NSString stringWithFormat:@"%@\n%@ %ld %@", self.console.text, @"SENDING ", (long) self.data.length, @" bytes of data..."];
    self.dataIndex = 0;
    [self sendData];
}

- (void)sendData
{
    static BOOL sendEOM = NO;
    
    if(sendEOM)
    {
        BOOL didSend = [self.manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
        
        if(didSend)
        {
            sendEOM = NO;
        }
        
        return;
    }
    
    if(self.dataIndex >= self.data.length)
    {
        return;
    }
    
    BOOL didSend = YES;
    
    while(didSend)
    {
        NSInteger sendAmt = self.data.length - self.dataIndex;
        
        if(sendAmt > MTU)
        {
            sendAmt = MTU;
        }
        
        NSData *packet = [NSData dataWithBytes:self.data.bytes+self.dataIndex length:sendAmt];
        didSend = [self.manager updateValue:packet forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
        
        if(!didSend)
        {
            return;
        }
        
        NSString *stringFromPacket = [[NSString alloc] initWithData:packet encoding:NSUTF8StringEncoding];
        NSLog(@"Sent piece: %@", stringFromPacket);
        
        self.dataIndex += sendAmt;
        
        if(self.dataIndex >= self.data.length)
        {
            sendEOM = YES;
            BOOL eomSent = [self.manager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
            
            if(eomSent)
            {
                sendEOM = NO;
                NSLog(@"Sent EOM");
            }
            
            return;
        }
    }
    
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self sendData];
}

- (void)peripheralManager:(CBPeripheralManager*)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    //self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Someone unsubscribed from my characteristic..."];
    [self.status setText:@"Not Connected"];
    NSLog(@"Someone unsubscribed from my characteristic...");
}


- (void)peripheralManager:(CBPeripheralManager*)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    NSLog(@"Received a request from Central.");
    
    CBATTRequest *request = [requests objectAtIndex:0];
    NSData *tmp = request.value;
    NSString *stringFromData = [[NSString alloc] initWithData:tmp encoding:NSUTF8StringEncoding];
    
    if(request.characteristic == dataCharacteristic)
    {
        NSLog(@"Got DATA: %@", tmp.description);
    }
    else if(request.characteristic == writebackCharacteristic)
    {
        NSLog(@"Got TEXT!");
        if([stringFromData isEqualToString:@"EOM"])
        {
            if(recvData != nil)
            {
                NSString *final = [[NSString alloc] initWithData:recvData encoding:NSUTF8StringEncoding];
                self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"[In]: ", final];
                recvData = nil;
            }
        }
        else
        {
            if(recvData == nil)
            {
                recvData = [[NSMutableData alloc] initWithData:tmp];
            }
            else
            {
                [recvData appendData:tmp];
            }
        }
    }

    
    [self.manager respondToRequest:request withResult:CBATTErrorSuccess];
}



@end
