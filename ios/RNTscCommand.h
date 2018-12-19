//
//  RNTscCommand.h
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/9.
//  Copyright © 2018年 Facebook. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
@interface RNTscCommand : NSObject
@property NSMutableData *command;
-(id)init;
-(id)initWithSize:(NSInteger)width height:(NSInteger) height andGap:(NSInteger)gap;
-(void)addStrToCommand:(NSString *)str;
-(void)addGap:(NSInteger)gap;
-(void)addSize:(NSInteger)width height:(NSInteger) height;
-(void)addCashdrwer:(NSInteger) m/*0,1*/ t1:(NSInteger) t1 t2:(NSInteger) t2;
-(void)addOffset:(NSInteger) offset;
-(void)addSpeed:(float) speed;/*   SPEED1DIV5(1.5F), SPEED2(2.0F), SPEED3(3.0F), SPEED4(4.0F); */

/*   DNESITY0(0), DNESITY1(1), DNESITY2(2), DNESITY3(3), DNESITY4(4), DNESITY5(5), DNESITY6(6), DNESITY7(
 7), DNESITY8(8), DNESITY9(9), DNESITY10(10), DNESITY11(11), DNESITY12(12), DNESITY13(13), DNESITY14(
 14), DNESITY15(15) */
-(void)addDensity:(NSInteger)density;
-(void)addDirection:(NSInteger) direction;/*  FORWARD(0), BACKWARD(1);*/
-(void)addReference:(NSInteger) x y:(NSInteger) y;
-(void)addShif:(NSInteger) shif;
-(void)addCls;
-(void)addFeed:(NSInteger) dot;
-(void)addBackFeed:(NSInteger) backDot;
-(void)addFormFeed;
-(void)addHome;
-(void)addPrint:(NSInteger) m n:(NSInteger) n;

/*       PC437(437), PC850(850), PC852(852), PC860(860), PC863(863), PC865(865), WPC1250(1250), WPC1252(1252), WPC1253(
 1253), WPC1254(1254);  */
-(void)addCodePage:(NSInteger) page;
-(void)addSound:(NSInteger) level  interval:(NSInteger) interval;
-(void)addLimitFeed:(NSInteger) n;
-(void)addSelfTest;

-(void)addBar:(NSInteger) x y:(NSInteger) y
        width:(NSInteger) width heigth:(NSInteger) height;

-(void)addText:(NSInteger) x y:(NSInteger) y
      fontType:(NSString *) font rotation:(NSInteger) rotation
         xscal:(NSInteger) Xscal yscal:(NSInteger) Yscal
          text:(NSString *) text;

-(void)add1DBarcode:(NSInteger) x y:(NSInteger) y
        barcodeType:(NSString *) type height:(NSInteger) height
        wide:(NSInteger) wide narrow:(NSInteger) narrow
           readable:(NSInteger) readable rotation:(NSInteger) rotation
            content:(NSString *) content;
-(void)addQRCode:(NSInteger) x y:(NSInteger) y errorCorrectionLevel:(NSString *) level
           width:(NSInteger) qrWidth rotation:(NSInteger) rotation
            code:(NSString *) code;

-(void)addBitmap:(NSInteger) x y:(NSInteger) y
      bitmapMode:(NSInteger) mode width:(NSInteger) nWidth
          bitmap:(UIImage *) b;
-(void)addBox:(NSInteger) x y:(NSInteger) y xend:(NSInteger) xend yend:(NSInteger) yend;
-(void)addErase:(NSInteger) x y:(NSInteger) y xwidth:(NSInteger) xwidth yheigth:(NSInteger) yheight;
-(void)addReverse:(NSInteger) x y:(NSInteger) y xwidth:(NSInteger) xwidth yheigth:(NSInteger) yheight;
-(void)addPeel:(NSString *) enable;
-(void)addTear:(NSString *) enable;
-(void)addCutter:(NSString *) enable;
-(void)addPartialCutter :(NSString *) enable;

-(float)findSpeedValue:(NSInteger) sp;

@end
