//
//  PrintImageBleWriteDelegate.h
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/8.
//  Copyright © 2018年 Facebook. All rights reserved.
//
#import <React/RCTBridgeModule.h>
#import "RNBluetoothManager.h"
#import "RNBluetoothEscposPrinter.h"
@interface PrintImageBleWriteDelegate :NSObject<WriteDataToBleDelegate>
@property NSData *toPrint;
@property NSInteger width;
@property NSInteger now;
@property RNBluetoothManager *printer;
@property RCTPromiseRejectBlock pendingReject;
@property RCTPromiseResolveBlock pendingResolve;
-(void) print;
@end
