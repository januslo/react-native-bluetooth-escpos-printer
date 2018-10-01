//
//  RNBluethManager.m
//  RNBluetoothEscposPrinter
//
//  Created by januslo on 2018/9/28.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RNBluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
@implementation RNBluetoothManager

NSString *EVENT_DEVICE_ALREADY_PAIRED = @"EVENT_DEVICE_ALREADY_PAIRED";
NSString *EVENT_DEVICE_DISCOVER_DONE = @"EVENT_DEVICE_DISCOVER_DONE";
NSString *EVENT_DEVICE_FOUND = @"EVENT_DEVICE_FOUND";
NSString *EVENT_CONNECTION_LOST = @"EVENT_CONNECTION_LOST";
NSString *EVENT_UNABLE_CONNECT=@"EVENT_UNABLE_CONNECT";
NSString *EVENT_CONNECTED=@"EVENT_CONNECTED";
bool hasListeners;
static CBPeripheral *connected;

+(CBPeripheral *)connectedDevice{
    return connected;
}

// Will be called when this module's first listener is added.
-(void)startObserving {
    hasListeners = YES;
    // Set up any upstream listeners or background tasks as necessary
}

// Will be called when this module's last listener is removed, or on dealloc.
-(void)stopObserving {
    hasListeners = NO;
    // Remove upstream listeners, stop unnecessary background tasks
}

/**
 * Exports the constants to javascritp.
 **/
- (NSDictionary *)constantsToExport
{
    
    /*
     EVENT_DEVICE_ALREADY_PAIRED    Emits the devices array already paired
     EVENT_DEVICE_DISCOVER_DONE    Emits when the scan done
     EVENT_DEVICE_FOUND    Emits when device found during scan
     EVENT_CONNECTION_LOST    Emits when device connection lost
     EVENT_UNABLE_CONNECT    Emits when error occurs while trying to connect device
     EVENT_CONNECTED    Emits when device connected
     */

    return @{ EVENT_DEVICE_ALREADY_PAIRED: EVENT_DEVICE_ALREADY_PAIRED,
              EVENT_DEVICE_DISCOVER_DONE:EVENT_DEVICE_DISCOVER_DONE,
              EVENT_DEVICE_FOUND:EVENT_DEVICE_FOUND,
              EVENT_CONNECTION_LOST:EVENT_CONNECTION_LOST,
              EVENT_UNABLE_CONNECT:EVENT_UNABLE_CONNECT,
              EVENT_CONNECTED:EVENT_CONNECTED
              };
}
- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}


/**
 * Defines the event would be emited.
 **/
- (NSArray<NSString *> *)supportedEvents
{
    return @[EVENT_DEVICE_DISCOVER_DONE,EVENT_DEVICE_FOUND,
             EVENT_UNABLE_CONNECT,EVENT_CONNECTION_LOST,
             EVENT_CONNECTED,EVENT_DEVICE_ALREADY_PAIRED];
}


RCT_EXPORT_MODULE(BluetoothManager);


//isBluetoothEnabled
RCT_EXPORT_METHOD(isBluetoothEnabled:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    CBManagerState state = [self.centralManager  state];
    resolve(state == CBManagerStatePoweredOn?@"true":@"false");//canot pass boolean or int value to resolve directly.
}

//enableBluetooth
RCT_EXPORT_METHOD(enableBluetooth:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}
//disableBluetooth
RCT_EXPORT_METHOD(disableBluetooth:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve(nil);
}
//scanDevices
RCT_EXPORT_METHOD(scanDevices:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    @try{
        if(!self.centralManager || self.centralManager.state!=CBManagerStatePoweredOn){
            reject(@"BLUETOOTCH_INVALID_STATE",@"BLUETOOTCH_INVALID_STATE",nil);
        }
        if(self.centralManager.isScanning){
            [self.centralManager stopScan];
        }
        self.scanResolveBlock = resolve;
        self.scanRejectBlock = reject;
        [self.centralManager scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObjectsAndKeys:@NO, CBCentralManagerScanOptionAllowDuplicatesKey, nil]];
        NSLog(@"Scanning started");
    }
    @catch(NSException *exception){
        NSLog(@"ERROR IN STARTING SCANE %@",exception);
        reject([exception name],[exception name],nil);
    }
}

