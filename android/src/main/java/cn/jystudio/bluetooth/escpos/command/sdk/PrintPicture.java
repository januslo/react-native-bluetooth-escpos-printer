package cn.jystudio.bluetooth.escpos.command.sdk;

import android.graphics.*;

import java.io.UnsupportedEncodingException;

public class PrintPicture {
    private static int[] p0 = new int[]{0, 128};
    private static int[] p1 = new int[]{0, 64};
    private static int[] p2 = new int[]{0, 32};
    private static int[] p3 = new int[]{0, 16};
    private static int[] p4 = new int[]{0, 8};
    private static int[] p5 = new int[]{0, 4};
    private static int[] p6 = new int[]{0, 2};
    private static int[][] Floyd16x16 = new int[][]{{0, 128, 32, 160, 8, 136, 40, 168, 2, 130, 34, 162, 10, 138, 42, 170}, {192, 64, 224, 96, 200, 72, 232, 104, 194, 66, 226, 98, 202, 74, 234, 106}, {48, 176, 16, 144, 56, 184, 24, 152, 50, 178, 18, 146, 58, 186, 26, 154}, {240, 112, 208, 80, 248, 120, 216, 88, 242, 114, 210, 82, 250, 122, 218, 90}, {12, 140, 44, 172, 4, 132, 36, 164, 14, 142, 46, 174, 6, 134, 38, 166}, {204, 76, 236, 108, 196, 68, 228, 100, 206, 78, 238, 110, 198, 70, 230, 102}, {60, 188, 28, 156, 52, 180, 20, 148, 62, 190, 30, 158, 54, 182, 22, 150}, {252, 124, 220, 92, 244, 116, 212, 84, 254, 126, 222, 94, 246, 118, 214, 86}, {3, 131, 35, 163, 11, 139, 43, 171, 1, 129, 33, 161, 9, 137, 41, 169}, {195, 67, 227, 99, 203, 75, 235, 107, 193, 65, 225, 97, 201, 73, 233, 105}, {51, 179, 19, 147, 59, 187, 27, 155, 49, 177, 17, 145, 57, 185, 25, 153}, {243, 115, 211, 83, 251, 123, 219, 91, 241, 113, 209, 81, 249, 121, 217, 89}, {15, 143, 47, 175, 7, 135, 39, 167, 13, 141, 45, 173, 5, 133, 37, 165}, {207, 79, 239, 111, 199, 71, 231, 103, 205, 77, 237, 109, 197, 69, 229, 101}, {63, 191, 31, 159, 55, 183, 23, 151, 61, 189, 29, 157, 53, 181, 21, 149}, {254, 127, 223, 95, 247, 119, 215, 87, 253, 125, 221, 93, 245, 117, 213, 85}};


