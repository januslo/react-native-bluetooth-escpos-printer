
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RNBluetoothManager.h"
#import "RNBluetoothEscposPrinter.h"
#import "ColumnSplitedString.h"
#import "PrintColumnBleWriteDelegate.h"
#import "ImageUtils.h"
#import "ZXingObjC/ZXingObjC.h"
#import "PrintImageBleWriteDelegate.h"
@implementation RNBluetoothEscposPrinter

int WIDTH_58 = 384;
int WIDTH_80 = 576;
Byte ESC[] = {0x1b};
//NSInteger ESC = 0x1b;
Byte ESC_FS[] = {0x1c};
//NSInteger FS = 0x1C;
Byte ESC_GS[] = {0x1D};
Byte US[] = {0x1F};
Byte DLE[] = {0x10};
Byte DC4[] = {0x14};
Byte DC1[] = {0x11};
Byte SP[] = {0x20};
Byte NL[] = {0x0A};
Byte FF[] = {0x0C};
Byte PIECE[] = {0xFF};
Byte NUL[] =  {0x00};
Byte SIGN[] = {0x21};//!
Byte T[] = {0x74};//t
Byte AND[] ={0x26}; //&
Byte M[] = {0x4d};//M
Byte V[] = {0x56};//V
Byte A[] = {0x61};//a
Byte E[] = {0x45};//E
Byte G[] = {0x47};//G

RCTPromiseResolveBlock pendingResolve;
RCTPromiseRejectBlock pendingReject;

-(id)init {
    if (self = [super init])  {
        self.deviceWidth = WIDTH_58;
    }
    return self;
}


- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
+ (BOOL)requiresMainQueueSetup
{
    return YES;
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
        Byte at[] = {'@'};
        [data appendBytes:ESC length:1];
        [data appendBytes:at length:1];
        pendingResolve = resolve;
        pendingReject = reject;
        [RNBluetoothManager writeValue:data withDelegate:self];
    }else{
        reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
    
}

