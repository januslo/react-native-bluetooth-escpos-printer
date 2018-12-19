//
//  RNTscCommand.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/9.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RNTscCommand.h"
#import "ImageUtils.h"
@implementation RNTscCommand
-(id)init
{
    _command = [[NSMutableData alloc] init];
    return self;
}
-(id)initWithSize:(NSInteger)width height:(NSInteger) height andGap:(NSInteger)gap
{
    _command = [[NSMutableData alloc] init];
    [self addSize:width height:height];
    [self addGap:gap];
    return self;
}
-(void)addStrToCommand:(NSString *)str
{
    if(str){
    //encoding GBK? UTF-8? GB2312?
        [_command appendData:[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)]];
    }
}
-(void)addGap:(NSInteger)gap
{
    [self addStrToCommand:[NSString stringWithFormat:@"GAP %lu mm,%d mm\r\n",(int)gap,0]];
}
-(void)addSize:(NSInteger)width height:(NSInteger) height
{
     [self addStrToCommand:[NSString stringWithFormat:@"SIZE %ld mm,%ld mm\r\n",width,height]];
}
-(void)addCashdrwer:(NSInteger) m/*0,1*/ t1:(NSInteger) t1 t2:(NSInteger) t2
{
      [self addStrToCommand:[NSString stringWithFormat:@"CASHDRAWER %ld,%ld,%ld\r\n",m,t1,t2]];
}
-(void)addOffset:(NSInteger) offset
{
      [self addStrToCommand:[NSString stringWithFormat:@"OFFSET %ld mm\r\n",offset]];
}

/*   SPEED1DIV5(1.5F), SPEED2(2.0F), SPEED3(3.0F), SPEED4(4.0F){ } */
-(void)addSpeed:(float) speed
{
      [self addStrToCommand:[NSString stringWithFormat:@"SPEED %f\r\n",speed]];
}

/*   DNESITY0(0), DNESITY1(1), DNESITY2(2), DNESITY3(3), DNESITY4(4), DNESITY5(5), DNESITY6(6), DNESITY7(
 7), DNESITY8(8), DNESITY9(9), DNESITY10(10), DNESITY11(11), DNESITY12(12), DNESITY13(13), DNESITY14(
 14), DNESITY15(15) */
-(void)addDensity:(NSInteger)density
{
      [self addStrToCommand:[NSString stringWithFormat:@"DENSITY %ld\r\n",density]];
}

/*  FORWARD(0), BACKWARD(1){ }*/
-(void)addDirection:(NSInteger) direction
{
    [self addStrToCommand:[NSString stringWithFormat:@"DIRECTION %ld\r\n",direction]];
}

-(void)addReference:(NSInteger) x y:(NSInteger) y
{
      [self addStrToCommand:[NSString stringWithFormat:@"REFERENCE %ld,%ld\r\n",x,y]];
}
-(void)addShif:(NSInteger) shif
{
      [self addStrToCommand:[NSString stringWithFormat:@"SHIFT %ld\r\n",shif]];
}
-(void)addCls
{
      [self addStrToCommand:@"CLS\r\n"];
}
-(void)addFeed:(NSInteger) dot
{
      [self addStrToCommand:[NSString stringWithFormat:@"FEED %ld\r\n",dot]];
}
-(void)addBackFeed:(NSInteger) backDot
{
      [self addStrToCommand:[NSString stringWithFormat:@"BACKFEED %ld\r\n",backDot]];
}
-(void)addFormFeed
{
    [self addStrToCommand:@"FORMFEED\r\n"];
}
-(void)addHome
{
      [self addStrToCommand:@"HOME\r\n"];
}
-(void)addPrint:(NSInteger) m n:(NSInteger) n
{
      [self addStrToCommand:[NSString stringWithFormat:@"PRINT %ld,%ld\r\n",m,n]];
}

/*       PC437(437), PC850(850), PC852(852), PC860(860), PC863(863), PC865(865), WPC1250(1250), WPC1252(1252), WPC1253(
 1253), WPC1254(1254){ }  */
-(void)addCodePage:(NSInteger) page
{
      [self addStrToCommand:[NSString stringWithFormat:@"CODEPAGE %ld\r\n",page]];
}
-(void)addSound:(NSInteger) level  interval:(NSInteger) interval
{
      [self addStrToCommand:[NSString stringWithFormat:@"SOUND %ld,%ld\r\n",level,interval]];
}
-(void)addLimitFeed:(NSInteger) n
{
      [self addStrToCommand:[NSString stringWithFormat:@"LIMITFEED %ld\r\n",n]];
}
-(void)addSelfTest
{
      [self addStrToCommand:@"SELFTEST\r\n"];
}

-(void)addBar:(NSInteger) x y:(NSInteger) y
width:(NSInteger) width heigth:(NSInteger) height
{
      [self addStrToCommand:[NSString stringWithFormat:@"BAR %ld,%ld,%ld,%ld\r\n",
                             x,y,width,height]];
}

