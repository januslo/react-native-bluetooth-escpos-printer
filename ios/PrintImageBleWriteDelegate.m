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
        if(_now == -1){
             if(_pendingResolve) {_pendingResolve(nil); _pendingResolve=nil;}
        }else if(_now>=[_toPrint length]){
//            ASCII ESC M 0 CR LF
//            Hex 1B 4D 0 0D 0A
//            Decimal 27 77 0 13 10
            unsigned char * initPrinter = malloc(5);
            initPrinter[0]=27;
            initPrinter[1]=77;
            initPrinter[2]=0;
            initPrinter[3]=13;
            initPrinter[4]=10;
            [RNBluetoothManager writeValue:[NSData dataWithBytes:initPrinter length:5] withDelegate:self];
            _now = -1;
            [NSThread sleepForTimeInterval:0.01f];
        }else {
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
     NSInteger sizePerLine = (int)(_width/8);
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
