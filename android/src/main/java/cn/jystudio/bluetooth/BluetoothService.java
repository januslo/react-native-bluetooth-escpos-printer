
package cn.jystudio.bluetooth;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothServerSocket;
import android.bluetooth.BluetoothSocket;
import android.content.Context;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.*;
import java.lang.reflect.Method;

/**
 * This class does all the work for setting up and managing Bluetooth
 * connections with other devices.
 */
public class BluetoothService {
    // Debugging
    private static final String TAG = "BluetoothService";
    private static final boolean DEBUG = true;


    // Name for the SDP record when creating server socket
    private static final String NAME = "BTPrinter";
    //UUID must be this
    // Unique UUID for this application
    private static final UUID MY_UUID = UUID.fromString("00001101-0000-1000-8000-00805F9B34FB");

    // Member fields
    private BluetoothAdapter mAdapter;

    private ConnectedThread mConnectedThread;
    private int mState;

    // Constants that indicate the current connection state
    public static final int STATE_NONE = 0;       // we're doing nothing
   // public static final int STATE_LISTEN = 1;     // now listening for incoming connections //feathure removed.
    public static final int STATE_CONNECTING = 2; // now initiating an outgoing connection
    public static final int STATE_CONNECTED = 3;  // now connected to a remote device


    public static final int MESSAGE_STATE_CHANGE = 4;
    public static final int MESSAGE_READ = 5;
    public static final int MESSAGE_WRITE = 6;
    public static final int MESSAGE_DEVICE_NAME = 7;
    public static final int MESSAGE_CONNECTION_LOST = 8;
    public static final int MESSAGE_UNABLE_CONNECT = 9;

    // Key names received from the BluetoothService Handler
    public static final String DEVICE_NAME = "device_name";
    public static final String DEVICE_ADDRESS = "device_address";
    public static final String TOAST = "toast";

    public static String ErrorMessage = "No_Error_Message";

    private static List<BluetoothServiceStateObserver> observers = new ArrayList<BluetoothServiceStateObserver>();

    /**
     * Constructor. Prepares a new BTPrinter session.
     *
     * @param context The UI Activity Context
     */
    public BluetoothService(Context context) {
        mAdapter = BluetoothAdapter.getDefaultAdapter();
        mState = STATE_NONE;

    }

    public void addStateObserver(BluetoothServiceStateObserver observer) {
        observers.add(observer);
    }

    public void removeStateObserver(BluetoothServiceStateObserver observer) {
        observers.remove(observer);
    }

    /**
     * Set the current state of the connection
     *
     * @param state An integer defining the current connection state
     */
    private synchronized void setState(int state, Map<String, Object> bundle) {
        if (DEBUG) Log.d(TAG, "setState() " + getStateName(mState) + " -> " + getStateName(state));
        mState = state;
        infoObervers(state, bundle);
    }
    private String getStateName(int state){
        String name="UNKNOW:" + state;
        if(STATE_NONE == state){
            name="STATE_NONE";
        }else if(STATE_CONNECTED == state){
            name="STATE_CONNECTED";
        }else if(STATE_CONNECTING ==  state){
            name="STATE_CONNECTING";
        }
        return name;
    }

    private synchronized void infoObervers(int code, Map<String, Object> bundle) {
        for (BluetoothServiceStateObserver ob : observers) {
            ob.onBluetoothServiceStateChanged(code, bundle);
        }
    }

    /**
     * Return the current connection state.
     */
    public synchronized int getState() {
        return mState;
    }


    /**
     * Start the ConnectThread to initiate a connection to a remote device.
     *
     * @param device The BluetoothDevice to connect
     */
    public synchronized void connect(BluetoothDevice device) {
        if (DEBUG) Log.d(TAG, "connect to: " + device);
        BluetoothDevice connectedDevice = null;
        if(mConnectedThread!=null){
            connectedDevice = mConnectedThread.bluetoothDevice();
        }
        if( mState==STATE_CONNECTED && connectedDevice!=null && connectedDevice.getAddress().equals(device.getAddress())){
            // connected already
            Map<String, Object> bundle = new HashMap<String, Object>();
            bundle.put(DEVICE_NAME, device.getName());
            bundle.put(DEVICE_ADDRESS,device.getAddress());
            setState(STATE_CONNECTED, bundle);
        }else {
            // Cancel any thread currently running a connection
            this.stop();
            // Start the thread to manage the connection and perform transmissions
            mConnectedThread = new ConnectedThread(device);
            mConnectedThread.start();
            setState(STATE_CONNECTING, null);
        }
    }

    /**
     * Stop all threads
     */
    public synchronized void stop() {
        if (mConnectedThread != null) {
            mConnectedThread.cancel();
            mConnectedThread = null;
        }
    }

    /**
     * Write to the ConnectedThread in an unsynchronized manner
     *
     * @param out The bytes to write
     * @see ConnectedThread#write(byte[])
     */
    public void write(byte[] out) {
        // Create temporary object
        ConnectedThread r;
        // Synchronize a copy of the ConnectedThread
        synchronized (this) {
            if (mState != STATE_CONNECTED) return;
            r = mConnectedThread;
        }
        r.write(out);
    }

