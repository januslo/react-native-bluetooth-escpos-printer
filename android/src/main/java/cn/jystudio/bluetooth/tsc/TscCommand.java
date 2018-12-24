package cn.jystudio.bluetooth.tsc;

import android.graphics.Bitmap;
import android.util.Log;
import cn.jystudio.bluetooth.escpos.command.sdk.PrintPicture;

import java.io.UnsupportedEncodingException;
import java.util.Vector;

public class TscCommand {
    private static final String DEBUG_TAG = "TSCCommand";
    private Vector<Byte> Command = null;

    public static enum FOOT {
        F2(0), F5(1);

        private FOOT(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum SPEED {
        SPEED1DIV5(1.5F), SPEED2(2.0F), SPEED3(3.0F), SPEED4(4.0F);

        private SPEED(float value) {
            this.value = value;
        }

        private final float value;

        public float getValue() {
            return this.value;
        }
    }

    public static enum READABLE {
        DISABLE(0), EANBLE(1);

        private READABLE(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum BITMAP_MODE {
        OVERWRITE(0), OR(1), XOR(2);

        private BITMAP_MODE(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum DENSITY {
        DNESITY0(0), DNESITY1(1), DNESITY2(2), DNESITY3(3), DNESITY4(4), DNESITY5(5), DNESITY6(6), DNESITY7(
                7), DNESITY8(8), DNESITY9(9), DNESITY10(10), DNESITY11(11), DNESITY12(12), DNESITY13(13), DNESITY14(
                14), DNESITY15(15);

        private DENSITY(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum DIRECTION {
        FORWARD(0), BACKWARD(1);

        private DIRECTION(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum CODEPAGE {
        PC437(437), PC850(850), PC852(852), PC860(860), PC863(863), PC865(865), WPC1250(1250), WPC1252(1252), WPC1253(
                1253), WPC1254(1254);

        private CODEPAGE(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum FONTMUL {
        MUL_1(1), MUL_2(2), MUL_3(3), MUL_4(4), MUL_5(5), MUL_6(6), MUL_7(7), MUL_8(8), MUL_9(9), MUL_10(10);

        private FONTMUL(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum FONTTYPE {
        FONT_1("1"), FONT_2("2"), FONT_3("3"), FONT_4("4"), FONT_5("5"), FONT_6("6"), FONT_7("7"), FONT_8(
                "8"), FONT_CHINESE("TSS24.BF2"), FONT_TAIWAN("TST24.BF2"), FONT_KOREAN("K");

        private FONTTYPE(String value) {
            this.value = value;
        }

        private final String value;

        public String getValue() {
            return this.value;
        }
    }

    public static enum ROTATION {
        ROTATION_0(0), ROTATION_90(90), ROTATION_180(180), ROTATION_270(270);

        private ROTATION(int value) {
            this.value = value;
        }

        private final int value;

        public int getValue() {
            return this.value;
        }
    }

    public static enum BARCODETYPE {
        CODE128("128"), CODE128M("128M"), EAN128("EAN128"), ITF25("25"), ITF25C("25C"), CODE39("39"), CODE39C(
                "39C"), CODE39S("39S"), CODE93("93"), EAN13("EAN13"), EAN13_2("EAN13+2"), EAN13_5("EAN13+5"), EAN8(
                "EAN8"), EAN8_2("EAN8+2"), EAN8_5("EAN8+5"), CODABAR("CODA"), POST("POST"), UPCA(
                "EAN13"), UPCA_2("EAN13+2"), UPCA_5("EAN13+5"), UPCE("EAN13"), UPCE_2(
                "EAN13+2"), UPCE_5("EAN13+5"), CPOST("CPOST"), MSI("MSI"), MSIC(
                "MSIC"), PLESSEY("PLESSEY"), ITF14("ITF14"), EAN14("EAN14");

        private final String value;

        private BARCODETYPE(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }
    }

    public static enum ENABLE {
        ON("ON"), OFF("OFF");

        private final String value;

        private ENABLE(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }
    }

    public static enum EEC {
        LEVEL_L("L"),
        LEVEL_M("M"),
        LEVEL_Q("Q"),
        LEVEL_H("H");
        private final String value;

        private EEC(String value) {
            this.value = value;
        }

        public String getValue() {
            return this.value;
        }

    }

//    public static enum MIRROR {
//        NORMAL(0), MIRROR(1);
//        private final int value;
//        private MIRROR(int value){
//            this.value = value;
//        }
//        public int getValue(){return this.value;}
//    }

    public TscCommand() {
        this.Command = new Vector(4096, 1024);
    }

    public TscCommand(int width, int height, int gap) {
        this.Command = new Vector(4096, 1024);
        addSize(width, height);
        addGap(gap);
    }

    public void clrCommand() {
        this.Command.clear();
    }

    private void addStrToCommand(String str) {
        byte[] bs = null;
        if (!str.equals("")) {
            try {
                bs = str.getBytes("GB2312");
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
            for (int i = 0; i < bs.length; i++) {
                this.Command.add(Byte.valueOf(bs[i]));
            }
        }
    }

    public void addGap(int gap) {
        String str = new String();
        str = "GAP " + gap + " mm," + 0 + " mm" + "\r\n";
        addStrToCommand(str);
    }

    public void addSize(int width, int height) {
        String str = new String();
        str = "SIZE " + width + " mm," + height + " mm" + "\r\n";
        addStrToCommand(str);
    }

    public void addCashdrwer(FOOT m, int t1, int t2) {
        String str = new String();
        str = "CASHDRAWER " + m.getValue() + "," + t1 + "," + t2 + "\r\n";
        addStrToCommand(str);
    }

    public void addOffset(int offset) {
        String str = new String();
        str = "OFFSET " + offset + " mm" + "\r\n";
        addStrToCommand(str);
    }

    public void addSpeed(SPEED speed) {
        String str = new String();
        str = "SPEED " + speed.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addDensity(DENSITY density) {
        String str = new String();
        str = "DENSITY " + density.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addDirection(DIRECTION direction) {
        String str = new String();
        str = "DIRECTION " + direction.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addReference(int x, int y) {
        String str = new String();
        str = "REFERENCE " + x + "," + y + "\r\n";
        addStrToCommand(str);
    }

    public void addShif(int shift) {
        String str = new String();
        str = "SHIFT " + shift + "\r\n";
        addStrToCommand(str);
    }

    public void addCls() {
        String str = new String();
        str = "CLS\r\n";
        addStrToCommand(str);
    }

    public void addFeed(int dot) {
        String str = new String();
        str = "FEED " + dot + "\r\n";
        addStrToCommand(str);
    }

    public void addBackFeed(int dot) {
        String str = new String();
        str = "BACKFEED " + dot + "\r\n";
        addStrToCommand(str);
    }

    public void addFormFeed() {
        String str = new String();
        str = "FORMFEED\r\n";
        addStrToCommand(str);
    }

    public void addHome() {
        String str = new String();
        str = "HOME\r\n";
        addStrToCommand(str);
    }

    public void addPrint(int m, int n) {
        String str = new String();
        str = "PRINT " + m + "," + n + "\r\n";
        addStrToCommand(str);
    }

    public void addCodePage(CODEPAGE page) {
        String str = new String();
        str = "CODEPAGE " + page.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addSound(int level, int interval) {
        String str = new String();
        str = "SOUND " + level + "," + interval + "\r\n";
        addStrToCommand(str);
    }

    public void addLimitFeed(int n) {
        String str = new String();
        str = "LIMITFEED " + n + "\r\n";
        addStrToCommand(str);
    }

    public void addSelfTest() {
        String str = new String();
        str = "SELFTEST\r\n";
        addStrToCommand(str);
    }

    public void addBar(int x, int y, int width, int height) {
        String str = new String();
        str = "BAR " + x + "," + y + "," + width + "," + height + "\r\n";
        addStrToCommand(str);
    }

    public void addText(int x, int y, FONTTYPE font, ROTATION rotation, FONTMUL Xscal, FONTMUL Yscal, String text) {
        String str = new String();
        str = "TEXT " + x + "," + y + "," + "\"" + font.getValue() + "\"" + "," + rotation.getValue() + ","
                + Xscal.getValue() + "," + Yscal.getValue() + "," + "\"" + text + "\"" + "\r\n";
        addStrToCommand(str);
    }

    public void add1DBarcode(int x, int y, BARCODETYPE type, int height, int wide, int narrow, READABLE readable, ROTATION rotation,
                             String content) {
        String str = new String();
        str = "BARCODE " + x + "," + y + "," + "\"" + type.getValue() + "\"" + "," + height + "," + readable.getValue()
                + "," + rotation.getValue() + "," + narrow + "," + wide + "," + "\"" + content + "\"" + "\r\n";
        addStrToCommand(str);
    }

    public void addQRCode(int x, int y, EEC level, int qrWidth, ROTATION rotation, String code) {
        //var cmd = 'QRCODE 条码X方向起始点,条码Y方向起始点,纠错级别,二维码高度,A(A和M),旋转角度,M2（分为类型1和类型2）,S1 (s1-s8,默认s7),\"1231你好2421341325454353\"';
        String str = "QRCODE " + x + "," + y + "," + level.getValue() + "," + qrWidth + ",A," + rotation.getValue() + ",M2,S1,\"" + code + "\"\r\n";
        addStrToCommand(str);
    }
//    public void addBitmap(int x,int y,BITMAP_MODE mode,int imgWidth, Bitmap b){
//
//        int width = ((imgWidth + 7) / 8) * 8;
//        int height = b.getHeight() * width / b.getWidth();
//        height = ((height + 7) / 8) * 8;
//
//        Bitmap rszBitmap = b;
//        if (b.getWidth() != width) {
//            rszBitmap = Bitmap.createScaledBitmap(b, width, height, true);
//        }
//
//        Bitmap grayBitmap = PrintPicture.toGrayscale(rszBitmap);
//        byte[] dithered = PrintPicture.thresholdToBWPic(grayBitmap);
//        byte[] data =PrintPicture.eachLinePixToCmd(dithered, width, mode.getValue());
//        height = dithered.length / width;
//        width /= 8;
//        //{command} {X},{Y },{width},{ height },{mode},{bitmap data }
//        //  String str = "BITMAP " + x + "," + y + "," + width + "," + height + "," + mode.getValue() + ",";
//        String str = "BITMAP "+x+","+y+","+width+","+height+","+mode.getValue()+",";
//        addStrToCommand(str);
//        for(int i=0;i<data.length;i++){
//            Command.add(Byte.valueOf(data[i]));
//        }
//        addStrToCommand("\r\n");
//    }


    public void addBitmap(int x, int y, TscCommand.BITMAP_MODE mode, int nWidth, Bitmap b) {
        if (b != null) {
            int width = (nWidth + 7) / 8 * 8;
            int height = b.getHeight() * width / b.getWidth();
            Log.d("BMP", "bmp.getWidth() " + b.getWidth());
            Bitmap grayBitmap = PrintPicture.toGrayscale(b);
            Bitmap rszBitmap = PrintPicture.resizeImage(grayBitmap, width, height);
            byte[] src = PrintPicture.bitmapToBWPix(rszBitmap);
            height = src.length / width;
            width /= 8;
            String str = "BITMAP " + x + "," + y + "," + width + "," + height + "," + mode.getValue() + ",";
            this.addStrToCommand(str);
            byte[] codecontent = PrintPicture.pixToTscCmd(src);

            for (int k = 0; k < codecontent.length; ++k) {
                this.Command.add(Byte.valueOf(codecontent[k]));
            }

            Log.d("TSCCommand", "codecontent" + codecontent);
            addStrToCommand("\r\n");
        }

    }

    public void addBox(int x, int y, int xend, int yend) {
        String str = new String();
        str = "BAR " + x + "," + y + "," + xend + "," + yend + "\r\n";
        addStrToCommand(str);
    }

    public void addErase(int x, int y, int xwidth, int yheight) {
        String str = new String();
        str = "ERASE " + x + "," + y + "," + xwidth + "," + yheight + "\r\n";
        addStrToCommand(str);
    }

    public void addReverse(int x, int y, int xwidth, int yheight) {
        String str = new String();
        str = "REVERSE " + x + "," + y + "," + xwidth + "," + yheight + "\r\n";
        addStrToCommand(str);
    }

    public Vector<Byte> getCommand() {
        return this.Command;
    }

    public void queryPrinterType() {
        String str = new String();
        str = "~!T\r\n";
        addStrToCommand(str);
    }

    public void queryPrinterStatus() {
        this.Command.add(Byte.valueOf((byte) 27));
        this.Command.add(Byte.valueOf((byte) 33));
        this.Command.add(Byte.valueOf((byte) 63));
    }

    public void resetPrinter() {
        this.Command.add(Byte.valueOf((byte) 27));
        this.Command.add(Byte.valueOf((byte) 33));
        this.Command.add(Byte.valueOf((byte) 82));
    }

    public void queryPrinterLife() {
        String str = new String();
        str = "~!@\r\n";
        addStrToCommand(str);
    }

    public void queryPrinterMemory() {
        String str = new String();
        str = "~!A\r\n";
        addStrToCommand(str);
    }

    public void queryPrinterFile() {
        String str = new String();
        str = "~!F\r\n";
        addStrToCommand(str);
    }

    public void queryPrinterCodePage() {
        String str = new String();
        str = "~!I\r\n";
        addStrToCommand(str);
    }

    public void addPeel(ENABLE enable) {
        String str = new String();
        str = "SET PEEL " + enable.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addTear(ENABLE enable) {
        String str = new String();
        str = "SET TEAR " + enable.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addCutter(ENABLE enable) {
        String str = new String();
        str = "SET CUTTER " + enable.getValue() + "\r\n";
        addStrToCommand(str);
    }

    public void addPartialCutter(ENABLE enable) {
        String str = new String();
        str = "SET PARTIAL_CUTTER " + enable.getValue() + "\r\n";
        addStrToCommand(str);
    }


}
