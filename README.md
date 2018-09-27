# react-native-bluetooch-escpos-printer

React-Native plugin for the bluetooth ESC/POS & TSC printers.

Any questions or bug please raise a issue.

##Still under developement

#May support Android /IOS

[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/januslo/react-native-bluetooth-escpos-printer/master/LICENSE) [![npm version](https://badge.fury.io/js/react-native-bluetooth-escpos-printer.svg)](https://www.npmjs.com/package/react-native-bluetooth-escpos-printer)

## Installation
### Step 1 ###
Install via NPM [Check In NPM](https://www.npmjs.com/package/react-native-bluetooth-escpos-printer)
```bash
npm install react-native-bluetooth-escpos-printer --save
```

Or install via github
```bash
npm install https://github.com/januslo/react-native-bluetooth-escpos-printer.git --save
```

### Step2 ###
Link the plugin to your RN project
```bash
react-native link react-native-bluetooth-escpos-printer
```

Or you may need to link manually.
//TODO: manually link guilds.

### Step3 ###
Refers to your JS files
```javascript
    import {BluetoothManager,BluetoothEscposPrinter,BluetoothTscPrinter} from 'react-native-bluetooth-escpos-printer';
```

## Usage and APIs ##

### BluetoothManager ###
BluetoothManager is the module that for Bluetooth service management, supports Bluetooth status check, enable/disable Bluetooth service,scan devices,connect/unpaire devices.

* isBluetoothEnabled 
async function, check whether Bluetooth service is enabled.
//TODO: consider to return the the devices information already bound and paired here..

```javascript
     BluetoothManager.isBluetoothEnabled().then((enabled)=> {
                alert(enabled) // enabled ==> true /false 
            }, (err)=> {
                alert(err)
            });
```

* enableBluetooth
async function, enable the bluetooth service, returns the devices information already bound and paired.

```javascript
BluetoothManager.enableBluetooth().then((r)=>{
                var paired = [];
                if(r && r.length>0){
                    for(var i=0;i<r.length;i++){
                        try{
                            paired.push(JSON.parse(r[i])); // NEED TO PARSE THE DEVICE INFORMATION
                        }catch(e){
                            //ignore
                        }
                    }
                }
                console.log(JSON.stringify(paired))
            },(err)=>{
               alert(err)
           });
```

* disableBluetooth
async function ,disable the bluetooth service.

```javascript
BluetoothManager.disableBluetooth().then(()=>{
            // do something.
          },(err)=>{alert(err)});
```

* scanDevices
async function , scans the bluetooth devices, returns devices found and pared after scan finish. Event [BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED] would be emitted with devices bound; event [BluetoothManager.EVENT_DEVICE_FOUND] would be emitted (many time) as long as new devices found.

samples with events:
```javascript
 DeviceEventEmitter.addListener(
            BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED, (rsp)=> {
                this._deviceAlreadPaired(rsp) // rsp.devices would returns the paired devices array in JSON string.
            });
        DeviceEventEmitter.addListener(
            BluetoothManager.EVENT_DEVICE_FOUND, (rsp)=> {
                this._deviceFoundEvent(rsp) // rsp.devices would returns the found device object in JSON string
            });
```

samples with scanDevices function
```javascript
BluetoothManager.scanDevices()
            .then((s)=> {
                var ss = JSON.parse(s);//JSON string
                this.setState({
                    pairedDs: this.state.pairedDs.cloneWithRows(ss.paired || []),
                    foundDs: this.state.foundDs.cloneWithRows(ss.found || []),
                    loading: false
                }, ()=> {
                    this.paired = ss.paired || [];
                    this.found = ss.found || [];
                });
            }, (er)=> {
                this.setState({
                    loading: false
                })
                alert('error' + JSON.stringify(er));
            });
```

* connect
async function, connect the specified devices, if not bound, bound dailog promps.

```javascript

    BluetoothManager.connect(rowData.address) // the device address scanned.
     .then((s)=>{
       this.setState({
        loading:false,
        boundAddress:rowData.address
    })
    },(e)=>{
       this.setState({
         loading:false
     })
       alert(e);
    })
    
```

* unpaire
async function, disconnect and unpaire the specified devices

```javascript
     BluetoothManager.connect(rowData.address)
     .then((s)=>{
        //success here
     },
     (err)=>{
        //error here
     })
```

* Events of BluetoothManager module

| Name/KEY | DESCRIPTION |
|---|---|
| EVENT_DEVICE_ALREADY_PAIRED | Emits the devices array already paired |
| EVENT_DEVICE_DISCOVER_DONE | Emits when the scan done |
| EVENT_DEVICE_FOUND | Emits when device found during scan |
| EVENT_CONNECTION_LOST | Emits when device connection lost |
| EVENT_UNABLE_CONNECT | Emits when error occurs while trying to connect device |
| EVENT_CONNECTED | Emits when device connected |

### BluetoothTscPrinter ###
The printer for label printing.

* printLabel
async function the perform label print action.

```javascript
BluetoothTscPrinter.printLable(options)
.then(()=>{
    //success
},
(err)=>{
    //error
})
    
```

#### Options of printLabel( ) function: (JSON object) ####
    
##### width #####
    label with , the real size of the label, matured by mm usualy.
##### height #####
    label height, the real size of the label, matured by mm usualy.
##### direction #####
    the printing direction, constants of BluetoothTscPrinter.DIRECTION, values BluetoothTscPrinter.DIRECTION.FORWARD/BluetoothTscPrinter.DIRECTION.BACKWARD (0/1)
##### gap #####
    the gap between 2 labels, matured by mm usualy.
##### reference #####
    the "zero" position of the label, values [x,y], default [0,0]
##### tear #####
    switch of the paper cut, constants of BluetoothTscPrinter.TEAR, values ON/OFF (string 'ON','OFF')
##### sound #####
    switch of the bee sound, values 0/1
##### text #####
    the collection of texts to print, contains following fields as the configuration:
        * text 
            the text string,
        * x 
            the text print start position-x
        * y
            the text print start position-y
        * fonttype
            the font type of the text, constanst of BluetoothTscPrinter.FONTTYPE,refereces as table:
                | CONSTANTS | VALUE   |
                |---|---|
                |FONT_1| "1"|
                |FONT_2| "2"|
                |FONT_3| "3"|
                |FONT_4| "4"|
                |FONT_5| "5"|
                |FONT_6| "6"|
                |FONT_7| "7"|
                |FONT_8|"8"|
                |SIMPLIFIED_CHINESE| "TSS24.BF2"|
                |TRADITIONAL_CHINESE| "TST24.BF2"|
                |KOREAN| "K"|
        * rotation
            the rotation of the text, constants of the BluetoothTscPrinter.ROTATION, referces as table:
                   | CONSTANTS | VALUE   |
                   |---|---|
                   |ROTATION_0| 0|
                   |ROTATION_90| 90|
                   |ROTATION_180| 180|
                   |ROTATION_270| 270|
        * xscal
            the scal in x,
        * yscal 
            the scal in y, xscal/yscal is the constants of the BluetoothTscPrinter.FONTMUL, referces as table:
             | CONSTANTS | VALUE   |
             |---|---|
             |MUL_1| 1|
             |MUL_2| 2|
             |MUL_3| 3|
             |MUL_4| 4|
             |MUL_5| 5|
             |MUL_6| 6|
             |MUL_7| 7|
             |MUL_8| 8|
             |MUL_9| 9|
             |MUL_10: 10|
        
##### qrcode #####
    the collection of qrcodes to print, contains following fields as the configuration:
        * code
            the qrcode content string.
        * x
            the print start position at x
        * y 
            the print start position at y
        * level
            the error correction level, constants of BluetoothTscPrinter.EEC, referces as tables:
            | CONSTANTS | VALUE   |
            |---|---|
            |LEVEL_L|"L"|
            |LEVEL_M| "M"|
            |LEVEL_Q| "Q"|
            |LEVEL_H| "H"|
        * width
            the qrcode size (width X width),since the qrcode are squre normally, so we just config the width.
        
        * rotation
            rationtion. the same as text object.
       
##### barcode #####
//todo
            
