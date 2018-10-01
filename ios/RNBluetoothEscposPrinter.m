
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RNBluetoothManager.h"
#import "RNBluetoothEscposPrinter.h"

@implementation RNBluetoothEscposPrinter

int WIDTH_58 = 384;
int WIDTH_80 = 576;
NSInteger ESC = 0x1b;
NSInteger FS = 0x1C;
NSInteger GS = 0x1D;
NSInteger US = 0x1F;
NSInteger DLE = 0x10;
NSInteger DC4 = 0x14;
NSInteger DC1 = 0x11;
NSInteger SP = 0x20;
NSInteger NL = 0x0A;
NSInteger FF = 0x0C;
NSInteger PIECE = 0xFF;
NSInteger NUL =  0x00;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


/**
 * Exports the constants to javascritp.
 **/
- (NSDictionary *)constantsToExport
{
    return @{ @"width58":[NSString stringWithFormat:@"%i", WIDTH_58],
              @"width80":[NSString stringWithFormat:@"%i", WIDTH_80]};
}

RCT_EXPORT_MODULE(BluetoothEscposPrinter);

/**
 * Sets the current deivce width
 **/
RCT_EXPORT_METHOD(setWidth:(int) width)
{
    self.deviceWidth = width;
}

//public void printerInit(final Promise promise){
//    if(sendDataByte(PrinterCommand.POS_Set_PrtInit())){
//        promise.resolve(null);
//    }else{
//        promise.reject("COMMAND_NOT_SEND");
//    }
//}

RCT_EXPORT_METHOD(printerInit:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if(RNBluetoothManager.isConnected){
        NSMutableData *data = [[NSMutableData alloc] init];
        NSInteger at = (int)'@';
        [data appendBytes:ESC length:sizeof(ESC)];
        [data appendBytes:at length:sizeof(at)];
//        [RNBluetoothManager.connectedDevice writeValue:data forCharacteristic:[RNBluetoothManager.connectedDevice get]  type:<#(CBCharacteristicWriteType)#>];
    }else{
        reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
    
}

@end
