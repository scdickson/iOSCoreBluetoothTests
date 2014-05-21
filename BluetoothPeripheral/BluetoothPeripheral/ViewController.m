//
//  ViewController.m
//  BluetoothPeripheral
//
//  Created by Sam Dickson on 5/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

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
CBMutableCharacteristic *customCharacteristic;
CBMutableCharacteristic *writebackCharacteristic;

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
    
    CBUUID *serviceUUID = [CBUUID UUIDWithString:KServiceUUID];
    CBMutableService *customService = [[CBMutableService alloc] initWithType:serviceUUID primary:YES];
    //[customService setCharacteristics:@[customCharacteristic, writebackCharacteristic]];
    customService.characteristics = [[NSArray alloc] initWithObjects:customCharacteristic, writebackCharacteristic, nil];
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
        [self sendData];
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

- (void)sendData
{
    NSData *data = [self.message.text dataUsingEncoding:NSUTF8StringEncoding];
    
    BOOL didSend = [self.manager updateValue:data forCharacteristic:customCharacteristic onSubscribedCentrals:nil];
    
    if(didSend)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"[Out]:", self.message.text];
        NSLog(@"Okay! I sent some data!");
    }
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
    NSData *worth_a_shot = request.value;
    NSString *stringFromData = [[NSString alloc] initWithData:worth_a_shot encoding:NSUTF8StringEncoding];
    self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"[In]: ", stringFromData];
    NSLog(@"I got some data: %@", stringFromData);
    
    [self.manager respondToRequest:request withResult:CBATTErrorSuccess];
}



@end