//stop scan
RCT_EXPORT_METHOD(stopScan:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    if(self.centralManager.isScanning){
        [self.centralManager stopScan];
        NSMutableArray *devices = [[NSMutableArray alloc] init];
        for(NSString *key in self.foundDevices){
            [devices addObject:@{@"address":key,@"name":[self.foundDevices objectForKey:key].name}];
        }
        NSError *error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:devices options:NSJSONWritingPrettyPrinted error:&error];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        [self sendEventWithName:EVENT_DEVICE_DISCOVER_DONE body:@{@"found":jsonStr,@"paired":@"[]"}];
        if(self.scanResolveBlock){
            RCTPromiseResolveBlock rsBlock = self.scanResolveBlock;
            rsBlock(@{@"found":jsonStr,@"paired":@"[]"});
            self.scanResolveBlock = nil;
        }
    }
    self.scanRejectBlock = nil;
    self.scanResolveBlock = nil;
    resolve(nil);
}

//connect(address)
RCT_EXPORT_METHOD(connect:(NSString *)address
                  findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"Trying to connect....%@",address);
    if(self.centralManager.isScanning){
        [self.centralManager stopScan];
    }
    CBPeripheral *peripheral = [self.foundDevices objectForKey:address];
    self.connectResolveBlock = resolve;
    self.connectRejectBlock = reject;
    if(peripheral){
          _waitingConnect = address;
        [self.centralManager connectPeripheral:peripheral options:nil];
    }else{
          //starts the scan.
        _waitingConnect = address;
       [self.centralManager scanForPeripheralsWithServices:nil options:[NSDictionary dictionaryWithObjectsAndKeys:@NO, CBCentralManagerScanOptionAllowDuplicatesKey, nil]];
    }
}
//unpaire(address)

