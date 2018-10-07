//
//  PrintColumnBleWriteDelegate.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/6.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrintColumnBleWriteDelegate.h"
@implementation PrintColumnBleWriteDelegate

NSMutableArray<NSMutableString *>  *columns;
NSInteger maxRowCount;

- (void)didWriteDataToBle:(BOOL)success {NSLog(@"Call back deletgate: %lu",_now+1);
    if(_canceled){
           if(_pendingReject) _pendingReject(@"ERROR_IN_PRINT_COLUMN",@"ERROR_IN_PRINT_COLUMN",nil);
        return;
    }
    _now = _now+1;
    if(_now >= maxRowCount){
        if(_error && _pendingReject){
            _pendingReject(@"ERROR_IN_PRINT_COLUMN",@"ERROR_IN_PRINT_COLUMN",nil);
        }else if(_pendingResolve){
            _pendingResolve(nil);
        }
    }else{
        if(!success){
            _error = true;
        }
        [self print];
    }
    [NSThread sleepForTimeInterval:0.05f];//slow down.
}
-(void)printColumn:( NSMutableArray<NSMutableString *> *)columnsToPrint withMaxcount:(NSInteger)maxcount{
    columns = columnsToPrint;
    maxRowCount = maxcount;
    [self print];
}
-(void)print{
    [(NSMutableString *)[columns objectAtIndex:_now] appendString:@"\n\r"];//wrap line..
    @try {
        [self.printer textPrint:[columns objectAtIndex:_now] inEncoding:_encodig withCodePage:_codePage widthTimes:_widthTimes heightTimes:_heightTimes fontType:_fontType delegate:self];
    }
    @catch (NSException *e){
        NSLog(@"ERROR IN PRINTING COLUMN:%@",e);
        _pendingReject(@"ERROR_IN_PRINT_COLUMN",@"ERROR_IN_PRINT_COLUMN",nil);
        self.canceled = true;
    }
}

@end;
