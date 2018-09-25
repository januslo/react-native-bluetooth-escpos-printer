/**
 * Created by januslo on 2018/9/20.
 */
/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 * @flow
 */

import React, {Component} from 'react';
import {ActivityIndicator,Platform, StyleSheet, Text, View,Image,Button,NativeModules,ListView,DeviceEventEmitter,Switch} from 'react-native';
import {BluetoothManager,BluetoothEscposPrinter,BluetoothTscPrinter} from 'react-native-bluetooth-escpos-printer';


//获取屏幕信息
var Dimensions = require('Dimensions');
var width = Dimensions.get('window').width;
var height = Dimensions.get('window').height;


const ds = new ListView.DataSource({rowHasChanged: (r1, r2) => r1 !== r2});
const base64Image = "iVBORw0KGgoAAAANSUhEUgAAADAAAAAwCAMAAABg3Am1AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAA8FBMVEUAAABCQkJDQ0NFRUU/Pz9BQUFAQEBERERDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0NDQ0MAAAA0ZZMIAAAATnRSTlMAAAAAAAAAABWFz8JdBQFHt9OYIxSi/PBsBFHjvCSk/vJt5b7mo26h75ziIZkD1csRXvpziwvx+QadveRSSA3XF6r31DMPOSLWzMTZFgd4wftfAAAAAWJLR0QAiAUdSAAAAAlwSFlzAAALEgAACxIB0t1+/AAAAaBJREFUSMe11dlSwjAUgOE2WmUTQRBtBQVBREREQEVUFkHcz/s/jklbQ7YOhwtz2fzftJ1OTi0rWDaJxRPJ1A6xxEXSu5nsXo7Ylrpskt8vABwcuqIgG94RABRLmtgk+eMTugXliiAI8U7ZRaiqwvnrJUH7WnBRFfR5zsKeinoohN4XRHyeZc8F2RJ6SSh9KJReeCpH7QOh9st76L3/5lrPRf5c6wEaF039IlQvmYgXAL1aVxQk8D20YxQk1wDXHQpuGui+22Pv4FbK2L5/639Rt44TYY8WvEcKoUcJqUcIpV8ptN4Xd5H9vd5TMXiIBMOOoXe8x0igzJKgf6pB9JJmCaIXJkPYb6/oFYHoJYHqxXllo/qlcDxcz8VzE9lTkWInLoPuAZIjCrJrgPGEgtYaYDqgIFc07LwMTbNkNmfvQEpVbafbfzXMkvbCn622Lth50adP2BuEf740MVvwP4oi+LyShNArQphXgpB69v/jQppXXCi9IJR5FQqt50KbV74w9Ey8td4/etq8Sn1+TeeGngn3u5PW7myPJj/G/v/WL4DMswebZ4AxAAAAJXRFWHRkYXRlOmNyZWF0ZQAyMDE1LTA2LTI1VDA4OjQ0OjQ2KzA4OjAww1b9dwAAACV0RVh0ZGF0ZTptb2RpZnkAMjAxNS0wNi0yNVQwODo0NDo0NiswODowMLILRcsAAAAASUVORK5CYII=";


export default class App extends Component {
    _listeners = [];

    constructor() {
        super();
        this.state = {
            devices: null,
            pairedDs: ds.cloneWithRows([]),
            foundDs: ds.cloneWithRows([]),
            bleOpend: false,
            loading:true,
            boundAddress:'',
            debugMsg:''
        }
    }

    componentDidMount() {//alert(BluetoothManager)
    	BluetoothManager.isBluetoothEnabled((enabled)=> {
            this.setState({
                bleOpend: enabled,
                loading:false
            })
        });

        this._listeners.push(DeviceEventEmitter.addListener(
            BluetoothManager.EVENT_DEVICE_ALREADY_PAIRED, (rsp)=>{this._deviceAlreadPaired(rsp)}));
        this._listeners.push(DeviceEventEmitter.addListener(
            BluetoothManager.EVENT_DEVICE_FOUND, (rsp)=>{this._deviceFoundEvent(rsp)}));
    }

    componentWillUnmount() {
        for (let ls in this._listeners) {
            this._listeners[ls].remove();
            this._listeners[ls].remove();
        }
    }

    _deviceAlreadPaired(rsp) {
    	var ds = null;
    	try{
    		ds = JSON.parse(rsp.devices);
    	}catch(e){}
    	this.paired = ds || []
        this.setState({
            pairedDs: this.state.pairedDs.cloneWithRows(this.paired)
        });
    }

    _deviceFoundEvent(rsp) {
    	var r= null;
    	try{
    		r = JSON.parse(rsp.device);
    	}catch(e){
    		//ignore
    	}
    	if(r){
    		if(!this.found) this.found = [];
	        this.found.push(r);
	        this.setState({
	            foundDs: this.state.foundDs.cloneWithRows(this.found)
	        });
    	}
    }

