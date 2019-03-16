//
//  RNBluetoothTscPrinter.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/1.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNBluetoothTscPrinter.h"
#import "RNTscCommand.h"
#import "RNBluetoothManager.h"

@implementation RNBluetoothTscPrinter

NSData *toPrint;
RCTPromiseRejectBlock _pendingReject;
RCTPromiseResolveBlock _pendingResolve;
NSInteger now;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

RCT_EXPORT_MODULE(BluetoothTscPrinter);
//printLabel(final ReadableMap options, final Promise promise)
RCT_EXPORT_METHOD(printLabel:(NSDictionary *) options withResolve:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSInteger width = [[options valueForKey:@"width"] integerValue];
    NSInteger height = [[options valueForKey:@"height"] integerValue];
    NSInteger gap = [[options valueForKey:@"gap"] integerValue];
    NSInteger home = [[options valueForKey:@"home"] integerValue];
    NSString *tear = [options valueForKey:@"tear"];
    if(!tear || ![@"ON" isEqualToString:tear]) tear = @"OFF";
    NSArray *texts = [options objectForKey:@"text"];
    NSArray *qrCodes = [options objectForKey:@"qrcode"];
    NSArray *barCodes = [options objectForKey:@"barcode"];
    NSArray *images = [options objectForKey:@"image"];
    NSArray *reverses = [options objectForKey:@"revers"];
    NSInteger direction = [[options valueForKey:@"direction"] integerValue];
    NSInteger density = [[options valueForKey:@"density"] integerValue];
    NSArray* reference = [options objectForKey:@"reference"];
    NSInteger sound = [[options valueForKey:@"sound"] integerValue];
    NSInteger speed = [[options valueForKey:@"speed"] integerValue];
    RNTscCommand *tsc = [[RNTscCommand alloc] init];
    if(speed){
        [tsc addSpeed:[tsc findSpeedValue:speed]];
    }
    if(density){
        [tsc addDensity:density];
    }
    [tsc addSize:width height:height];
    [tsc addGap:gap];
    [tsc addDirection:direction];
    if(reference && [reference count] ==2){
        NSInteger x = [[reference objectAtIndex:0] integerValue];
        NSInteger y = [[reference objectAtIndex:1] integerValue];
        NSLog(@"refernce  %ld y:%ld ",x,y);
        [tsc addReference:x y:y];
    }else{
        [tsc addReference:0 y:0];
    }
    [tsc addTear:tear];
    if(home && home == 1){
      [tsc addBackFeed:16];
      [tsc addHome];
    }
    [tsc addCls];

    //Add Texts
    for(int i=0; texts && i<[texts count];i++){
        NSDictionary * text = [texts objectAtIndex:i];
        NSString *t = [text valueForKey:@"text"];
        NSInteger x = [[text valueForKey:@"x"] integerValue];
        NSInteger y = [[text valueForKey:@"y"] integerValue];
        NSString *fontType = [text valueForKey:@"fonttype"];
        NSInteger rotation = [[text valueForKey:@"rotation"] integerValue];
        NSInteger xscal = [[text valueForKey:@"xscal"] integerValue];
        NSInteger yscal = [[text valueForKey:@"yscal"] integerValue];
        Boolean bold = [[text valueForKey:@"bold"] boolValue];

        [tsc addText:x y:y fontType:fontType rotation:rotation xscal:xscal yscal:yscal text:t];
        if(bold){
            [tsc addText:x+1 y:y fontType:fontType
                rotation:rotation xscal:xscal yscal:yscal  text:t];
            [tsc addText:x y:y+1 fontType:fontType
                rotation:rotation xscal:xscal yscal:yscal  text:t];
        }
    }

  //images
        for (int i = 0; images && i < [images count]; i++) {
            NSDictionary *img = [images objectAtIndex:i];
            NSInteger x = [[img valueForKey:@"x"] integerValue];
            NSInteger y = [[img valueForKey:@"y"] integerValue];
            NSInteger imgWidth = [[img valueForKey:@"width"] integerValue];
            NSInteger mode = [[img valueForKey:@"mode"] integerValue];
            NSString *image  = [img valueForKey:@"image"];
            NSData *imageData = [[NSData alloc] initWithBase64EncodedString:image options:0];
            UIImage *uiImage = [[UIImage alloc] initWithData:imageData];
            [tsc addBitmap:x y:y bitmapMode:mode width:imgWidth bitmap:uiImage];
        }

    //QRCode
    for (int i = 0; qrCodes && i < [qrCodes count]; i++) {
        NSDictionary *qr = [qrCodes objectAtIndex:i];
        NSInteger x = [[qr valueForKey:@"x"] integerValue];
        NSInteger y = [[qr valueForKey:@"y"] integerValue];
        NSInteger qrWidth = [[qr valueForKey:@"width"] integerValue];
        NSString *level = [qr valueForKey:@"level"];
        if(!level)level = @"M";
        NSInteger rotation = [[qr valueForKey:@"rotation"] integerValue];
        NSString *code = [qr valueForKey:@"code"];
        [tsc addQRCode:x y:y errorCorrectionLevel:level width:qrWidth rotation:rotation code:code];
    }

    //BarCode
   for (int i = 0; barCodes && i < [barCodes count]; i++) {
       NSDictionary *bar = [barCodes objectAtIndex:i];
       NSInteger x = [[bar valueForKey:@"x"] integerValue];
       NSInteger y = [[bar valueForKey:@"y"] integerValue];
       NSInteger barWide =[[bar valueForKey:@"wide"] integerValue];
       if(!barWide) barWide = 2;
       NSInteger barHeight = [[bar valueForKey:@"height"] integerValue];
       NSInteger narrow = [[bar valueForKey:@"narrow"] integerValue];
       if(!narrow) narrow = 2;
       NSInteger rotation = [[bar valueForKey:@"rotation"] integerValue];
       NSString *code = [bar valueForKey:@"code"];
       NSString *type = [bar valueForKey:@"type"];
       NSInteger readable = [[bar valueForKey:@"readable"] integerValue];
       [tsc add1DBarcode:x y:y barcodeType:type height:barHeight wide:barWide narrow:narrow readable:readable rotation:rotation content:code];
    }
    for(int i=0; reverses&& i < [reverses count]; i++){
        NSDictionary *area = [reverses objectAtIndex:i];
        NSInteger ax = [[area valueForKey:@"x"] integerValue];
        NSInteger ay = [[area valueForKey:@"y"] integerValue];
        NSInteger aWidth = [[area valueForKey:@"width"] integerValue];
        NSInteger aHeight = [[area valueForKey:@"height"] integerValue];
        [tsc addReverse:ax y:ay xwidth:aWidth yheigth:aHeight];
    }
    [tsc addPrint:1 n:1];
    if (sound) {
        [tsc addSound:2 interval:100];
    }
    _pendingReject = reject;
    _pendingResolve = resolve;
    toPrint = tsc.command;
    now = 0;
    [RNBluetoothManager writeValue:toPrint withDelegate:self];
}

- (void) didWriteDataToBle: (BOOL)success{
    if(success){
        if(_pendingResolve){
            _pendingResolve(nil);
        }
    }else if(_pendingReject){
        _pendingReject(@"PRINT_ERROR",@"PRINT_ERROR",nil);
    }
}

@end
