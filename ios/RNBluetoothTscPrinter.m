//
//  RNBluetoothTscPrinter.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/1.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNBluetoothTscPrinter.h"

@implementation RNBluetoothTscPrinter

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE(BluetoothTscPrinter);
RCT_EXPORT_METHOD(selfTest)
{
    
}
@end
