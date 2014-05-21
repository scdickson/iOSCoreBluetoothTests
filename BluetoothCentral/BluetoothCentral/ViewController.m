//
//  ViewController.m
//  BluetoothCentral
//
//  Created by Sam Dickson on 5/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *message;
@property (weak, nonatomic) IBOutlet UIButton *send;
@property (weak, nonatomic) IBOutlet UITextView *console;
@property (weak, nonatomic) IBOutlet UIButton *disconnect;

@end

@implementation ViewController

static NSString* const KServiceUUID = @"DFE668D5-CE9A-4C72-86FE-3291242F7564";
static NSString* const KCharacteristicReadableUUID = @"EC0D2E22-3C43-45BB-9F4A-169B8681F64B";
static NSString* const KCharacteristicWriteableUUID = @"828EE34B-7521-4A38-AA32-B64F97789FAF";

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch(central.state)
    {
        case CBCentralManagerStatePoweredOn:
            [self.manager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:KServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
            self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Scanning for peripherals..."];
            NSLog(@"Scanning for peripherals...");
            break;
        default:
            self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Bluetooth LE is unsupported!"];
            NSLog(@"Bluetooth LE is unsupported.");
            break;
    }
}

- (IBAction)sendClicked:(id)sender
{
    NSData *data = [self.message.text dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheral writeValue:data forCharacteristic:self.writebackCharacteristic type:CBCharacteristicWriteWithoutResponse];
    self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Sent data:", self.message.text];
    NSLog(@"Okay! I sent some data!");
    self.message.text = @"";
    [self.view endEditing:YES];
    

}

- (IBAction)disconnectClicked:(id)sender
{
    [self.manager cancelPeripheralConnection:self.peripheral];
    self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Disconnected from Peripheral."];
    [self.disconnect setEnabled:NO];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Error writing to characteristic:", [error localizedDescription]];
        NSLog(@"Error writing to characteristic: %@ (code %d)", [error localizedDescription], [error code]);
    }
}

- (void)centralManager:(CBCentralManager*)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Found peripheral! Stopping scan."];
    [self.manager stopScan];
    
    if(self.peripheral != peripheral)
    {
        self.peripheral = peripheral;
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Connecting to peripheral: ", peripheral];
        NSLog(@"Connecting to peripheral %@", peripheral);
    [   self.manager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager*)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self.data setLength:0];
    [self.peripheral setDelegate:self];
    self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Connected!"];
    [self.peripheral discoverServices:@[[CBUUID UUIDWithString:KServiceUUID]]];
    [self.disconnect setEnabled:YES];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if(error)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Error discovering service: ", [error localizedDescription]];
        NSLog(@"Error discovering service: %@", [error localizedDescription]);
        //[self cleanup];
        return;
    }
    
    for(CBService *service in peripheral.services)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Found service with UUID: ", service.UUID];
        NSLog(@"Found service with UUID: %@", service.UUID);
        if([service.UUID isEqual:[CBUUID UUIDWithString:KServiceUUID]])
        {
            [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:KCharacteristicReadableUUID]] forService:service];
            [self.peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:KCharacteristicWriteableUUID]] forService:service];
        }
    
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if(error)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Error discovering characteristic: ", [error localizedDescription]];
        NSLog(@"Error discovering characteristic: %@", [error localizedDescription]);
        return;
    }
    
    if([service.UUID isEqual:[CBUUID UUIDWithString:KServiceUUID]])
    {
        for(CBCharacteristic *characteristic in service.characteristics)
        {
            //self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Discovered characteristic with UUID: ", characteristic.UUID];
            //NSLog(@"Discovered characteristic with UUID: %@", characteristic.UUID);
            
            if([characteristic.UUID isEqual:[CBUUID UUIDWithString:KCharacteristicReadableUUID]])
            {
                self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Discovered READABLE characteristic."];
                self.peripheralCharacteristic = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:self.peripheralCharacteristic];
            }
            else if([characteristic.UUID isEqual:[CBUUID UUIDWithString:KCharacteristicWriteableUUID]])
            {
                self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Discovered WRITABLE characteristic."];
                self.writebackCharacteristic = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:self.writebackCharacteristic];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral*)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Error changing notification state: ", [error localizedDescription]];
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
        return;
    }
    
    if(!([characteristic.UUID isEqual:[CBUUID UUIDWithString:KCharacteristicReadableUUID]] || [characteristic.UUID isEqual:[CBUUID UUIDWithString:KCharacteristicWriteableUUID]]))
    {
        return;
    }
    
    if(characteristic.isNotifying)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Notification began on ", characteristic];
        NSLog(@"Notification began on %@", characteristic);
        [peripheral readValueForCharacteristic:characteristic];
    }
    else
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Notification stopped on ", characteristic];
        NSLog(@"Notification has stopped on %@", characteristic);
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if(error)
    {
        self.console.text = [NSString stringWithFormat:@"%@\n%@", self.console.text, @"Error reading updated characteristic value: ", [error localizedDescription]];
        NSLog(@"Error reading updated characteristic value: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    self.console.text = [NSString stringWithFormat:@"%@\n%@ %@", self.console.text, @"Received data: ", stringFromData];
    NSLog(@"I got some data: %@", stringFromData);
}

@end
