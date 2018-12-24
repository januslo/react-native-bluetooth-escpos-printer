package cn.jystudio.bluetooth.tsc;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import cn.jystudio.bluetooth.BluetoothService;
import cn.jystudio.bluetooth.BluetoothServiceStateObserver;
import com.facebook.react.bridge.*;

import java.util.Map;
import java.util.Vector;

/**
 * Created by januslo on 2018/9/22.
 */
public class RNBluetoothTscPrinterModule extends ReactContextBaseJavaModule
implements BluetoothServiceStateObserver{
    private static final String TAG="BluetoothTscPrinter";
    private BluetoothService mService;

    public RNBluetoothTscPrinterModule(ReactApplicationContext reactContext,BluetoothService bluetoothService) {
        super(reactContext);
        this.mService = bluetoothService;
        this.mService.addStateObserver(this);
    }

    @Override
    public String getName() {
        return "BluetoothTscPrinter";
    }

    @ReactMethod
    public void printLabel(final ReadableMap options, final Promise promise) {
        int width = options.getInt("width");
        int height = options.getInt("height");
        int gap = options.hasKey("gap") ? options.getInt("gap") : 0;
        TscCommand.SPEED speed = options.hasKey("speed")?this.findSpeed(options.getInt("speed")):null;
        TscCommand.ENABLE enable = options.hasKey("tear") ?
                options.getString("tear").equalsIgnoreCase(TscCommand.ENABLE.ON.getValue()) ? TscCommand.ENABLE.ON : TscCommand.ENABLE.OFF
                : TscCommand.ENABLE.OFF;
        ReadableArray texts = options.hasKey("text")? options.getArray("text"):null;
        ReadableArray qrCodes = options.hasKey("qrcode")? options.getArray("qrcode"):null;
        ReadableArray barCodes = options.hasKey("barcode")? options.getArray("barcode"):null;
        ReadableArray images = options.hasKey("image")? options.getArray("image"):null;
        ReadableArray reverses = options.hasKey("reverse")? options.getArray("reverse"):null;

        TscCommand.DIRECTION direction = options.hasKey("direction") ?
                TscCommand.DIRECTION.BACKWARD.getValue() == options.getInt("direction") ? TscCommand.DIRECTION.BACKWARD : TscCommand.DIRECTION.FORWARD
                : TscCommand.DIRECTION.FORWARD;
//        Not Support Yet
//        TscCommand.MIRROR mirror = options.hasKey("mirror") ?
//                TscCommand.MIRROR.MIRROR.getValue() == options.getInt("mirror") ? TscCommand.MIRROR.MIRROR : TscCommand.MIRROR.NORMAL
//                : TscCommand.MIRROR.NORMAL;
        TscCommand.DENSITY density = options.hasKey("density")?this.findDensity(options.getInt("density")):null;
        ReadableArray reference = options.hasKey("reference")?options.getArray("reference"):null;

        boolean sound = false;
        if (options.hasKey("sound") && options.getInt("sound") == 1) {
            sound = true;
        }
        boolean home = false;
        if(options.hasKey("home") && options.getInt("home")== 1){
            home = true;
        }
        TscCommand tsc = new TscCommand();
        if(speed != null){
            tsc.addSpeed(speed);//设置打印速度
        }
        if(density != null){
            tsc.addDensity(density);//设置打印浓度
        }
        tsc.addSize(width,height); //设置标签尺寸，按照实际尺寸设置
        tsc.addGap(gap);           //设置标签间隙，按照实际尺寸设置，如果为无间隙纸则设置为0
         tsc.addDirection(direction);//设置打印方向
        //设置原点坐标
        if (reference != null && reference.size() == 2) {
            tsc.addReference(reference.getInt(0), reference.getInt(1));
        } else {
            tsc.addReference(0, 0);
        }
        tsc.addTear(enable); //撕纸模式开启
        if(home) {
            tsc.addBackFeed(16);
            tsc.addHome();//走纸到开始位置
        }
        tsc.addCls();// 清除打印缓冲区
        //绘制简体中文
        for (int i = 0;texts!=null&& i < texts.size(); i++) {
            ReadableMap text = texts.getMap(i);
            String t = text.getString("text");
            int x = text.getInt("x");
            int y = text.getInt("y");
            TscCommand.FONTTYPE fonttype = this.findFontType(text.getString("fonttype"));
            TscCommand.ROTATION rotation = this.findRotation(text.getInt("rotation"));
            TscCommand.FONTMUL xscal = this.findFontMul(text.getInt("xscal"));
            TscCommand.FONTMUL yscal = this.findFontMul(text.getInt("xscal"));
            boolean bold = text.hasKey("bold") && text.getBoolean("bold");

            try {
                byte[] temp = t.getBytes("UTF-8");
                String temStr = new String(temp, "UTF-8");
                t = new String(temStr.getBytes("GB2312"), "GB2312");//打印的文字
            } catch (Exception e) {
                promise.reject("INVALID_TEXT", e);
                return;
            }

            tsc.addText(x, y, fonttype/*字体类型*/,
                    rotation/*旋转角度*/, xscal/*横向放大*/, yscal/*纵向放大*/, t);

            if(bold){
                tsc.addText(x+1, y, fonttype,
                        rotation, xscal, yscal, t/*这里的t可能需要替换成同等长度的空格*/);
                tsc.addText(x, y+1, fonttype,
                        rotation, xscal, yscal, t/*这里的t可能需要替换成同等长度的空格*/);
            }
        }

        //绘制图片
        if(images != null){
            for (int i = 0; i < images.size(); i++) {
                ReadableMap img = images.getMap(i);
                int x = img.getInt("x");
                int y = img.getInt("y");
                int imgWidth = img.getInt("width");
                TscCommand.BITMAP_MODE mode = this.findBitmapMode(img.getInt("mode"));
                String image  = img.getString("image");
                byte[] decoded = Base64.decode(image, Base64.DEFAULT);
                Bitmap b = BitmapFactory.decodeByteArray(decoded, 0, decoded.length);
                tsc.addBitmap(x,y, mode, imgWidth,b);
            }
        }

        if (qrCodes != null) {
            for (int i = 0; i < qrCodes.size(); i++) {
                ReadableMap qr = qrCodes.getMap(i);
                int x = qr.getInt("x");
                int y = qr.getInt("y");
                int qrWidth = qr.getInt("width");
                TscCommand.EEC level = this.findEEC(qr.getString("level"));
                TscCommand.ROTATION rotation = this.findRotation(qr.getInt("rotation"));
                String code = qr.getString("code");
                tsc.addQRCode(x, y, level, qrWidth, rotation, code);
            }
        }
        if (barCodes != null) {
            for (int i = 0; i < barCodes.size(); i++) {
                ReadableMap bar = barCodes.getMap(i);
                int x = bar.hasKey("x") ? bar.getInt("x") : 0;
                int y = bar.hasKey("y") ? bar.getInt("y") : 0;
                int barHeight = bar.hasKey("height") ? bar.getInt("height") : 200;
                int barWide = bar.hasKey("wide") ? bar.getInt("wide") : 2;
                int narrow = bar.hasKey("narrow") ? bar.getInt("narrow") : 1;
                TscCommand.ROTATION rotation = this.findRotation(bar.getInt("rotation"));
                String code = bar.getString("code");
                TscCommand.BARCODETYPE type = this.findBarcodeType(bar.getString("type"));
                TscCommand.READABLE readable = this.findReadable(bar.getInt("readable"));
                tsc.add1DBarcode(x, y, type, barHeight, barWide, narrow, readable, rotation, code);
            }
        }

        if(reverses != null){
            for(int i=0; i < reverses.size(); i++){
                ReadableMap area = reverses.getMap(i);
                int ax = area.getInt("x");
                int ay = area.getInt("y");
                int aWidth = area.getInt("width");
                int aHeight = area.getInt("height");
                tsc.addReverse(ax,ay,aWidth,aHeight);
            }
        }

        tsc.addPrint(1, 1); // 打印标签
        if (sound) {
            tsc.addSound(2, 100); //打印标签后 蜂鸣器响
        }
        Vector<Byte> bytes = tsc.getCommand();
        byte[] tosend = new byte[bytes.size()];
        for(int i=0;i<bytes.size();i++){
            tosend[i]= bytes.get(i);
        }
        if(sendDataByte(tosend)){
            promise.resolve(null);
        }else{
            promise.reject("COMMAND_SEND_ERROR");
        }
    }

    private TscCommand.BARCODETYPE findBarcodeType(String type) {
        TscCommand.BARCODETYPE barcodeType = TscCommand.BARCODETYPE.CODE128;
        for (TscCommand.BARCODETYPE t : TscCommand.BARCODETYPE.values()) {
            if ((""+t.getValue()).equalsIgnoreCase(type)) {
                barcodeType = t;
                break;
            }
        }
        return barcodeType;
    }

    private TscCommand.READABLE findReadable(int readable) {
        TscCommand.READABLE ea = TscCommand.READABLE.EANBLE;
        if (TscCommand.READABLE.DISABLE.getValue() == readable) {
            ea = TscCommand.READABLE.DISABLE;
        }
        return ea;
    }

    private TscCommand.FONTMUL findFontMul(int scan) {
        TscCommand.FONTMUL mul = TscCommand.FONTMUL.MUL_1;
        for (TscCommand.FONTMUL m : TscCommand.FONTMUL.values()) {
            if (m.getValue() == scan) {
                mul = m;
                break;
            }
        }
        return mul;
    }

    private TscCommand.ROTATION findRotation(int rotation) {
        TscCommand.ROTATION rt = TscCommand.ROTATION.ROTATION_0;
        for (TscCommand.ROTATION r : TscCommand.ROTATION.values()) {
            if (r.getValue() == rotation) {
                rt = r;
                break;
            }
        }
        return rt;
    }

    private TscCommand.FONTTYPE findFontType(String fonttype) {
        TscCommand.FONTTYPE ft = TscCommand.FONTTYPE.FONT_CHINESE;
        for (TscCommand.FONTTYPE f : TscCommand.FONTTYPE.values()) {
            if ((""+f.getValue()).equalsIgnoreCase(fonttype)) {
                ft = f;
                break;
            }
        }
        return ft;
    }


    private TscCommand.SPEED findSpeed(int speed){
        TscCommand.SPEED sd = null;
        switch(speed){
            case 1:
                sd = TscCommand.SPEED.SPEED1DIV5;
                break;
            case 2:
                sd = TscCommand.SPEED.SPEED2;
                break;
            case 3:
                sd = TscCommand.SPEED.SPEED3;
                break;
            case 4:
                sd = TscCommand.SPEED.SPEED4;
                break;
        }
        return sd;
    }

    private TscCommand.EEC findEEC(String level) {
        TscCommand.EEC eec = TscCommand.EEC.LEVEL_L;
        for (TscCommand.EEC e : TscCommand.EEC.values()) {
            if (e.getValue().equalsIgnoreCase(level)) {
                eec = e;
                break;
            }
        }
        return eec;
    }

    private TscCommand.DENSITY findDensity(int density){
        TscCommand.DENSITY ds = null;
        for (TscCommand.DENSITY d : TscCommand.DENSITY.values()) {
            if (d.getValue() == density) {
                ds = d;
                break;
            }
        }
        return ds;
    }
    private TscCommand.BITMAP_MODE findBitmapMode(int mode){
        TscCommand.BITMAP_MODE bm = TscCommand.BITMAP_MODE.OVERWRITE;
        for (TscCommand.BITMAP_MODE m : TscCommand.BITMAP_MODE.values()) {
            if (m.getValue() == mode) {
                bm = m;
                break;
            }
        }
        return bm;
    }

    private boolean sendDataByte(byte[] data) {
        if (mService.getState() != BluetoothService.STATE_CONNECTED) {
            return false;
        }
        mService.write(data);
        return true;
    }

    @Override
    public void onBluetoothServiceStateChanged(int state, Map<String, Object> boundle) {

    }
}
