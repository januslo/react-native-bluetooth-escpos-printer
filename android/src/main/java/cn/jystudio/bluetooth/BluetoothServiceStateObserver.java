package cn.jystudio.bluetooth;

import java.util.Map;


/**
 * Created by januslo on 2018/9/22.
 */
public interface BluetoothServiceStateObserver {
    void onBluetoothServiceStateChanged(int state, Map<String,Object> boundle);
}
