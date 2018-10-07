//
//  ImageUtils.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/10/7.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageUtils.h"
@implementation ImageUtils : NSObject
 static int p0[] =  {0, 128};
 static int p1[] =  {0, 64};
 static int p2[] =  {0, 32};
 static int p3[] =  {0, 16};
static int p4[] =  {0, 8};
 static int p5[] =  {0, 4};
 static int p6[] =  {0, 2};

+(unsigned char *)imageToGreyImage:(UIImage *)image {
    // Create image rectangle with current image width/height
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    
    int colors = kGreen | kBlue | kRed;
    
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;
    uint32_t *rgbImage = (uint32_t *) malloc(actualWidth * actualHeight * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, actualWidth, actualHeight, 8, actualWidth * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, actualWidth, actualHeight), [image CGImage]);
//    CGContextRelease(context);
//    CGColorSpaceRelease(colorSpace);
    
//    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//
//    CGContextRef context = CGBitmapContextCreate(rgbImage, actualWidth, actualHeight, 8, actualWidth*4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
//    CGContextDrawImage(context, imageRect, [image CGImage]);
//
//    //CGImageRef grayImage = CGBitmapContextCreateImage(context);
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
    
//    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, nil, kCGImageAlphaOnly);
//    CGContextDrawImage(context, imageRect, [image CGImage]);
//    CGImageRef mask = CGBitmapContextCreateImage(context);
//    CGContextRelease(context);
    
//    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
//    CGImageRelease(grayImage);
 //   CGImageRelease(mask);
    
    // Return the new grayscale image
    
    // now convert to grayscale
    uint8_t *m_imageData = (uint8_t *) malloc(actualWidth * actualHeight);
    for(int y = 0; y < actualHeight; y++) {
        for(int x = 0; x < actualWidth; x++) {
            uint32_t rgbPixel=rgbImage[(int)(y*actualWidth+x)];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[(int)(y*actualWidth+x)]=sum/count;
        }
    }
    return m_imageData;
}

+ (UIImage *)imageWithImage:(UIImage *)image scaledToFillSize:(CGSize)size
{
    CGFloat scale = MAX(size.width/image.size.width, size.height/image.size.height);
    CGFloat width = image.size.width * scale;
    CGFloat height = image.size.height * scale;
    CGRect imageRect = CGRectMake((size.width - width)/2.0f,
                                  (size.height - height)/2.0f,
                                  width,
                                  height);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    [image drawInRect:imageRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (NSData*)bitmapToArray:(UIImage*) bmp
{
    CGDataProviderRef provider = CGImageGetDataProvider(bmp.CGImage);
    NSData* data = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
    return data;
}

+ (NSData *)eachLinePixToCmd:(NSData *)src nWidth:(NSInteger) nWidth nHeight:(NSInteger) nHeight nMode:(NSInteger) nMode
{
    NSInteger nBytesPerLine = (nWidth+7)/8;
    unsigned char* data[nHeight*(8+nBytesPerLine)];
    const char* srcData = (const char*)[src bytes];
    NSInteger k = 0;
    for(int i=0;i<nHeight;i++){
        NSInteger var10 = i*(8+nBytesPerLine);
         //GS v 0 m xL xH yL yH d1....dk 打印光栅位图
                data[var10 + 0] = 29;//GS
                data[var10 + 1] = 118;//v
                data[var10 + 2] = 48;//0
                data[var10 + 3] =  (int)(nMode & 1);
                data[var10 + 4] =  (int)(nBytesPerLine % 256);//xL
                data[var10 + 5] =  (int)(nBytesPerLine / 256);//xH
                data[var10 + 6] = 1;//yL
                data[var10 + 7] = 0;//yH
        for (int j = 0; j < nBytesPerLine; ++j) {
            data[var10 + 8 + j] = (int) (p0[srcData[k]] + p1[srcData[k + 1]] + p2[srcData[k + 2]] + p3[srcData[k + 3]] + p4[srcData[k + 4]] + p5[srcData[k + 5]] + p6[srcData[k + 6]] + srcData[k + 7]);
            k += 8;
        }
    }
    return [NSData dataWithBytes:data length:sizeof(data)];
}

+(unsigned char *)format_K_threshold:(unsigned char *) orgpixels
                        width:(NSInteger) xsize height:(NSInteger) ysize
{
    unsigned char * despixels = malloc(xsize*ysize);
    int graytotal = 0;
    int k = 0;
    
    int i;
    int j;
    int gray;
    for(i = 0; i < ysize; ++i) {
        for(j = 0; j < xsize; ++j) {
            gray = orgpixels[k] & 255;
            graytotal += gray;
            ++k;
        }
    }
    
    int grayave = graytotal / ysize / xsize;
    k = 0;
    
    for(i = 0; i < ysize; ++i) {
        for(j = 0; j < xsize; ++j) {
            gray = orgpixels[k] & 255;
            if(gray > grayave) {
                despixels[k] = 0;
            } else {
                despixels[k] = 1;
            }
            
            ++k;
        }
    }
    return despixels;
}

@end