    render() {
        return (
            <View style={styles.container}>
            <Text>{this.state.debugMsg}</Text>
                <Text>Blutooth Opended:</Text><Switch value={this.state.bleOpend} onValueChange={(v)=>{
                	this.setState({
                		loading:true
                	})
                if(!v){
                    BluetoothManager.disableBluetooth(()=>{
                    	 this.setState({
                        	bleOpend:false,
                        	loading:false,
                        	foundDs:this.state.foundDs.cloneWithRows([]),
                        	pairedDs:this.state.pairedDs.cloneWithRows([])
                        });
                    	 this.paired = [];
                    	 this.found = [];
                    });
                    
                }else{
                    BluetoothManager.enableBluetooth().then((r)=>{
                        this.setState({
                             bleOpend:true,
                             loading:false
                        })
                        },(err)=>{
                        	this.setState({
                        		loading:false
                        	})
                        	alert(err)
                        });
                }
                }} />
                <Text>Connected:{!this.state.name ? 'No Devices' : this.state.name}</Text>
                {this.state.bleOpend ? (<Button disabled={this.state.loading} onPress={()=>{this._scan()}} title="scan"/>) :
                    <Text>Open BLE first</Text>}
                    {this.state.bleOpend && this.state.boundAddress.length>0?(<Button disabled={this.state.loading} title="Self Test" onPress={()=>{this._selfTest()}} />):null}
                 {this.state.bleOpend && this.state.boundAddress.length>0?(<Button disabled={this.state.loading} title="Print Text" onPress={()=>{
                 	//this._printText('show me the money')
                 	 BluetoothTscPrinter.printLabel(
 {
                width: 40,
                height: 30,
                gap: 20,
                direction: BluetoothTscPrinter.DIRECTION.FORWARD,
                reference: [0, 0],
                tear: BluetoothTscPrinter.TEAR.ON,
                sound: 0,
                address: this.state.boundAddress,
                text: [{
                    text: 'I am a testing txt',
                    x: 20,
                    y: 0,
                    fonttype: BluetoothTscPrinter.FONTTYPE.SIMPLIFIED_CHINESE,
                    rotation: BluetoothTscPrinter.ROTATION.ROTATION_0,
                    xscal:BluetoothTscPrinter.FONTMUL.MUL_1,
                    yscal: BluetoothTscPrinter.FONTMUL.MUL_1
                },{
                    text: '你在说什么呢?',
                    x: 20,
                    y: 50,
                    fonttype: BluetoothTscPrinter.FONTTYPE.SIMPLIFIED_CHINESE,
                    rotation: BluetoothTscPrinter.ROTATION.ROTATION_0,
                    xscal:BluetoothTscPrinter.FONTMUL.MUL_1,
                    yscal: BluetoothTscPrinter.FONTMUL.MUL_1
                }],
                qrcode: [{x: 20, y: 96, level: BluetoothTscPrinter.EEC.LEVEL_L, width: 3, rotation: BluetoothTscPrinter.ROTATION.ROTATION_0, code: 'show me the money'}],
                barcode: [{x: 120, y:96, type: BluetoothTscPrinter.BARCODETYPE.CODE128, height: 40, readabel: 1, rotation: BluetoothTscPrinter.ROTATION.ROTATION_0, code: '1234567890'}],
              image: [{x: 160, y: 160, mode: BluetoothTscPrinter.BITMAP_MODE.OVERWRITE,width: 60,image: base64Image}]
            }
                 	 	);
                 	 alert(1);
                 }
                 } />):null}

                <Text>Found:</Text>
                    {this.state.loading?(<ActivityIndicator animating={true}  />):null}
                <ListView style={{width:width,height:height/3}} enableEmptySections={true} dataSource={this.state.foundDs}
                          renderRow={(rowData) => <Text style={{width:'100%',marginBottom:20}} onPress={()=>{
                           this.setState({
    							loading:true
    						});
                            BluetoothManager.connect(rowData.address)
                            .then((s)=>{
                            	this.setState({
    								loading:false,
    								boundAddress:rowD.address
    							})
                            },(e)=>{
                            	this.setState({
    							loading:false
    								})
                           		 alert(e);
                            })

                          }}>{rowData.name||rowData.address}</Text>}/>
                <Text>Paired:</Text>
                    {this.state.loading?(<ActivityIndicator animating={true}  />):null}
                <ListView  style={{width:width,height:height/3}} enableEmptySections={true} dataSource={this.state.pairedDs}
                          renderRow={(rowData) => <Text style={{width:'100%',marginBottom:20}} onPress={()=>{
                          	this.setState({
    							loading:true
    						});
                            BluetoothManager.connect(rowData.address)
                            .then((s)=>{
                            	this.setState({
    								loading:false,
    								boundAddress:rowData.address,
    								name:rowData.name || rowData.address
    							})
                            alert(s);
                            },(e)=>{
                            	this.setState({
    							loading:false
    								})
                           		 alert(e);
                            })

                          }}>{rowData.name||rowData.address}</Text>}/>
            </View>
        );
    }
    _selfTest(){
    	this.setState({
    		loading:true
    	},()=>{
    		BluetoothEscposPrinter.selfTest();

    			this.setState({
    				loading:false
    			})
    	})
    }

    _scan() {
    	this.setState({
    		loading:true
    	})
        BluetoothManager.scanDevices()
            .then((s)=> {
                var ss = JSON.parse(s);
                this.setState({
                    pairedDs: this.state.pairedDs.cloneWithRows(ss.paired || []),
                    foundDs: this.state.foundDs.cloneWithRows(ss.found || []),
                    loading:false
                },()=>{
                	this.paired = ss.paired||[];
                	this.found = ss.found ||[];
                });
            }, (er)=> {
            	this.setState({
            		loading:false
            	})
                alert('error' + JSON.stringify(er));
            });
    }
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: '#F5FCFF',
    },
    welcome: {
        fontSize: 20,
        textAlign: 'center',
        margin: 10,
    },
    instructions: {
        textAlign: 'center',
        color: '#333333',
        marginBottom: 5,
    },
});