- (CBCentralManager *) centralManager
{
    @synchronized(_centralManager)
    {
        if (!_centralManager)
        {
            if (![CBCentralManager instancesRespondToSelector:@selector(initWithDelegate:queue:options:)])
            {
                //for ios version lowser than 7.0
                self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
            }else
            {
                self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options: nil];
            }
        }
    }
    return _centralManager;
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%ld",(long)central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"did discover peripheral: %@",peripheral);
    NSDictionary *idAndName =@{@"address":peripheral.identifier.UUIDString,@"name":peripheral.name?peripheral.name:peripheral.identifier.UUIDString};
    NSDictionary *peripheralStored = @{peripheral.identifier.UUIDString:peripheral};
    if(!self.foundDevices){
        self.foundDevices = [[NSMutableDictionary alloc] init];
    }
    [self.foundDevices addEntriesFromDictionary:peripheralStored];
    if(hasListeners){
        [self sendEventWithName:EVENT_DEVICE_FOUND body:@{@"device":idAndName}];
    }
    if(_waitingConnect && _waitingConnect == peripheral.identifier.UUIDString){
        [self.centralManager connectPeripheral:peripheral options:nil];
        [self.centralManager stopScan];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did connected: %@",peripheral);
    NSString *pId = peripheral.identifier.UUIDString;
    if(_waitingConnect && [_waitingConnect isEqualToString: pId] && self.connectResolveBlock){
        NSLog(@"going to discover services.");
        peripheral.delegate=self;
        [peripheral discoverServices:nil];
      
    }
       NSLog(@"going to emit EVEnT_CONNECTED.");
    if(hasListeners){
        [self sendEventWithName:EVENT_CONNECTED body:@{@"device":@{@"name":peripheral.name,@"address":peripheral.identifier.UUIDString}}];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if(self.connectRejectBlock){
        RCTPromiseRejectBlock rjBlock = self.connectRejectBlock;
         rjBlock(@"",@"",error);
        self.connectRejectBlock = nil;
        self.connectResolveBlock = nil;
    }
    connected = nil;
    if(hasListeners){
        [self sendEventWithName:EVENT_UNABLE_CONNECT body:@{@"name":peripheral.name,@"address":peripheral.identifier.UUIDString}];
    }
    }

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if(self.connectRejectBlock){
        RCTPromiseRejectBlock rjBlock = self.connectRejectBlock;
        rjBlock(@"",@"",error);
        self.connectRejectBlock = nil;
        self.connectResolveBlock = nil;
    }
    connected = nil;
    if(hasListeners){
        [self sendEventWithName:EVENT_UNABLE_CONNECT body:@{@"name":peripheral.name,@"address":peripheral.identifier.UUIDString}];
    }
    }

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral    The peripheral providing this information.
 *    @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion            This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *                        <i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(nullable NSError *)error{
    if (error){
        NSLog(@"扫描外设服务出错：%@-> %@", peripheral.name, [error localizedDescription]);
        return;
    }
    NSLog(@"扫描到外设服务：%@ -> %@",peripheral.name,peripheral.services);
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
         NSLog(@"服务id：%@",service.UUID.UUIDString);
        //添加到数组
        //[self.serviceArray addObject:service];
    }
    NSLog(@"开始扫描外设服务的特征 %@...",peripheral.name);
    
    if(error && self.connectRejectBlock){
        RCTPromiseRejectBlock rjBlock = self.connectRejectBlock;
         rjBlock(@"",@"",error);
        self.connectRejectBlock = nil;
        self.connectResolveBlock = nil;
        connected = nil;
    }else
    if(_waitingConnect && _waitingConnect == peripheral.identifier.UUIDString){
        RCTPromiseResolveBlock rsBlock = self.connectResolveBlock;
        rsBlock(peripheral.identifier.UUIDString);
        self.connectRejectBlock = nil;
        self.connectResolveBlock = nil;
        connected = peripheral;
//        for(CBService s:peripheral.services){
//
//        }
    }
}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral    The peripheral providing this information.
 *  @param service        The <code>CBService</code> object containing the characteristic(s).
 *    @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion            This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *                        they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error{
    if(error){
        NSLog(@"Discrover charactoreristics error:%@",error);
        return;
    }
    
    
//    本帖最后由 xiaozaozao 于 2017-1-20 16:07 编辑
//
//
//    好帖，感谢楼主的经验贴，感谢楼主的指教！
//    ServiceUUID：49535343-fe7d-4ae5-8fa9-9fafd205e455；
//    写的是
//characteristicUUID:49535343-8841-43f4-a8d4-ecbe34729bb3；
//    读的是
//characteristicUUID:49535343-1e4d-4bd9-ba61-23c647249616;
//
//    如果要写，翻译成base64位；
//
//    调用监听改变，需要去使能设备的Notify，var param={
//    serviceUUID: '000018f0-0000-1000-8000-00805f9b34fb',//service的UUID  这个值需要获取查看设备，我暂认为他是通用的
//    characteristicUUID:'00002af0-0000-1000-8000-00805f9b34fb',//characteristic的UUID  这个值也需要获取查看，我认为他是通用的
//    enable:true //true 或false,开启或关闭监听
//    };
//    param = JSON.stringify(param);
//    uexBluetoothLE.setCharacteristicNotification(param);
    
//    2018-10-01 12:12:49.760434+0800 bluetoothEscposPrinterExamples[7977:4411124] 扫描到外设服务：BlueTooth Printer -> (
//                                                                                                               "<CBService: 0x1c0a66440, isPrimary = YES, UUID = 49535343-FE7D-4AE5-8FA9-9FAFD205E455>",
//                                                                                                               "<CBService: 0x1c0660380, isPrimary = YES, UUID = 18F0>",
//                                                                                                               "<CBService: 0x1c0a66500, isPrimary = YES, UUID = E7810A71-73AE-499D-8C15-FAA9AEF0C3F2>"
//
    
//    2018-10-01 12:12:49.760638+0800 bluetoothEscposPrinterExamples[7977:4411124] 服务id：49535343-FE7D-4AE5-8FA9-9FAFD205E455
//    2018-10-01 12:12:49.760763+0800 bluetoothEscposPrinterExamples[7977:4411124] 服务id：18F0
//    2018-10-01 12:12:49.760870+0800 bluetoothEscposPrinterExamples[7977:4411124] 服务id：E7810A71-73AE-499D-8C15-FAA9AEF0C3F2
//    2018-10-01 12:12:49.760891+0800 bluetoothEscposPrinterExamples[7977:4411124] 开始扫描外设服务的特征 BlueTooth Printer...
//    2018-10-01 12:12:49.761897+0800 bluetoothEscposPrinterExamples[7977:4411124] Characterstic found: <CBCharacteristic: 0x1c40bfda0, UUID = 49535343-1E4D-4BD9-BA61-23C647249616, properties = 0x10, value = <5f47505f 4c383031 3630>, notifying = NO>
//    2018-10-01 12:12:49.761934+0800 bluetoothEscposPrinterExamples[7977:4411124] NOtify
//    2018-10-01 12:12:49.761975+0800 bluetoothEscposPrinterExamples[7977:4411124] Characterstic found: <CBCharacteristic: 0x1c40bfc80, UUID = 49535343-8841-43F4-A8D4-ECBE34729BB3, properties = 0xC, value = (null), notifying = NO>
//    2018-10-01 12:12:49.762022+0800 bluetoothEscposPrinterExamples[7977:4411124] UNKNOWN
//    2018-10-01 12:12:49.762225+0800 bluetoothEscposPrinterExamples[7977:4411124] Characterstic found: <CBCharacteristic: 0x1c40bfb60, UUID = 2AF0, properties = 0x30, value = (null), notifying = NO>
//    2018-10-01 12:12:49.762241+0800 bluetoothEscposPrinterExamples[7977:4411124] UNKNOWN
//    2018-10-01 12:12:49.762281+0800 bluetoothEscposPrinterExamples[7977:4411124] Characterstic found: <CBCharacteristic: 0x1c40bfe00, UUID = 2AF1, properties = 0xC, value = (null), notifying = NO>
//    2018-10-01 12:12:49.762295+0800 bluetoothEscposPrinterExamples[7977:4411124] UNKNOWN
//    2018-10-01 12:12:49.762422+0800 bluetoothEscposPrinterExamples[7977:4411124] Characterstic found: <CBCharacteristic: 0x1c40bfd40, UUID = BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F, properties = 0x3E, value = (null), notifying = NO>
//    2018-10-01 12:12:49.762438+0800 bluetoothEscposPrinterExamples[7977:4411124] UNKNOWN)
    
    for(CBCharacteristic *cc in service.characteristics){
        NSLog(@"Characterstic found: %@",cc);
        CBCharacteristicProperties pro = cc.properties;
        switch (pro) {
            case CBCharacteristicPropertyRead:
                NSLog(@"CBCharacteristicPropertyRead");
                break;
            case CBCharacteristicPropertyBroadcast:
                NSLog(@"Broadcaset");
                break;
            case CBCharacteristicPropertyWrite:
                NSLog(@"Write");
                break;
            case CBCharacteristicPropertyNotify:
                NSLog(@"NOtify");
                break;
            case CBCharacteristicPropertyIndicate:
                NSLog(@"INDICATE");
                break;
            case CBCharacteristicPropertyExtendedProperties:
                NSLog(@"extended properties");
                break;
            case CBCharacteristicPropertyWriteWithoutResponse:
                NSLog(@"write without resppnse");
                break;
            case CBCharacteristicPropertyNotifyEncryptionRequired:
                NSLog(@"NotifyEncryptionRequired");
                break;
            case CBCharacteristicPropertyAuthenticatedSignedWrites:
                NSLog(@"AuthticatedSignedWrites");
                break;
            case CBCharacteristicPropertyIndicateEncryptionRequired:
                NSLog(@"IndicateEncryptionRquried");
                break;
                
            default:
                NSLog(@"UNKNOWN");
                break;
        }
    }
    
}


 
@end
