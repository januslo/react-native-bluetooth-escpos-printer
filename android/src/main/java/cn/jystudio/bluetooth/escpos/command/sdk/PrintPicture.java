package cn.jystudio.bluetooth.escpos.command.sdk;

import zj.com.customize.sdk.Other;
import android.graphics.Bitmap;

public class PrintPicture {

	/**
	 * 打印位图函数
	 * 此函数是将一行作为一个图片打印，这样处理不容易出错
	 * @param mBitmap
	 * @param nWidth
	 * @param nMode
	 * @return
	 */
    public static byte[] POS_PrintBMP(Bitmap mBitmap, int nWidth, int nMode) {
		// 先转黑白，再调用函数缩放位图
		int width = ((nWidth + 7) / 8) * 8;
		int height = mBitmap.getHeight() * width / mBitmap.getWidth();
		height = ((height + 7) / 8) * 8;

		Bitmap rszBitmap = mBitmap;
		if (mBitmap.getWidth() != width){
			rszBitmap = Other.resizeImage(mBitmap, width, height);
		}
	
		Bitmap grayBitmap = Other.toGrayscale(rszBitmap);
		
		byte[] dithered = Other.thresholdToBWPic(grayBitmap);

		byte[] data = Other.eachLinePixToCmd(dithered, width, nMode);
		
		return data;
	}
	
    /**
     * 使用下传位图打印图片
	 * 先收完再打印
     * @param bmp
     * @return
     */
	public static byte[] Print_1D2A(Bitmap bmp){
			
			/*
			 * 使用下传位图打印图片
			 * 先收完再打印
			 */
	 		int width = bmp.getWidth();
	 		int height = bmp.getHeight();
	 		byte data[]=new byte[1024*10];
			data[0] = 0x1D;
			data[1] = 0x2A;
			data[2] =(byte)( (width - 1)/ 8 + 1);
			data[3] =(byte)( (height - 1)/ 8 + 1);
			byte k = 0;
			int position = 4;
			int i;
			int j;
			byte temp = 0;
			for(i = 0; i <width;  i++){

				System.out.println("进来了...I");
				for(j = 0; j < height; j++){
					System.out.println("进来了...J");
					if(bmp.getPixel(i, j) != -1){
						temp |= (0x80 >> k);
					} // end if
					k++;
					if(k == 8){
						data[position++] = temp;
						temp = 0;
						k = 0;
					} // end if k
				}// end for j
				if(k % 8 != 0){
					data[position ++] = temp;
					temp = 0;
					k = 0;
				}
			
			}
			System.out.println("data"+data);
			
			if( width% 8 != 0){
				i =   height/ 8;
				if(height % 8 != 0) i++;
				j = 8 - (width % 8);
				for(k = 0; k < i*j; k++){
					data[position++] = 0;
				}			
			}	
			return data;
		}

}