    /**
     * Indicate that the connection attempt failed.
     */
    private void connectionFailed() {
        setState(STATE_NONE, null);
        infoObervers(MESSAGE_UNABLE_CONNECT, null);
    }

    /**
     * Indicate that the connection was lost and notify the UI Activity.
     */
    private void connectionLost() {
        setState(STATE_NONE, null);
        infoObervers(MESSAGE_CONNECTION_LOST, null);
    }

    /**
     * This thread runs during a connection with a remote device.
     * It handles all incoming and outgoing transmissions.
     */
    private class ConnectedThread extends Thread {
        private final BluetoothDevice mmDevice;
        private  BluetoothSocket mmSocket;
        private  InputStream mmInStream;
        private  OutputStream mmOutStream;

        public ConnectedThread(BluetoothDevice device) {
            mmDevice = device;
        }

        @Override
        public void run() {
            Log.i(TAG, "BEGIN mConnectThread");
            setName("ConnectThread");
            Map<String, Object> bundle = new HashMap<String, Object>();

            // Always cancel discovery because it will slow down a connection
            mAdapter.cancelDiscovery();

            BluetoothSocket tmp = null;

            // try to connect with socket inner method firstly.
            for(int i=1;i<=3;i++) {
                try {
                    tmp = (BluetoothSocket) mmDevice.getClass().getMethod("createRfcommSocket", int.class).invoke(mmDevice, i);
                } catch (Exception e) {
                }
                if(tmp!=null){
                    mmSocket = tmp;
                    break;
                }
            }

            // try with given uuid
            if(mmSocket == null) {
                try {
                    tmp = mmDevice.createRfcommSocketToServiceRecord(MY_UUID);
                } catch (IOException e) {
                    e.printStackTrace();
                    Log.e(TAG, "create() failed", e);
                }
                if (tmp == null) {
                    Log.e(TAG, "create() failed: Socket NULL.");
                    connectionFailed();
                    return;
                }
            }
            mmSocket = tmp;

            // Make a connection to the BluetoothSocket
            try {
                // This is a blocking call and will only return on a
                // successful connection or an exception
                mmSocket.connect();
            } catch (Exception e) {
                e.printStackTrace();
                connectionFailed();
                // Close the socket
                try {
                    mmSocket.close();
                } catch (Exception e2) {
                    Log.e(TAG, "unable to close() socket during connection failure", e2);
                }
                return;
            }


            Log.d(TAG, "create ConnectedThread");
            InputStream tmpIn = null;
            OutputStream tmpOut = null;

            // Get the BluetoothSocket input and output streams
            try {
                tmpIn = mmSocket.getInputStream();
                tmpOut = mmSocket.getOutputStream();
            } catch (IOException e) {
                Log.e(TAG, "temp sockets not created", e);
            }

            mmInStream = tmpIn;
            mmOutStream = tmpOut;

            bundle.put(DEVICE_NAME, mmDevice.getName());
            bundle.put(DEVICE_ADDRESS,mmDevice.getAddress());
            setState(STATE_CONNECTED, bundle);

            Log.i(TAG, "Connected");
            int bytes;

            // Keep listening to the InputStream while connected
            while (true) {
                try {
                    byte[] buffer = new byte[256];
                    // Read from the InputStream
                    bytes = mmInStream.read(buffer);
                    if (bytes > 0) {
                        // Send the obtained bytes to the UI Activity
                        bundle = new HashMap<String, Object>();
                        bundle.put("bytes", bytes);
                        infoObervers(MESSAGE_READ, bundle);
                    } else {
                        Log.e(TAG, "disconnected");
                        connectionLost();
                        break;
                    }
                } catch (IOException e) {
                    Log.e(TAG, "disconnected", e);
                    connectionLost();
                    break;
                }
            }
            Log.i(TAG, "ConnectedThread End");
        }

        /**
         * Write to the connected OutStream.
         *
         * @param buffer The bytes to write
         */
        public void write(byte[] buffer) {
            try {
                mmOutStream.write(buffer);
                mmOutStream.flush();//清空缓存
               /* if (buffer.length > 3000) //
                {
                  byte[] readata = new byte[1];
                  SPPReadTimeout(readata, 1, 5000);
                }*/
                Log.i("BTPWRITE", new String(buffer, "GBK"));
                Map<String, Object> bundle = new HashMap<String, Object>();
                bundle.put("bytes", buffer);
                infoObervers(MESSAGE_WRITE, bundle);
            } catch (IOException e) {
                Log.e(TAG, "Exception during write", e);
            }
        }

        public BluetoothDevice bluetoothDevice(){
            if(mmSocket!=null && mmSocket.isConnected()){
                return mmSocket.getRemoteDevice();
            }else{
                return null;
            }
        }

        public void cancel() {
            try {
                mmSocket.close();
                connectionLost();
            } catch (IOException e) {
                Log.e(TAG, "close() of connect socket failed", e);
            }
        }
    }
}
