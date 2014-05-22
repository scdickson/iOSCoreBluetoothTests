//
//  ViewController.h
//  BluetoothCentral
//
//  Created by Sam Dickson on 5/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (strong, nonatomic) CBCentralManager *manager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) CBCharacteristic *peripheralCharacteristic;
@property (strong, nonatomic) CBCharacteristic *writebackCharacteristic;
@property (strong, nonatomic) CBCharacteristic *dataCharacteristic;
@property (nonatomic, readwrite) NSInteger dataIndex;
@property (strong, nonatomic) NSData *data;
@end
