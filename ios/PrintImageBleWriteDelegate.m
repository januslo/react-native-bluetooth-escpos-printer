//
//  PrintImageBleWriteDelegate.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/8.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintImageBleWriteDelegate.h"
@implementation PrintImageBleWriteDelegate


- (void) didWriteDataToBle: (BOOL)success
{NSLog(@"PrintImageBleWriteDelete diWriteDataToBle: %d",success?1:0);
    if(success){
        if(_now>=[_toPrint length]){
            if(_pendingResolve) {_pendingResolve(nil); _pendingResolve=nil;}
        }else{
            [self print];
        }
    }else if(_pendingReject){
        _pendingReject(@"PRINT_IMAGE_FAILED",@"PRINT_IMAGE_FAILED",nil);
        _pendingReject = nil;
    }
    
}

-(void) print
{
    @synchronized (self) {
     NSInteger sizePerLine = ((_width+7)/8+8);
   // do{
//        if(sizePerLine+_now>=[_toPrint length]){
//            sizePerLine = [_toPrint length] - _now;
//        }
       // if(sizePerLine>0){
            NSData *subData = [_toPrint subdataWithRange:NSMakeRange(_now, sizePerLine)];
            NSLog(@"Write data:%@",subData);
            [RNBluetoothManager writeValue:subData withDelegate:self];
        //}
        _now = _now+sizePerLine;
        [NSThread sleepForTimeInterval:0.01f];
        
    }
    //}while(_now<[_toPrint length]);
}
@end
