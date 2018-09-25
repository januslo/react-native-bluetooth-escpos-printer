
package cn.jystudio.bluetooth.escpos;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Base64;
import cn.jystudio.bluetooth.BluetoothService;
import cn.jystudio.bluetooth.BluetoothServiceStateObserver;
import cn.jystudio.bluetooth.escpos.command.sdk.Command;
import cn.jystudio.bluetooth.escpos.command.sdk.PrintPicture;
import cn.jystudio.bluetooth.escpos.command.sdk.PrinterCommand;
import com.facebook.react.bridge.*;

import javax.annotation.Nullable;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;

public class RNBluetoothEscposPrinterModule extends ReactContextBaseJavaModule
implements BluetoothServiceStateObserver{
    private static final String TAG = "BluetoothEscposPrinter";

    public static final int WIDTH_58 = 384;
    public static final int WIDTH_80 = 576;
    private final ReactApplicationContext reactContext;
    /******************************************************************************************************/

    private int deviceWidth = WIDTH_58;
    private BluetoothService mService;


    public RNBluetoothEscposPrinterModule(ReactApplicationContext reactContext, BluetoothService bluetoothService) {
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
    public void printText(String text, ReadableMap options, Callback cb) {
        String encoding = options.hasKey("encoding") ? options.getString("encoding") : "GBK";
        int codepage = options.hasKey("codepage") ? options.getInt("codepage") : 0;
        int widthTimes = options.hasKey("widthtimes") ? options.getInt("widthtimes") : 0;
        int heigthTimes = options.hasKey("heigthtimes") ? options.getInt("heigthtimes") : 0;
        int fonttype = options.hasKey("fonttype") ? options.getInt("fonttype") : 0;
        byte[] bytes = PrinterCommand.POS_Print_Text(text, encoding, codepage, widthTimes, heigthTimes, fonttype);
        cb.invoke(sendDataByte(bytes));
    }

    @ReactMethod
    public void setWidth(int width) {
        deviceWidth = width;
    }

    @ReactMethod
    public void printPic(String base64encodeStr) {
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
            byte[] data = PrintPicture.POS_PrintBMP(mBitmap, deviceWidth, nMode);
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

    @ReactMethod
    public void rotate(int rotate) {
        sendDataByte(PrinterCommand.POS_Set_Rotate(rotate));
    }

    @ReactMethod
    public void setBlob(int weight) {
        sendDataByte(PrinterCommand.POS_Set_Bold(weight));
    }

    private boolean sendDataString(String data) {
        if (data.length() > 0) {
            try {
                return sendDataByte(data.getBytes("UTF-8"));
            } catch (UnsupportedEncodingException e) {
                return false;
            }
        }
        return true;
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

    /****************************************************************************************************/

}