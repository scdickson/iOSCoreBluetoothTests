//
//  ViewController.h
//  BluetoothPeripheral
//
//  Created by Sam Dickson on 5/20/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController : UIViewController <CBPeripheralManagerDelegate>
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, readwrite) NSInteger dataIndex;
@property (nonatomic, strong) NSData *data;
@end
