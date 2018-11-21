
package cn.jystudio.bluetooth.escpos;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import android.util.Log;
import cn.jystudio.bluetooth.BluetoothService;
import cn.jystudio.bluetooth.BluetoothServiceStateObserver;
import cn.jystudio.bluetooth.escpos.command.sdk.Command;
import cn.jystudio.bluetooth.escpos.command.sdk.PrintPicture;
import cn.jystudio.bluetooth.escpos.command.sdk.PrinterCommand;
import com.facebook.react.bridge.*;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.google.zxing.qrcode.decoder.ErrorCorrectionLevel;

import javax.annotation.Nullable;
import java.nio.charset.Charset;
import java.util.*;

public class RNBluetoothEscposPrinterModule extends ReactContextBaseJavaModule
        implements BluetoothServiceStateObserver {
    private static final String TAG = "BluetoothEscposPrinter";

    public static final int WIDTH_58 = 384;
    public static final int WIDTH_80 = 576;
    private final ReactApplicationContext reactContext;
    /******************************************************************************************************/

    private int deviceWidth = WIDTH_58;
    private BluetoothService mService;


    public RNBluetoothEscposPrinterModule(ReactApplicationContext reactContext,
                                          BluetoothService bluetoothService) {
        super(reactContext);
        this.reactContext = reactContext;
        this.mService = bluetoothService;
        this.mService.addStateObserver(this);
    }

    @Override
    public String getName() {
        return "BluetoothEscposPrinter";
    }


    @Override
    public
    @Nullable
    Map<String, Object> getConstants() {
        Map<String, Object> constants = new HashMap<>();
        constants.put("width58", WIDTH_58);
        constants.put("width80", WIDTH_80);
        return constants;
    }

    @ReactMethod
    public void printerInit(final Promise promise){
        if(sendDataByte(PrinterCommand.POS_Set_PrtInit())){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }

    @ReactMethod
    public void printAndFeed(int feed,final Promise promise){
        if(sendDataByte(PrinterCommand.POS_Set_PrtAndFeedPaper(feed))){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }

    @ReactMethod
    public void printerLeftSpace(int sp,final Promise promise){
        if(sendDataByte(PrinterCommand.POS_Set_LeftSP(sp))){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }

    @ReactMethod
    public void printerLineSpace(int sp,final Promise promise){
        byte[] command = PrinterCommand.POS_Set_DefLineSpace();
        if(sp>0){
            command = PrinterCommand.POS_Set_LineSpace(sp);
        }
        if(command==null || !sendDataByte(command)){
            promise.reject("COMMAND_NOT_SEND");
        }else{
            promise.resolve(null);
        }
    }

    /**
     * Under line switch, 0-off,1-on,2-deeper
     * @param line 0-off,1-on,2-deeper
     */
    @ReactMethod
    public void printerUnderLine(int line,final Promise promise){
        if(sendDataByte(PrinterCommand.POS_Set_UnderLine(line))){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }

    /**
     * When n=0 or 48, left justification is enabled
     * When n=1 or 49, center justification is enabled
     * When n=2 or 50, right justification is enabled
     * @param align
     * @param promise
     */
    @ReactMethod
    public void printerAlign(int align,final Promise promise){
        Log.d(TAG,"Align:"+align);
        if(sendDataByte(PrinterCommand.POS_S_Align(align))){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }


    @ReactMethod
    public void printText(String text, @Nullable  ReadableMap options, final Promise promise) {
        try {
            String encoding = "GBK";
            int codepage = 0;
            int widthTimes = 0;
            int heigthTimes=0;
            int fonttype=0;
            if(options!=null) {
                encoding = options.hasKey("encoding") ? options.getString("encoding") : "GBK";
                codepage = options.hasKey("codepage") ? options.getInt("codepage") : 0;
                widthTimes = options.hasKey("widthtimes") ? options.getInt("widthtimes") : 0;
                heigthTimes = options.hasKey("heigthtimes") ? options.getInt("heigthtimes") : 0;
                fonttype = options.hasKey("fonttype") ? options.getInt("fonttype") : 0;
            }
            String toPrint = text;
//            if ("UTF-8".equalsIgnoreCase(encoding)) {
//                byte[] b = text.getBytes("UTF-8");
//                toPrint = new String(b, Charset.forName(encoding));
//            }

            byte[] bytes = PrinterCommand.POS_Print_Text(toPrint, encoding, codepage, widthTimes, heigthTimes, fonttype);
            if (sendDataByte(bytes)) {
                promise.resolve(null);
            } else {
                promise.reject("COMMAND_NOT_SEND");
            }
        }catch (Exception e){
            promise.reject(e.getMessage(),e);
        }
    }

    @ReactMethod
    public void printColumn(ReadableArray columnWidths,ReadableArray columnAligns,ReadableArray columnTexts,
                            @Nullable ReadableMap options,final Promise promise){
        if(columnWidths.size()!=columnTexts.size() || columnWidths.size()!=columnAligns.size()){
            promise.reject("COLUMN_WIDTHS_ALIGNS_AND_TEXTS_NOT_MATCH");
            return;
        }
            int totalLen = 0;
            for(int i=0;i<columnWidths.size();i++){
                totalLen+=columnWidths.getInt(i);
            }
            int maxLen = deviceWidth/8;
            if(totalLen>maxLen){
                promise.reject("COLUNM_WIDTHS_TOO_LARGE");
                return;
            }

        String encoding = "GBK";
        int codepage = 0;
        int widthTimes = 0;
        int heigthTimes = 0;
        int fonttype = 0;
        if (options != null) {
            encoding = options.hasKey("encoding") ? options.getString("encoding") : "GBK";
            codepage = options.hasKey("codepage") ? options.getInt("codepage") : 0;
            widthTimes = options.hasKey("widthtimes") ? options.getInt("widthtimes") : 0;
            heigthTimes = options.hasKey("heigthtimes") ? options.getInt("heigthtimes") : 0;
            fonttype = options.hasKey("fonttype") ? options.getInt("fonttype") : 0;
        }
        Log.d(TAG,"encoding: "+encoding);

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
        List<List<String>> table = new ArrayList<List<String>>();

        /**splits the column text to few rows and applies the alignment **/
        int padding = 1;
        for(int i=0;i<columnWidths.size();i++){
            int width =columnWidths.getInt(i)-padding;//1 char padding
            String text = String.copyValueOf(columnTexts.getString(i).toCharArray());
            List<ColumnSplitedString> splited = new ArrayList<ColumnSplitedString>();
            int shorter = 0;
            int counter = 0;
            String temp = "";
            for(int c=0;c<text.length();c++){
                char ch = text.charAt(c);
                int l = isChinese(ch)?2:1;
                if (l==2){
                    shorter++;
                }
                temp=temp+ch;

                if(counter+l<width){
                   counter = counter+l;
                }else{
                    splited.add(new ColumnSplitedString(shorter,temp));
                    temp = "";
                    counter=0;
                    shorter=0;
                }
            }
            if(temp.length()>0) {
                splited.add(new ColumnSplitedString(shorter,temp));
            }
            int align = columnAligns.getInt(i);

            List<String> formated = new ArrayList<String>();
            for(ColumnSplitedString s: splited){
                StringBuilder empty = new StringBuilder();
                for(int w=0;w<(width+padding-s.getShorter());w++){
                    empty.append(" ");
                }
                int startIdx = 0;
                String ss = s.getStr();
                if(align == 1 && ss.length()<(width-s.getShorter())){
                    startIdx = (width-s.getShorter()-ss.length())/2;
                    if(startIdx+ss.length()>width-s.getShorter()){
                        startIdx--;
                    }
                    if(startIdx<0){
                        startIdx=0;
                    }
                }else if(align==2 && ss.length()<(width-s.getShorter())){
                    startIdx =width - s.getShorter()-ss.length();
                }
                Log.d(TAG,"empty.replace("+startIdx+","+(startIdx+ss.length())+","+ss+")");
                empty.replace(startIdx,startIdx+ss.length(),ss);
                formated.add(empty.toString());
            }
            table.add(formated);

        }

        /**  try to find the max row count of the table **/
        int maxRowCount = 0;
        for(int i=0;i<table.size()/*column count*/;i++){
            List<String> rows = table.get(i); // row data in current column
            if(rows.size()>maxRowCount){maxRowCount = rows.size();}// try to find the max row count;
        }

        /** loop table again to fill the rows **/
        StringBuilder[] rowsToPrint = new StringBuilder[maxRowCount];
        for(int column=0;column<table.size()/*column count*/;column++){
            List<String> rows = table.get(column); // row data in current column
            for(int row=0;row<maxRowCount;row++){
                if(rowsToPrint[row]==null){
                    rowsToPrint[row] = new StringBuilder();
                }
                if(row<rows.size()){
                    //got the row of this column
                    rowsToPrint[row].append(rows.get(row));
                }else{
                    int w =columnWidths.getInt(column);
                    StringBuilder empty = new StringBuilder();
                   for(int i=0;i<w;i++){
                       empty.append(" ");
                   }
                    rowsToPrint[row].append(empty.toString());//Append spaces to ensure the format
                }
            }
        }

        /** loops the rows and print **/
        for(int i=0;i<rowsToPrint.length;i++){
            rowsToPrint[i].append("\n\r");//wrap line..
            try {
//                byte[] toPrint = rowsToPrint[i].toString().getBytes("UTF-8");
//                String text = new String(toPrint, Charset.forName(encoding));
                if (!sendDataByte(PrinterCommand.POS_Print_Text(rowsToPrint[i].toString(), encoding, codepage, widthTimes, heigthTimes, fonttype))) {
                    promise.reject("COMMAND_NOT_SEND");
                    return;
                }
            }catch (Exception e){
                e.printStackTrace();
            }
        }
        promise.resolve(null);
    }

    @ReactMethod
    public void setWidth(int width) {
        deviceWidth = width;
    }

    @ReactMethod
    public void printPic(String base64encodeStr, @Nullable  ReadableMap options) {
        int width = 0;
        int leftPadding = 0;
        if(options!=null){
            width = options.hasKey("width") ? options.getInt("width") : 0;
            leftPadding = options.hasKey("left")?options.getInt("left") : 0;
        }

        //cannot larger then devicesWith;
        if(width > deviceWidth || width == 0){
            width = deviceWidth;
        }

        byte[] bytes = Base64.decode(base64encodeStr, Base64.DEFAULT);
        Bitmap mBitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        int nMode = 0;
        if (mBitmap != null) {
            /**
             * Parameters:
             * mBitmap  要打印的图片
             * nWidth   打印宽度（58和80）
             * nMode    打印模式
             * Returns: byte[]
             */
            byte[] data = PrintPicture.POS_PrintBMP(mBitmap, width, nMode, leftPadding);
            //	SendDataByte(buffer);
            sendDataByte(Command.ESC_Init);
            sendDataByte(Command.LF);
            sendDataByte(data);
            sendDataByte(PrinterCommand.POS_Set_PrtAndFeedPaper(30));
            sendDataByte(PrinterCommand.POS_Set_Cut(1));
            sendDataByte(PrinterCommand.POS_Set_PrtInit());
        }
    }


    @ReactMethod
    public void selfTest(@Nullable Callback cb) {
        boolean result = sendDataByte(PrinterCommand.POS_Set_PrtSelfTest());
        if (cb != null) {
            cb.invoke(result);
        }
    }

    /**
     * Rotate 90 degree, 0-no rotate, 1-rotate
     * @param rotate  0-no rotate, 1-rotate
     */
    @ReactMethod
    public void rotate(int rotate,final Promise promise) {
        if(sendDataByte(PrinterCommand.POS_Set_Rotate(rotate))){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }

    @ReactMethod
    public void setBlob(int weight,final Promise promise) {
        if(sendDataByte(PrinterCommand.POS_Set_Bold(weight))){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_NOT_SEND");
        }
    }

    @ReactMethod
    public void printQRCode(String content, int size, int correctionLevel, final Promise promise) {
        try {
            Log.i(TAG, "生成的文本：" + content);
            // 把输入的文本转为二维码
            Hashtable<EncodeHintType, Object> hints = new Hashtable<EncodeHintType, Object>();
            hints.put(EncodeHintType.CHARACTER_SET, "utf-8");
            hints.put(EncodeHintType.ERROR_CORRECTION, ErrorCorrectionLevel.forBits(correctionLevel));
            BitMatrix bitMatrix = new QRCodeWriter().encode(content,
                    BarcodeFormat.QR_CODE, size, size, hints);

            int width = bitMatrix.getWidth();
            int height = bitMatrix.getHeight();

            System.out.println("w:" + width + "h:"
                    + height);

            int[] pixels = new int[width * height];
            for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                    if (bitMatrix.get(x, y)) {
                        pixels[y * width + x] = 0xff000000;
                    } else {
                        pixels[y * width + x] = 0xffffffff;
                    }
                }
            }

            Bitmap bitmap = Bitmap.createBitmap(width, height,
                    Bitmap.Config.ARGB_8888);

            bitmap.setPixels(pixels, 0, width, 0, 0, width, height);

            //TODO: may need a left padding to align center.
            byte[] data = PrintPicture.POS_PrintBMP(bitmap, size, 0, 0);
            if (sendDataByte(data)) {
                promise.resolve(null);
            } else {
                promise.reject("COMMAND_NOT_SEND");
            }
        } catch (Exception e) {
            promise.reject(e.getMessage(), e);
        }
    }

    @ReactMethod
    public void printBarCode(String str, int nType, int nWidthX, int nHeight,
                             int nHriFontType, int nHriFontPosition) {
        byte[] command = PrinterCommand.getBarCodeCommand(str, nType, nWidthX, nHeight, nHriFontType, nHriFontPosition);
        sendDataByte(command);
    }

    private boolean sendDataByte(byte[] data) {
        if (data==null || mService.getState() != BluetoothService.STATE_CONNECTED) {
            return false;
        }
        mService.write(data);
        return true;
    }

    // 根据Unicode编码完美的判断中文汉字和符号
    private static boolean isChinese(char c) {
        Character.UnicodeBlock ub = Character.UnicodeBlock.of(c);
        if (ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS
                || ub == Character.UnicodeBlock.CJK_COMPATIBILITY_IDEOGRAPHS
                || ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_A
                || ub == Character.UnicodeBlock.CJK_UNIFIED_IDEOGRAPHS_EXTENSION_B
                || ub == Character.UnicodeBlock.CJK_SYMBOLS_AND_PUNCTUATION
                || ub == Character.UnicodeBlock.HALFWIDTH_AND_FULLWIDTH_FORMS
                || ub == Character.UnicodeBlock.GENERAL_PUNCTUATION) {
            return true;
        }
        return false;
    }

    @Override
    public void onBluetoothServiceStateChanged(int state, Map<String, Object> boundle) {

    }

    /****************************************************************************************************/

    private static class ColumnSplitedString{
        private int shorter;
        private String str;

        public ColumnSplitedString(int shorter, String str) {
            this.shorter = shorter;
            this.str = str;
        }

        public int getShorter() {
            return shorter;
        }

        public String getStr() {
            return str;
        }
    }

}
