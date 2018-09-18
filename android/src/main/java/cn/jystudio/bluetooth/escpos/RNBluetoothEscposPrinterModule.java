
package cn.jystudio.bluetooth.escpos;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothAdapter;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.widget.Toast;
import cn.jystudio.bluetooch.BluetoothService;
import com.facebook.react.bridge.*;

import java.util.concurrent.ArrayBlockingQueue;

public class RNBluetoothEscposPrinterModule extends ReactContextBaseJavaModule implements ActivityEventListener {
    private static final String TAG="RNBluetoothEscposPrinterModule";

    // Intent request codes
    private static final int REQUEST_CONNECT_DEVICE = 1;
    private static final int REQUEST_ENABLE_BT = 2;
    private static final int REQUEST_CHOSE_BMP = 3;
    private static final int REQUEST_CAMER = 4;

    public static final int MESSAGE_STATE_CHANGE = BluetoothService.MESSAGE_STATE_CHANGE;
    public static final int MESSAGE_READ = BluetoothService.MESSAGE_READ;
    public static final int MESSAGE_WRITE = BluetoothService.MESSAGE_WRITE;
    public static final int MESSAGE_DEVICE_NAME = BluetoothService.MESSAGE_DEVICE_NAME;
    public static final int MESSAGE_TOAST = BluetoothService.MESSAGE_TOAST;
    public static final int MESSAGE_CONNECTION_LOST = BluetoothService.MESSAGE_CONNECTION_LOST;
    public static final int MESSAGE_UNABLE_CONNECT = BluetoothService.MESSAGE_UNABLE_CONNECT;
    public static final String DEVICE_NAME =BluetoothService.DEVICE_NAME;
    public static final String TOAST= BluetoothService.TOAST;

    private static final ArrayBlockingQueue<InvokResult> resultQueue = new ArrayBlockingQueue<InvokResult>(30);

  private final ReactApplicationContext reactContext;
    /******************************************************************************************************/
    // Name of the connected device
    private String mConnectedDeviceName = null;
    // Local Bluetooth adapter
    private BluetoothAdapter mBluetoothAdapter = null;
    // Member object for the services
    private BluetoothService mService = null;


  public RNBluetoothEscposPrinterModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
      this.reactContext.addActivityEventListener(this);
      // Get local Bluetooth adapter
      mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();

      // If the adapter is null, then Bluetooth is not supported
      if (mBluetoothAdapter == null) {
          Toast.makeText(this.reactContext, "Bluetooth is not available",
                  Toast.LENGTH_LONG).show();
      }
  }

  @Override
  public String getName() {
    return "BluetoothEscposPrinter";
  }


    @ReactMethod
    public void enableBluetooth(final Promise promise){
        // If Bluetooth is not on, request that it be enabled.
        // setupChat() will then be called during onActivityResult
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(
                    BluetoothAdapter.ACTION_REQUEST_ENABLE);
            this.reactContext.startActivityForResult(enableIntent, REQUEST_ENABLE_BT, Bundle.EMPTY);
            try {
                InvokResult result = resultQueue.take();
                if(result.isOK()){
                    promise.resolve(result.getMsg());
                }else{
                    promise.reject(result.getMsg(),new Throwable(result.getMsg()));
                }
            }catch (Exception e){
                promise.reject(e.getMessage(),e);
            }
            // Otherwise, setup the session
        } else {
            if (mService == null){
                mService = new BluetoothService(reactContext, bluetoothServiceHandler);
            }

        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {

    }

    /****************************************************************************************************/
    @SuppressLint("HandlerLeak")
    private final Handler bluetoothServiceHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case MESSAGE_STATE_CHANGE:
                    Log.i(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
                    switch (msg.arg1) {
                        case BluetoothService.STATE_CONNECTED:
                           //// TODO: 2018/9/18  
                            break;
                        case BluetoothService.STATE_CONNECTING:
                            // TODO: 2018/9/18  
                            break;
                        case BluetoothService.STATE_LISTEN:
                        case BluetoothService.STATE_NONE:
                            // TODO: 2018/9/18
                            break;
                    }
                    break;
                case MESSAGE_WRITE:
                    // TODO: 2018/9/18
                    break;
                case MESSAGE_READ:
                    // TODO: 2018/9/18
                    break;
                case MESSAGE_DEVICE_NAME:
                    // save the connected device's name
                    mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
                    Toast.makeText(reactContext,
                            "Connected to " + mConnectedDeviceName,
                            Toast.LENGTH_SHORT).show();
                    break;
                case MESSAGE_TOAST:
                    Toast.makeText(reactContext,
                            msg.getData().getString(TOAST), Toast.LENGTH_SHORT)
                            .show();
                    break;
                case MESSAGE_CONNECTION_LOST:    //蓝牙已断开连接
                    Toast.makeText(reactContext, "Device connection was lost",
                            Toast.LENGTH_SHORT).show();
                    break;
                case MESSAGE_UNABLE_CONNECT:     //无法连接设备
                    Toast.makeText(reactContext, "Unable to connect device",
                            Toast.LENGTH_SHORT).show();
                    break;
            }
        }
    };

    protected static class InvokResult{
        public static final int STATUS_OK=1;
        public static final int STATUS_ERR=0;

        private int status;
        private String msg;

        public InvokResult(int status, String msg) {
            this.status = status;
            this.msg = msg;
        }
        public boolean isOK(){
            return STATUS_OK == this.status;
        }

        public String getMsg() {
            return msg;
        }
    }
}