-(void)addText:(NSInteger) x y:(NSInteger) y
fontType:(NSString *) font rotation:(NSInteger) rotation
xscal:(NSInteger) Xscal yscal:(NSInteger) Yscal
text:(NSString *) text
{
    [self addStrToCommand:[NSString stringWithFormat:@"TEXT %ld,%ld,\"%@\",%ld,%ld,%ld,\"%@\"\r\n",
                           x,y,font,rotation,Xscal,Yscal,text]];
}

-(void)add1DBarcode:(NSInteger) x y:(NSInteger) y
barcodeType:(NSString *) type height:(NSInteger) height
  wide:(NSInteger) wide narrow:(NSInteger) narrow
readable:(NSInteger) readable rotation:(NSInteger) rotation
content:(NSString *) content
{
    //str = "BARCODE " + x + "," + y + "," + "\"" + type.getValue() + "\"" + "," + height + "," + readable.getValue()
   // + "," + rotation.getValue() + "," + narrow + "," + wide + "," + "\"" + content + "\"" + "\r\n";
    NSString *c =[NSString stringWithFormat:@"BARCODE %ld,%ld,\"%@\",%ld,%ld,%ld,%d,%d,\"%@\"\r\n",
                  x,y,type,height,readable,rotation,narrow,wide,content];
    NSLog(@"BARCODE COMMAND:%@",c);
    [self addStrToCommand:c];
}

-(void)addQRCode:(NSInteger) x y:(NSInteger) y errorCorrectionLevel:(NSString *) level
width:(NSInteger) qrWidth rotation:(NSInteger) rotation
code:(NSString *) code
{
    [self addStrToCommand:[NSString stringWithFormat:@"QRCODE %ld,%ld,%@,%ld,A,%ld,M2,S1,\"%@\"\r\n",
                           x,y,level,qrWidth,rotation,code]];
}

-(void)addBitmap:(NSInteger) x y:(NSInteger) y
bitmapMode:(NSInteger) mode width:(NSInteger) nWidth
bitmap:(UIImage *) b{
    //todo: NEED TO IMPLEMENT>>>>>>
    if (b) {
        CGFloat imgWidth = b.size.width;
        CGFloat imgHeigth = b.size.height;
        NSInteger width = (nWidth + 7) / 8 * 8;
        NSInteger height = imgHeigth * width / imgWidth;
        UIImage *resized = [ImageUtils imageWithImage:b scaledToFillSize:CGSizeMake(width, height)];
        uint8_t * graybits = [ImageUtils imageToGreyImage:resized];
        NSInteger srcLen = (int)resized.size.width*resized.size.height;
        NSData *codecontent = [ImageUtils pixToTscCmd:graybits width:srcLen];
        height = srcLen / width;
        width /= 8;
        NSString *str =[NSString stringWithFormat:@ "BITMAP %ld,%ld,%ld,%ld,%ld,",
                        x,y,width,height,mode];
        [self addStrToCommand:str];
        [_command appendData:codecontent];
        [self addStrToCommand:@"\r\n"];
    }
    
}
-(void)addBox:(NSInteger) x y:(NSInteger) y xend:(NSInteger) xend yend:(NSInteger) yend
{
    [self addStrToCommand:[NSString stringWithFormat:@"BAR %ld,%ld,%ld,%ld\r\n",
                           x,y,xend,yend]];
}
-(void)addErase:(NSInteger) x y:(NSInteger) y xwidth:(NSInteger) xwidth yheigth:(NSInteger) yheight
{
    [self addStrToCommand:[NSString stringWithFormat:@"ERASE %ld,%ld,%ld,%ld\r\n",
                           x,y,xwidth,yheight]];
}
-(void)addReverse:(NSInteger) x y:(NSInteger) y xwidth:(NSInteger) xwidth yheigth:(NSInteger) yheight
{
    [self addStrToCommand:[NSString stringWithFormat:@"REVERSE %ld,%ld,%ld,%ld\r\n",
                           x,y,xwidth,yheight]];
}
-(void)addPeel:(NSString *) enable
{
    [self addStrToCommand:[NSString stringWithFormat:@"SET PEEL %@\r\n",enable]];
}
-(void)addTear:(NSString *) enable
{
      [self addStrToCommand:[NSString stringWithFormat:@"SET TEAR %@\r\n",enable]];
}
-(void)addCutter:(NSString *) enable
{
      [self addStrToCommand:[NSString stringWithFormat:@"SET CUTTER %@\r\n",enable]];
}
-(void)addPartialCutter :(NSString *) enable
{
     [self addStrToCommand:[NSString stringWithFormat:@"SET PARTIAL_CUTTER %@\r\n",enable]];
}

-(float)findSpeedValue:(NSInteger) sp{
    // SPEED1DIV5(1.5F), SPEED2(2.0F), SPEED3(3.0F), SPEED4(4.0F);
    switch (sp) {
        case 2:
            return 2.0f;
            break;
        case 3:
            return 3.0f;
            break;
        case 4:
            return 4.0f;
            break;
        case 1:
        default:
            return 1.5f;
            break;
    }
}
@end