//{GS, 'L', 0x00 , 0x00 }
// data[2] = (byte) (left % 100);
//data[3] = (byte) (left / 100);
RCT_EXPORT_METHOD(printerLeftSpace:(int) sp
                  withResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if(sp>255 || sp<0){
        reject(@"COMMAND_NOT_SEND",@"INVALID_VALUE",nil);
        return;
    }
    
    if(RNBluetoothManager.isConnected){
        NSMutableData *data = [[NSMutableData alloc] init];
        Byte left[] = {'L'};
        Byte sp_up[] = {(sp%100)};
        Byte sp_down[] = {(sp/100)};
        [data appendBytes:ESC_GS length:1];
        [data appendBytes:left length:1];
        [data appendBytes:sp_up length:1];
        [data appendBytes:sp_down length:1];
        pendingResolve = resolve;
        pendingReject = reject;
        [RNBluetoothManager writeValue:data withDelegate:self];
    }else{
        reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
}

//{ESC, 45, 0x00 };
//{FS, 45, 0x00 };
RCT_EXPORT_METHOD(printerUnderLine:(int)sp withResolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{
    if(sp<0 || sp>2){
          reject(@"COMMAND_NOT_SEND",@"INVALID_VALUE",nil);
        return;
    }
    if(RNBluetoothManager.isConnected){
        NSMutableData *data = [[NSMutableData alloc] init];
        Byte under_line[] = {45};
        Byte spb[] = {sp};
        [data appendBytes:ESC length:1];
        [data appendBytes:under_line length:1];
        [data appendBytes:spb length:1];
        [data appendBytes:ESC_FS length:1];
        [data appendBytes:under_line length:1];
        [data appendBytes:spb length:1];
        pendingResolve = resolve;
        pendingReject = reject;
        [RNBluetoothManager writeValue:data withDelegate:self];
    }else{
        reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
    
}

RCT_EXPORT_METHOD(printText:(NSString *) text withOptions:(NSDictionary *) options
                  resolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject)
{NSLog(@"printing text...with options: %@",options);
    if(!RNBluetoothManager.isConnected){
          reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }else{
        @try{
    //encoding:'GBK',
    //codepage:0,
    //widthtimes:0,
    //heigthtimes:0,
    //fonttype:1
        NSString *encodig = [options valueForKey:@"encoding"];
        if(!encodig) encodig=@"GBK";
            NSInteger codePage = [[options valueForKey:@"codepage"] integerValue];NSLog(@"Got codepage from options: %ld",codePage);
        if(!codePage) codePage = 0;
        NSInteger widthTimes = [[options valueForKey:@"widthtimes"] integerValue];
        if(!widthTimes) widthTimes = 0;
        NSInteger heigthTime = [[options valueForKey:@"heigthtimes"] integerValue];
        if(!heigthTime) heigthTime =0;
        NSInteger fontType = [[options valueForKey:@"fontType"] integerValue];
        if(!fontType) fontType = 0;
            pendingResolve = resolve;
            pendingReject = reject;
            [self textPrint:text inEncoding:encodig withCodePage:codePage widthTimes:widthTimes heightTimes:heigthTime fontType:fontType delegate:self];
        }
        @catch (NSException *e){
            NSLog(@"print text exception: %@",e);
            reject(e.name.description,e.name.description,nil);
        }
    }
}
-(NSStringEncoding) toNSEncoding:(NSString *)encoding
{NSLog(@"encoding: %@",encoding);
    NSStringEncoding nsEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    if([@"UTF-8" isEqualToString:encoding] || [@"utf-8" isEqualToString:encoding] ){
        nsEncoding = NSUTF8StringEncoding;
    }
    
    return nsEncoding;
}
-(void) textPrint:(NSString *) text
       inEncoding:(NSString *) encoding
     withCodePage:(NSInteger) codePage
       widthTimes:(NSInteger) widthTimes
      heightTimes:(NSInteger) heightTimes
         fontType:(NSInteger) fontType
     delegate:(NSObject<WriteDataToBleDelegate> *) delegate
{
    Byte *intToWidth[] = {0x00, 0x10, 0x20, 0x30};
    Byte *intToHeight[] = {0x00, 0x01, 0x02, 0x03};
    Byte *multTime[] = {intToWidth[widthTimes],intToHeight[heightTimes]};
    NSData *bytes = [text dataUsingEncoding:[self toNSEncoding:encoding]];
    NSLog(@"Got bytes length:%lu",[bytes length]);
    
    NSMutableData *toSend = [[NSMutableData alloc] init];
    
    //gsExclamationMark:{GS, '!', 0x00 };
    [toSend appendBytes:ESC_GS length:sizeof(ESC_GS)];
    [toSend appendBytes:SIGN length:sizeof(SIGN)];
    [toSend appendBytes:multTime length:sizeof(multTime)];
    //escT:  {ESC, 't', 0x00 };
    [toSend appendBytes:ESC length:sizeof(ESC)];
    [toSend appendBytes:T length:sizeof(T)];
    [toSend appendBytes:&codePage length:sizeof(codePage)];NSLog(@"codepage: %lu",codePage);
    if(codePage == 0){
        //FS_and :{FS, '&' };
        [toSend appendBytes:ESC_FS length:sizeof(ESC_FS)];
        [toSend appendBytes:AND length:sizeof(AND)];
    }else{NSLog(@"{FS,46}");
        //FS_dot: {FS, 46 };
        NSInteger fourtySix= 46;
        [toSend appendBytes:ESC_FS length:sizeof(ESC_FS)];
        [toSend appendBytes:&fourtySix length:sizeof(fourtySix)];
    }
//    escM:{ESC, 'M', 0x00 };
    [toSend appendBytes:ESC length:sizeof(ESC)];
    [toSend appendBytes:M length:sizeof(M)];
    [toSend appendBytes:&fontType length:sizeof(fontType)];
    // text data
    [toSend appendData:bytes];
    //LF
   // [toSend appendBytes:&NL length:sizeof(NL)];
  
    NSLog(@"Goting to write text : %@",text);
    NSLog(@"With data: %@",toSend);
    [RNBluetoothManager writeValue:toSend withDelegate:delegate];
}

RCT_EXPORT_METHOD(rotate:(NSInteger *)rotate
                  withResolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject)
{
    if(RNBluetoothManager.isConnected){
        //    //取消/选择90度旋转打印
       // public static byte[] ESC_V = new byte[] {ESC, 'V', 0x00 };
        NSMutableData *data = [[NSMutableData alloc] init];
        Byte rotateBytes[] = {(int)rotate};
        [data appendBytes:ESC length:1];
        [data appendBytes:V length:1];
        [data appendBytes:rotateBytes length:1];
        pendingReject = reject;
        pendingResolve = resolve;
        [RNBluetoothManager writeValue:data withDelegate:self];
    }else{
           reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
//        if(sendDataByte(PrinterCommand.POS_Set_Rotate(rotate))){
//            promise.resolve(null);
//        }else{
//            promise.reject("COMMAND_NOT_SEND");
//        }
}

RCT_EXPORT_METHOD(printerAlign:(NSInteger *) align
                   withResolver:(RCTPromiseResolveBlock) resolve rejecter:(RCTPromiseRejectBlock) reject)
{
    if(RNBluetoothManager.isConnected){
        //if ((align < 0 || align > 2) && (align < 48 || align > 50)) return null;
        if((align < 0 || align > 2) && (align < 48 || align > 50)){
             reject(@"INVALD_PARAMETERS",@"INVALD_PARAMETERS",nil);
        }else{
            //{ESC, 'a', 0x00 }
            NSMutableData *toSend = [[NSMutableData alloc] init];
            [toSend appendBytes:ESC length:sizeof(ESC)];
            [toSend appendBytes:A length:sizeof(A)];
            [toSend appendBytes:&align length:sizeof(align)];
            pendingReject =reject;
            pendingResolve =resolve;
            [RNBluetoothManager writeValue:toSend withDelegate:self];
        }
    }else{
         reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
}

RCT_EXPORT_METHOD(printColumn:(NSArray *)columnWidths
                  withAligns:(NSArray *) columnAligns
                  texts:(NSArray *) columnTexts
                  options:(NSDictionary *)options
                  resolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{
    if(!RNBluetoothManager.isConnected){
        reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }else{
        @try{
            NSString *encodig = [options valueForKey:@"encoding"];
            if(!encodig) encodig=@"GBK";
            NSInteger codePage = [[options valueForKey:@"codepage"] integerValue];NSLog(@"Got codepage from options: %ld",codePage);
            if(!codePage) codePage = 0;
            NSInteger widthTimes = [[options valueForKey:@"widthtimes"] integerValue];
            if(!widthTimes) widthTimes = 0;
            NSInteger heigthTime = [[options valueForKey:@"heigthtimes"] integerValue];
            if(!heigthTime) heigthTime =0;
            NSInteger fontType = [[options valueForKey:@"fontType"] integerValue];
            if(!fontType) fontType = 0;
          /**
                 * [column1-1,
                 * column1-2,
                 * column1-3 ... column1-n]
                 * ,
                 *  [column2-1,
                 * column2-2,
                 * column2-3 ... column2-n]
                 *
                 * ...
                 *
                 */
            NSMutableArray *table =[[NSMutableArray alloc] init];
            
                /**splits the column text to few rows and applies the alignment **/
                int padding = 1;
                for(int i=0;i< [columnWidths count];i++){
                    NSInteger width =[[columnWidths objectAtIndex:i ] integerValue] - padding;//1 char padding
                    NSString *text = [columnTexts objectAtIndex:i]; //String.copyValueOf(columnTexts.getString(i).toCharArray());
                    NSLog(@"Text in column: %@",text);
                    NSMutableArray<ColumnSplitedString *> *splited = [[NSMutableArray alloc] init];
                    //List<ColumnSplitedString> splited = new ArrayList<ColumnSplitedString>();
                    int shorter = 0;
                    int counter = 0;
                   NSMutableString *temp = [[NSMutableString alloc] init];
                   
                    for(int c=0;c<[text length];c++){
                        unichar ch = [text characterAtIndex:c];
                        int l = (ch>= 0x4e00 && ch <= 0x9fff)?2:1;
                        if (l==2){
                            shorter=shorter+1;
                        }
                        [temp appendString:[text substringWithRange:NSMakeRange(c, 1)]];
                        if(counter+l<width){
                            counter = counter+l;
                        }else{
                            ColumnSplitedString *css = [[ColumnSplitedString alloc] init];
                            css.str = temp;
                            css.shorter = shorter;
                            [splited addObject:css];
                            temp = [[NSMutableString alloc] init];
                            counter=0;
                            shorter=0;
                        }
                    }
                    if([temp length]>0) {
                        ColumnSplitedString *css = [[ColumnSplitedString alloc] init];
                        css.str = temp;
                        css.shorter = shorter;
                        [splited addObject:css];
                    }
                    NSInteger align =[[columnAligns objectAtIndex:i] integerValue];
            
                    NSMutableArray *formated = [[NSMutableArray alloc] init];
                    for(ColumnSplitedString *s in splited){
                        NSMutableString *empty = [[NSMutableString alloc] init];
                        for(int w=0;w<(width+padding-s.shorter);w++){
                            [empty appendString:@" "];
                        }
                        int startIdx = 0;
                        NSString *ss = s.str;
                        if(align == 1 && [ss length]<(width-s.shorter)){
                            startIdx = (int)(width-s.shorter-[ss length])/2;
                            if(startIdx+[ss length]>width-s.shorter){
                                startIdx--;
                            }
                            if(startIdx<0){
                                startIdx=0;
                            }
                        }else if(align==2 && [ss length]<(width-s.shorter)){
                            startIdx =(int)(width - s.shorter-[ss length]);
                        }
                        NSInteger length =[ss length];
//                        if(length+startIdx>[empty length]){
//                            length = [empty length]-startIdx;
//                        }
                        NSLog(@"empty(length: %lu) replace from %d length %lu with str:%@)",[empty length],startIdx,length,ss);
                        [empty replaceCharactersInRange:NSMakeRange(startIdx, length) withString:ss];
                        [formated addObject:empty];
                    }
                    [table addObject:formated];
                }
            
            /**  try to find the max row count of the table **/
                NSInteger maxRowCount = 0;
                for(int i=0;i<[table count]/*column count*/;i++){
                    NSArray *rows = [table objectAtIndex:i]; // row data in current column
                    if([rows count]>maxRowCount){
                        maxRowCount = [rows count];// try to find the max row count;
                    }
                }
            
                /** loop table again to fill the rows **/
            NSMutableArray<NSMutableString *> *rowsToPrint = [[NSMutableArray alloc] init];
                for(int column=0;column<[table count]/*column count*/;column++){
                    NSArray *rows = [table objectAtIndex:column]; // row data in current column
                    for(int row=0;row<maxRowCount;row++){
                        if([rowsToPrint count]<=row || [rowsToPrint objectAtIndex:row] ==nil){
                           [rowsToPrint setObject:[[NSMutableString alloc] init] atIndexedSubscript:row];
                        }
                        if(row<[rows count]){
                            //got the row of this column
                            [(NSMutableString *)[rowsToPrint objectAtIndex:row] appendString:[rows objectAtIndex:row]];//.append(rows.get(row));
                        }else{
                            NSInteger w = [[columnWidths objectAtIndex:column] integerValue]; //columnWidths.getInt(column);
                            NSMutableString *empty = [[NSMutableString alloc] init];
                            for(int i=0;i<w;i++){
                                [empty appendString:@" "]; //empty.append(" ");
                            }
                             [(NSMutableString *)[rowsToPrint objectAtIndex:row] appendString:empty];//Append spaces to ensure the format
                        }
                    }
                }
            
                /** loops the rows and print **/
            PrintColumnBleWriteDelegate *delegate = [[PrintColumnBleWriteDelegate alloc] init];
            delegate.now = 0;
            delegate.error = false;
            delegate.pendingReject = reject;
            delegate.pendingResolve =resolve;
            delegate.canceled = false;
            delegate.encodig = encodig;
            delegate.widthTimes = widthTimes;
            delegate.heightTimes = heigthTime;
            delegate.fontType = fontType;
            delegate.codePage = codePage;
            delegate.printer = self;
            [delegate printColumn:rowsToPrint withMaxcount:maxRowCount];
        }
        @catch(NSException *e){
            NSLog(@"print text exception: %@",[e callStackSymbols]);
            reject(e.name.description,e.name.description,nil);
        }
        
    }
}

RCT_EXPORT_METHOD(setBlob:(NSInteger) sp
                  withResolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{
    //\\    //选择/取消加粗指令
//    public static byte[] ESC_G = new byte[] {ESC, 'G', 0x00 };
//    public static byte[] ESC_E = new byte[] {ESC, 'E', 0x00 };
    //E+G
    NSMutableData *toSend = [[NSMutableData alloc] init];
    [toSend appendBytes:&ESC length:sizeof(ESC)];
    [toSend appendBytes:&G length:sizeof(G)];
    [toSend appendBytes:&sp length:sizeof(sp)];
    [toSend appendBytes:&ESC length:sizeof(ESC)];
    [toSend appendBytes:&E length:sizeof(E)];
    [toSend appendBytes:&sp length:sizeof(sp)];
    pendingReject =reject;
    pendingResolve = resolve;
    [RNBluetoothManager writeValue:toSend withDelegate:self];
}

RCT_EXPORT_METHOD(printPic:(NSString *) base64encodeStr withOptions:(NSDictionary *) options
                  resolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{
    if(RNBluetoothManager.isConnected){
        @try{
            NSInteger nWidth = [[options valueForKey:@"width"] integerValue];
            if(!nWidth) nWidth = _deviceWidth;
            //TODO:need to handel param "left" in the options.
            NSInteger paddingLeft = [[options valueForKey:@"left"] integerValue];
            if(!paddingLeft) paddingLeft = 0;
            NSData *decoded = [[NSData alloc] initWithBase64EncodedString:base64encodeStr options:0 ];
            UIImage *srcImage = [[UIImage alloc] initWithData:decoded scale:1];
            NSData *jpgData = UIImageJPEGRepresentation(srcImage, 1);
            UIImage *jpgImage = [[UIImage alloc] initWithData:jpgData];
            //mBitmap.getHeight() * width / mBitmap.getWidth();
            NSInteger imgHeight = jpgImage.size.height;
            NSInteger imagWidth = jpgImage.size.width;
            NSInteger width = nWidth;//((int)(((nWidth*0.86)+7)/8))*8-7;
            CGSize size = CGSizeMake(width, imgHeight*width/imagWidth);
            UIImage *scaled = [ImageUtils imageWithImage:jpgImage scaledToFillSize:size];
            if(paddingLeft>0){
                scaled = [ImageUtils imagePadLeft:paddingLeft withSource:scaled];
                size =[scaled size];
            }
            
            unsigned char * graImage = [ImageUtils imageToGreyImage:scaled];
            unsigned char * formatedData = [ImageUtils format_K_threshold:graImage width:size.width height:size.height];
            NSData *dataToPrint = [ImageUtils eachLinePixToCmd:formatedData nWidth:size.width nHeight:size.height nMode:0];
            PrintImageBleWriteDelegate *delegate = [[PrintImageBleWriteDelegate alloc] init];
            delegate.pendingResolve = resolve;
            delegate.pendingReject = reject;
            delegate.width = width;
            delegate.toPrint  = dataToPrint;
            delegate.now = 0;
            [delegate print];
        }
        @catch(NSException *e){
            NSLog(@"ERROR IN PRINTING IMG: %@",[e callStackSymbols]);
              reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
        }
    }else{
        reject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
}

RCT_EXPORT_METHOD(printQRCode:(NSString *)content
                  withSize:(NSInteger) size
                  correctionLevel:(NSInteger) correctionLevel
                  andResolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{
    NSLog(@"QRCODE TO PRINT: %@",content);
    NSError *error = nil;
    ZXEncodeHints *hints = [ZXEncodeHints hints];
    hints.encoding=NSUTF8StringEncoding;
    hints.margin=0;
    hints.errorCorrectionLevel = [self findCorrectionLevel:correctionLevel];
    
    ZXMultiFormatWriter *writer = [ZXMultiFormatWriter writer];
    ZXBitMatrix *result = [writer encode:content
                                  format:kBarcodeFormatQRCode
                                   width:(int)size
                                  height:(int)size
                                    hints:hints
                                   error:&error];
    if(error || !result){
        reject(@"ERROR_IN_CREATE_QRCODE",@"ERROR_IN_CREATE_QRCODE",nil);
    }else{
        CGImageRef image = [[ZXImage imageWithMatrix:result] cgimage];
        uint8_t * graImage = [ImageUtils imageToGreyImage:[UIImage imageWithCGImage:image]];
        unsigned char * formatedData = [ImageUtils format_K_threshold:graImage width:size height:size];
        NSData *dataToPrint = [ImageUtils eachLinePixToCmd:formatedData nWidth:size nHeight:size nMode:0];
        PrintImageBleWriteDelegate *delegate = [[PrintImageBleWriteDelegate alloc] init];
        delegate.pendingResolve=resolve;
        delegate.pendingReject = reject;
        delegate.width = size;
        delegate.toPrint  = dataToPrint;
        delegate.now = 0;
        [delegate print];
    }
}

RCT_EXPORT_METHOD(printBarCode:(NSString *) str withType:(NSInteger)
                  nType width:(NSInteger) nWidth heigth:(NSInteger) nHeight
                  hriFontType:(NSInteger) nHriFontType hriFontPosition:(NSInteger) nHriFontPosition
                  andResolver:(RCTPromiseResolveBlock) resolve
                  rejecter:(RCTPromiseRejectBlock) reject)
{
    if (nType < 0x41 | nType > 0x49 | nWidth < 2 | nWidth > 6
        | nHeight < 1 | nHeight > 255 | (!str||[str length]<1))
      {
          reject(@"INVALID_PARAMETER",@"INVALID_PARAMETER",nil);
          return;
      }
    
    NSData *conentData = [str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    NSMutableData *toPrint = [[NSMutableData alloc] init];
    int8_t * command = malloc(16);
        command[0] = 29 ;//GS
        command[1] = 119;//W
        command[2] = nWidth;
        command[3] = 29;//GS
        command[4] = 104;//h
        command[5] = nHeight;
        command[6] = 29;//GS
        command[7] = 102;//f
        command[8] = (nHriFontType & 0x01);
        command[9] = 29;//GS
        command[10] = 72;//H
        command[11] = (nHriFontPosition & 0x03);
        command[12] = 29;//GS
        command[13] = 107;//k
        command[14] = nType;
        command[15] = [conentData length];
    [toPrint appendBytes:command length:16];
    [toPrint appendData:conentData];
    
    pendingReject = reject;
    pendingResolve = resolve;
    [RNBluetoothManager writeValue:toPrint withDelegate:self];
}
//  L:1,
//M:0,
//Q:3,
//H:2
-(ZXQRCodeErrorCorrectionLevel *)findCorrectionLevel:(NSInteger)level
{
    switch (level) {
        case 1:
            return [[ZXQRCodeErrorCorrectionLevel alloc] initWithOrdinal:0 bits:0x01 name:@"L"];
            break;
        case 2:
             return [[ZXQRCodeErrorCorrectionLevel alloc] initWithOrdinal:3 bits:0x02 name:@"H"];
        case 3:
             return [[ZXQRCodeErrorCorrectionLevel alloc] initWithOrdinal:2 bits:0x03 name:@"Q"];
        default:
             return [[ZXQRCodeErrorCorrectionLevel alloc] initWithOrdinal:1 bits:0x00 name:@"M"];
            break;
    }
}

- (void) didWriteDataToBle: (BOOL)success{
    if(success){
        pendingResolve(nil);
    }else{NSLog(@"REJECT<REJECT<REJECT<REJECT<REJECT<");
        pendingReject(@"COMMAND_NOT_SEND",@"COMMAND_NOT_SEND",nil);
    }
    pendingReject = nil;
    pendingResolve = nil;
    [NSThread sleepForTimeInterval:0.05f];//slow down
}

@end