    public static Bitmap resizeImage(Bitmap bitmap, int w, int h) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        float scaleWidth = (float) w / (float) width;
        float scaleHeight = (float) h / (float) height;
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);
        Bitmap resizedBitmap = Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
        return resizedBitmap;
    }

    public static Bitmap pad(Bitmap Src, int padding_x, int padding_y) {
        Bitmap outputimage = Bitmap.createBitmap(Src.getWidth() + padding_x,Src.getHeight() + padding_y, Bitmap.Config.ARGB_8888);
        Canvas can = new Canvas(outputimage);
        can.drawARGB(255,255,255,255); //This represents White color
        can.drawBitmap(Src, padding_x, padding_y, null);
        return outputimage;
    }


    /**
     * 打印位图函数
     * 此函数是将一行作为一个图片打印，这样处理不容易出错
     *
     * @param mBitmap
     * @param nWidth
     * @param nMode
     * @return
     */
    public static byte[] POS_PrintBMP(Bitmap mBitmap, int nWidth, int nMode, int leftPadding) {
        // 先转黑白，再调用函数缩放位图
        int width = ((nWidth + 7) / 8) * 8;
        int height = mBitmap.getHeight() * width / mBitmap.getWidth();
        height = ((height + 7) / 8) * 8;
        int left = leftPadding == 0 ? 0 : ((leftPadding+7) / 8) * 8;

        Bitmap rszBitmap = mBitmap;
        if (mBitmap.getWidth() != width) {
            rszBitmap = Bitmap.createScaledBitmap(mBitmap, width, height, true);
        }

        Bitmap grayBitmap = toGrayscale(rszBitmap);
        if(left>0){
            grayBitmap = pad(grayBitmap,left,0);
        }

        byte[] dithered = thresholdToBWPic(grayBitmap);

        byte[] data = eachLinePixToCmd(dithered, width+left, nMode);

        return data;
    }

    /**
     * 使用下传位图打印图片
     * 先收完再打印
     *
     * @param bmp
     * @return
     */
    public static byte[] Print_1D2A(Bitmap bmp) {

			/*
			 * 使用下传位图打印图片
			 * 先收完再打印
			 */
        int width = bmp.getWidth();
        int height = bmp.getHeight();
        byte data[] = new byte[1024 * 10];
        data[0] = 0x1D;
        data[1] = 0x2A;
        data[2] = (byte) ((width - 1) / 8 + 1);
        data[3] = (byte) ((height - 1) / 8 + 1);
        byte k = 0;
        int position = 4;
        int i;
        int j;
        byte temp = 0;
        for (i = 0; i < width; i++) {
            for (j = 0; j < height; j++) {
                if (bmp.getPixel(i, j) != -1) {
                    temp |= (0x80 >> k);
                } // end if
                k++;
                if (k == 8) {
                    data[position++] = temp;
                    temp = 0;
                    k = 0;
                } // end if k
            }// end for j
            if (k % 8 != 0) {
                data[position++] = temp;
                temp = 0;
                k = 0;
            }

        }

        if (width % 8 != 0) {
            i = height / 8;
            if (height % 8 != 0) i++;
            j = 8 - (width % 8);
            for (k = 0; k < i * j; k++) {
                data[position++] = 0;
            }
        }
        return data;
    }

    public static Bitmap toGrayscale(Bitmap bmpOriginal) {
        int width, height;
        height = bmpOriginal.getHeight();
        width = bmpOriginal.getWidth();

        Bitmap bmpGrayscale = Bitmap.createBitmap(width, height, Bitmap.Config.RGB_565);
        Canvas c = new Canvas(bmpGrayscale);
        Paint paint = new Paint();
        ColorMatrix cm = new ColorMatrix();
        cm.setSaturation(0);
        ColorMatrixColorFilter f = new ColorMatrixColorFilter(cm);
        paint.setColorFilter(f);
        c.drawBitmap(bmpOriginal, 0, 0, paint);
        return bmpGrayscale;
    }

    public static byte[] thresholdToBWPic(Bitmap mBitmap) {
        int[] pixels = new int[mBitmap.getWidth() * mBitmap.getHeight()];
        byte[] data = new byte[mBitmap.getWidth() * mBitmap.getHeight()];
        mBitmap.getPixels(pixels, 0, mBitmap.getWidth(), 0, 0, mBitmap.getWidth(), mBitmap.getHeight());
        format_K_threshold(pixels, mBitmap.getWidth(), mBitmap.getHeight(), data);
        return data;
    }

    private static void format_K_threshold(int[] orgpixels, int xsize, int ysize, byte[] despixels) {
        int graytotal = 0;
        boolean grayave = true;
        int k = 0;

        int i;
        int j;
        int gray;
        for (i = 0; i < ysize; ++i) {
            for (j = 0; j < xsize; ++j) {
                gray = orgpixels[k] & 255;
                graytotal += gray;
                ++k;
            }
        }

        int var10 = graytotal / ysize / xsize;
        k = 0;

        for (i = 0; i < ysize; ++i) {
            for (j = 0; j < xsize; ++j) {
                gray = orgpixels[k] & 255;
                if (gray > var10) {
                    despixels[k] = 0;
                } else {
                    despixels[k] = 1;
                }

                ++k;
            }
        }

    }

    public static byte[] eachLinePixToCmd(byte[] src, int nWidth, int nMode) {
        int nHeight = src.length / nWidth;
        int nBytesPerLine = nWidth / 8;
        byte[] data = new byte[nHeight * (8 + nBytesPerLine)];
        boolean offset = false;
        int k = 0;

        for (int i = 0; i < nHeight; ++i) {
            int var10 = i * (8 + nBytesPerLine);
            //GS v 0 m xL xH yL yH d1....dk 打印光栅位图
            data[var10 + 0] = 29;//GS
            data[var10 + 1] = 118;//v
            data[var10 + 2] = 48;//0
            data[var10 + 3] = (byte) (nMode & 1);
            data[var10 + 4] = (byte) (nBytesPerLine % 256);//xL
            data[var10 + 5] = (byte) (nBytesPerLine / 256);//xH
            data[var10 + 6] = 1;//yL
            data[var10 + 7] = 0;//yH

            for (int j = 0; j < nBytesPerLine; ++j) {
                data[var10 + 8 + j] = (byte) (p0[src[k]] + p1[src[k + 1]] + p2[src[k + 2]] + p3[src[k + 3]] + p4[src[k + 4]] + p5[src[k + 5]] + p6[src[k + 6]] + src[k + 7]);
                k += 8;
            }
        }

        return data;
    }

    public static byte[] pixToTscCmd(byte[] src) {
        byte[] data = new byte[src.length / 8];
        int k = 0;

        for (int j = 0; k < data.length; ++k) {
            byte temp = (byte) (p0[src[j]] + p1[src[j + 1]] + p2[src[j + 2]] + p3[src[j + 3]] + p4[src[j + 4]] + p5[src[j + 5]] + p6[src[j + 6]] + src[j + 7]);
            data[k] = (byte) (~temp);
            j += 8;
        }

        return data;
    }
    public static byte[] pixToEscRastBitImageCmd(byte[] src) {
        byte[] data = new byte[src.length / 8];
        int i = 0;

        for (int k = 0; i < data.length; ++i) {
            data[i] = (byte) (p0[src[k]] + p1[src[k + 1]] + p2[src[k + 2]] + p3[src[k + 3]] + p4[src[k + 4]] + p5[src[k + 5]] + p6[src[k + 6]] + src[k + 7]);
            k += 8;
        }

        return data;
    }
    public static byte[] pixToEscNvBitImageCmd(byte[] src, int width, int height) {
        byte[] data = new byte[src.length / 8 + 4];
        data[0] = (byte) (width / 8 % 256);
        data[1] = (byte) (width / 8 / 256);
        data[2] = (byte) (height / 8 % 256);
        data[3] = (byte) (height / 8 / 256);
        boolean k = false;

        for (int i = 0; i < width; ++i) {
            int var7 = 0;

            for (int j = 0; j < height / 8; ++j) {
                data[4 + j + i * height / 8] = (byte) (p0[src[i + var7]] + p1[src[i + var7 + 1 * width]] + p2[src[i + var7 + 2 * width]] + p3[src[i + var7 + 3 * width]] + p4[src[i + var7 + 4 * width]] + p5[src[i + var7 + 5 * width]] + p6[src[i + var7 + 6 * width]] + src[i + var7 + 7 * width]);
                var7 += 8 * width;
            }
        }

        return data;
    }
    public static byte[] bitmapToBWPix(Bitmap mBitmap) {
        int[] pixels = new int[mBitmap.getWidth() * mBitmap.getHeight()];
        byte[] data = new byte[mBitmap.getWidth() * mBitmap.getHeight()];
        Bitmap grayBitmap = toGrayscale(mBitmap);
        grayBitmap.getPixels(pixels, 0, mBitmap.getWidth(), 0, 0, mBitmap.getWidth(), mBitmap.getHeight());
        format_K_dither16x16(pixels, grayBitmap.getWidth(), grayBitmap.getHeight(), data);
        return data;
    }

    private static void format_K_dither16x16(int[] orgpixels, int xsize, int ysize, byte[] despixels) {
        int k = 0;

        for (int y = 0; y < ysize; ++y) {
            for (int x = 0; x < xsize; ++x) {
                if ((orgpixels[k] & 255) > Floyd16x16[x & 15][y & 15]) {
                    despixels[k] = 0;
                } else {
                    despixels[k] = 1;
                }

                ++k;
            }
        }

    }

}
