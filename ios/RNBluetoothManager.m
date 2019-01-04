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
static NSArray<CBUUID *> *supportServices = nil;
static NSDictionary *writeableCharactiscs = nil;
bool hasListeners;
static CBPeripheral *connected;
static RNBluetoothManager *instance;
static NSObject<WriteDataToBleDelegate> *writeDataDelegate;// delegate of write data resule;
static NSData *toWrite;
static NSTimer *timer;

+(Boolean)isConnected{
    return !(connected==nil);
}

+(void)writeValue:(NSData *) data withDelegate:(NSObject<WriteDataToBleDelegate> *) delegate
{
    @try{
        writeDataDelegate = delegate;
        toWrite = data;
        connected.delegate = instance;
        [connected discoverServices:supportServices];
//    [connected writeValue:data forCharacteristic:[writeableCharactiscs objectForKey:supportServices[0]] type:CBCharacteristicWriteWithoutResponse];
    }
    @catch(NSException *e){
        NSLog(@"error in writing data to %@,issue:%@",connected,e);
        [writeDataDelegate didWriteDataToBle:false];
    }
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

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

/**
 * Defines the event would be emited.
 **/
- (NSArray<NSString *> *)supportedEvents
{
    return @[EVENT_DEVICE_DISCOVER_DONE,
             EVENT_DEVICE_FOUND,
             EVENT_UNABLE_CONNECT,
             EVENT_CONNECTION_LOST,
             EVENT_CONNECTED,
             EVENT_DEVICE_ALREADY_PAIRED];
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
            return;
        }
        if(self.centralManager.isScanning){
            [self.centralManager stopScan];
        }
        self.scanResolveBlock = resolve;
        self.scanRejectBlock = reject;
        if(connected && connected.identifier){
            NSDictionary *idAndName =@{@"address":connected.identifier.UUIDString,@"name":connected.name?connected.name:@""};
            NSDictionary *peripheralStored = @{connected.identifier.UUIDString:connected};
            if(!self.foundDevices){
                self.foundDevices = [[NSMutableDictionary alloc] init];
            }
            [self.foundDevices addEntriesFromDictionary:peripheralStored];
            if(hasListeners){
                [self sendEventWithName:EVENT_DEVICE_FOUND body:@{@"device":idAndName}];
            }
        }
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
        //Callbacks:
        //centralManager:didDiscoverPeripheral:advertisementData:RSSI:
        NSLog(@"Scanning started with services.");
        if(timer && timer.isValid){
            [timer invalidate];
            timer = nil;
        }
        timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(callStop) userInfo:nil repeats:NO];
    
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
    [self callStop];
    resolve(nil);
}

//connect(address)
RCT_EXPORT_METHOD(connect:(NSString *)address
                  findEventsWithResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"Trying to connect....%@",address);
    [self callStop];
    if(connected){
        NSString *connectedAddress =connected.identifier.UUIDString;
        if([address isEqualToString:connectedAddress]){
            resolve(nil);
            return;
        }else{
            [self.centralManager cancelPeripheralConnection:connected];
            //Callbacks:
            //entralManager:didDisconnectPeripheral:error:
        }
    }
    CBPeripheral *peripheral = [self.foundDevices objectForKey:address];
    self.connectResolveBlock = resolve;
    self.connectRejectBlock = reject;
    if(peripheral){
          _waitingConnect = address;
          NSLog(@"Trying to connectPeripheral....%@",address);
        [self.centralManager connectPeripheral:peripheral options:nil];
        // Callbacks:
        //    centralManager:didConnectPeripheral:
        //    centralManager:didFailToConnectPeripheral:error:
    }else{
          //starts the scan.
        _waitingConnect = address;
         NSLog(@"Scan to find ....%@",address);
        [self.centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@NO}];
        //Callbacks:
        //centralManager:didDiscoverPeripheral:advertisementData:RSSI:
    }
}
//unpaire(address)


-(void)callStop{
    if(self.centralManager.isScanning){
        [self.centralManager stopScan];
        NSMutableArray *devices = [[NSMutableArray alloc] init];
        for(NSString *key in self.foundDevices){
            NSLog(@"insert found devies:%@ =>%@",key,[self.foundDevices objectForKey:key]);
            NSString *name = [self.foundDevices objectForKey:key].name;
            if(!name){
                name = @"";
            }
            [devices addObject:@{@"address":key,@"name":name}];
        }
        NSError *error = nil;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:devices options:NSJSONWritingPrettyPrinted error:&error];
        NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if(hasListeners){
            [self sendEventWithName:EVENT_DEVICE_DISCOVER_DONE body:@{@"found":jsonStr,@"paired":@"[]"}];
        }
        if(self.scanResolveBlock){
            RCTPromiseResolveBlock rsBlock = self.scanResolveBlock;
            rsBlock(@{@"found":jsonStr,@"paired":@"[]"});
            self.scanResolveBlock = nil;
        }
    }
    if(timer && timer.isValid){
        [timer invalidate];
        timer = nil;
    }
    self.scanRejectBlock = nil;
    self.scanResolveBlock = nil;
}
- (void) initSupportServices
{
    if(!supportServices){
        CBUUID *issc = [CBUUID UUIDWithString: @"49535343-FE7D-4AE5-8FA9-9FAFD205E455"];
        supportServices = [NSArray arrayWithObject:issc];/*ISSC*/
        writeableCharactiscs = @{issc:@"49535343-8841-43F4-A8D4-ECBE34729BB3"};
    }
}

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
        if(!instance){
            instance = self;
        }
    }
    [self initSupportServices];
    return _centralManager;
}

/**
 * CBCentralManagerDelegate
 **/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    NSLog(@"%ld",(long)central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"did discover peripheral: %@",peripheral);
    NSDictionary *idAndName =@{@"address":peripheral.identifier.UUIDString,@"name":peripheral.name?peripheral.name:@""};
    NSDictionary *peripheralStored = @{peripheral.identifier.UUIDString:peripheral};
    if(!self.foundDevices){
        self.foundDevices = [[NSMutableDictionary alloc] init];
    }
    [self.foundDevices addEntriesFromDictionary:peripheralStored];
    if(hasListeners){
        [self sendEventWithName:EVENT_DEVICE_FOUND body:@{@"device":idAndName}];
    }
    if(_waitingConnect && [_waitingConnect isEqualToString: peripheral.identifier.UUIDString]){
        [self.centralManager connectPeripheral:peripheral options:nil];
        [self callStop];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"did connected: %@",peripheral);
    connected = peripheral;
    NSString *pId = peripheral.identifier.UUIDString;
    if(_waitingConnect && [_waitingConnect isEqualToString: pId] && self.connectResolveBlock){
        NSLog(@"Predefined the support services, stop to looking up services.");
//        peripheral.delegate=self;
//        [peripheral discoverServices:nil];
        self.connectResolveBlock(nil);
        _waitingConnect = nil;
        self.connectRejectBlock = nil;
        self.connectResolveBlock = nil;
    }
       NSLog(@"going to emit EVENT_CONNECTED.");
    if(hasListeners){
        [self sendEventWithName:EVENT_CONNECTED body:@{@"device":@{@"name":peripheral.name?peripheral.name:@"",@"address":peripheral.identifier.UUIDString}}];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if(!connected && _waitingConnect && [_waitingConnect isEqualToString:peripheral.identifier.UUIDString]){
        if(self.connectRejectBlock){
            RCTPromiseRejectBlock rjBlock = self.connectRejectBlock;
            rjBlock(@"",@"",error);
            self.connectRejectBlock = nil;
            self.connectResolveBlock = nil;
            _waitingConnect=nil;
        }
        connected = nil;
        if(hasListeners){
            [self sendEventWithName:EVENT_UNABLE_CONNECT body:@{@"name":peripheral.name?peripheral.name:@"",@"address":peripheral.identifier.UUIDString}];
        }
    }else{
        connected = nil;
        if(hasListeners){
            [self sendEventWithName:EVENT_CONNECTION_LOST body:nil];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
    if(self.connectRejectBlock){
        RCTPromiseRejectBlock rjBlock = self.connectRejectBlock;
        rjBlock(@"",@"",error);
        self.connectRejectBlock = nil;
        self.connectResolveBlock = nil;
        _waitingConnect = nil;
    }
    connected = nil;
    if(hasListeners){
        [self sendEventWithName:EVENT_UNABLE_CONNECT body:@{@"name":peripheral.name?peripheral.name:@"",@"address":peripheral.identifier.UUIDString}];
    }
    }

/**
 * END OF CBCentralManagerDelegate
 **/

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
    if(toWrite && connected
       && [connected.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]
       && [service.UUID.UUIDString isEqualToString:supportServices[0].UUIDString]){
        if(error){
            NSLog(@"Discrover charactoreristics error:%@",error);
           if(writeDataDelegate)
           {
               [writeDataDelegate didWriteDataToBle:false];
               return;
           }
        }
        for(CBCharacteristic *cc in service.characteristics){
            NSLog(@"Characterstic found: %@ in service: %@" ,cc,service.UUID.UUIDString);
            if([cc.UUID.UUIDString isEqualToString:[writeableCharactiscs objectForKey: supportServices[0]]]){
                @try{
                    [connected writeValue:toWrite forCharacteristic:cc type:CBCharacteristicWriteWithoutResponse];
                   if(writeDataDelegate) [writeDataDelegate didWriteDataToBle:true];
                    if(toWrite){
                        NSLog(@"Value wrote: %lu",[toWrite length]);
                    }
                }
                @catch(NSException *e){
                    NSLog(@"ERRO IN WRITE VALUE: %@",e);
                      [writeDataDelegate didWriteDataToBle:false];
                }
            }
        }
        
        
    }
    
    if(error){
        NSLog(@"Discrover charactoreristics error:%@",error);
        return;
    }
    
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
    
    
    /** TESTING NSLOG OUTPUT:: ***/
//    2018-10-01 21:29:24.136033+0800 bluetoothEscposPrinterExamples[8239:4598148] Trying to connect....D7D39238-EF56-71A7-7DCC-D464EFD3BFF1
//    2018-10-01 21:29:24.302880+0800 bluetoothEscposPrinterExamples[8239:4598148] did connected: <CBPeripheral: 0x1c4302d90, identifier = D7D39238-EF56-71A7-7DCC-D464EFD3BFF1, name = BlueTooth Printer, state = connected>
//    2018-10-01 21:29:24.302982+0800 bluetoothEscposPrinterExamples[8239:4598148] going to discover services.
//    2018-10-01 21:29:24.303375+0800 bluetoothEscposPrinterExamples[8239:4598148] going to emit EVEnT_CONNECTED.
//    2018-10-01 21:29:24.431164+0800 bluetoothEscposPrinterExamples[8239:4598148] 扫描到外设服务：BlueTooth Printer -> (
//                                                                                                               "<CBService: 0x1c246b200, isPrimary = YES, UUID = 49535343-FE7D-4AE5-8FA9-9FAFD205E455>",
//                                                                                                               "<CBService: 0x1c246b280, isPrimary = YES, UUID = 18F0>",
//                                                                                                               "<CBService: 0x1c246a740, isPrimary = YES, UUID = E7810A71-73AE-499D-8C15-FAA9AEF0C3F2>"
//                                                                                                               )
//    2018-10-01 21:29:24.431354+0800 bluetoothEscposPrinterExamples[8239:4598148] 服务id：49535343-FE7D-4AE5-8FA9-9FAFD205E455
//    2018-10-01 21:29:24.431448+0800 bluetoothEscposPrinterExamples[8239:4598148] 服务id：18F0
//    2018-10-01 21:29:24.431535+0800 bluetoothEscposPrinterExamples[8239:4598148] 服务id：E7810A71-73AE-499D-8C15-FAA9AEF0C3F2
//    2018-10-01 21:29:24.431552+0800 bluetoothEscposPrinterExamples[8239:4598148] 开始扫描外设服务的特征 BlueTooth Printer...
//    2018-10-01 21:29:24.432374+0800 bluetoothEscposPrinterExamples[8239:4598148] Characterstic found: <CBCharacteristic: 0x1c04afa20, UUID = 49535343-1E4D-4BD9-BA61-23C647249616, properties = 0x10, value = <5f47505f 4c383031 3630>, notifying = NO> in service: 49535343-FE7D-4AE5-8FA9-9FAFD205E455
//    2018-10-01 21:29:24.432406+0800 bluetoothEscposPrinterExamples[8239:4598148] Notify
//    2018-10-01 21:29:24.432417+0800 bluetoothEscposPrinterExamples[8239:4598148] known properties: 16
//    2018-10-01 21:29:24.432455+0800 bluetoothEscposPrinterExamples[8239:4598148] Characterstic found: <CBCharacteristic: 0x1c04af480, UUID = 49535343-8841-43F4-A8D4-ECBE34729BB3, properties = 0xC, value = (null), notifying = NO> in service: 49535343-FE7D-4AE5-8FA9-9FAFD205E455
//    2018-10-01 21:29:24.432753+0800 bluetoothEscposPrinterExamples[8239:4598148] WriteWithoutResponse
//    2018-10-01 21:29:24.432772+0800 bluetoothEscposPrinterExamples[8239:4598148] Write
//    2018-10-01 21:29:24.432785+0800 bluetoothEscposPrinterExamples[8239:4598148] known properties: 12
//    2018-10-01 21:29:24.432988+0800 bluetoothEscposPrinterExamples[8239:4598148] Characterstic found: <CBCharacteristic: 0x1c44ac9c0, UUID = 2AF0, properties = 0x30, value = (null), notifying = NO> in service: 18F0
//    2018-10-01 21:29:24.433005+0800 bluetoothEscposPrinterExamples[8239:4598148] Notify
//    2018-10-01 21:29:24.433015+0800 bluetoothEscposPrinterExamples[8239:4598148] Indicate
//    2018-10-01 21:29:24.433024+0800 bluetoothEscposPrinterExamples[8239:4598148] known properties: 48
//    2018-10-01 21:29:24.433079+0800 bluetoothEscposPrinterExamples[8239:4598148] Characterstic found: <CBCharacteristic: 0x1c44aca80, UUID = 2AF1, properties = 0xC, value = (null), notifying = NO> in service: 18F0
//    2018-10-01 21:29:24.433647+0800 bluetoothEscposPrinterExamples[8239:4598148] WriteWithoutResponse
//    2018-10-01 21:29:24.433662+0800 bluetoothEscposPrinterExamples[8239:4598148] Write
//    2018-10-01 21:29:24.433672+0800 bluetoothEscposPrinterExamples[8239:4598148] known properties: 12
//    2018-10-01 21:29:24.433900+0800 bluetoothEscposPrinterExamples[8239:4598148] Characterstic found: <CBCharacteristic: 0x1c44ac780, UUID = BEF8D6C9-9C21-4C9E-B632-BD58C1009F9F, properties = 0x3E, value = (null), notifying = NO> in service: E7810A71-73AE-499D-8C15-FAA9AEF0C3F2
//    2018-10-01 21:29:24.433928+0800 bluetoothEscposPrinterExamples[8239:4598148] Read
//    2018-10-01 21:29:24.433953+0800 bluetoothEscposPrinterExamples[8239:4598148] WriteWithoutResponse
//    2018-10-01 21:29:24.433964+0800 bluetoothEscposPrinterExamples[8239:4598148] Write
//    2018-10-01 21:29:24.433973+0800 bluetoothEscposPrinterExamples[8239:4598148] Notify
//    2018-10-01 21:29:24.434378+0800 bluetoothEscposPrinterExamples[8239:4598148] Indicate
//    2018-10-01 21:29:24.434389+0800 bluetoothEscposPrinterExamples[8239:4598148] known properties: 62
    
//    for(CBCharacteristic *cc in service.characteristics){
//       // NSLog(@"Characterstic found: %@ in service: %@" ,cc,service.UUID.UUIDString);
//        CBCharacteristicProperties pro = cc.properties;
//        Byte p = (Byte)pro;
////        CBCharacteristicPropertyBroadcast                                                = 0x01,
////        CBCharacteristicPropertyRead                                                    = 0x02,
////        CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
////        CBCharacteristicPropertyWrite                                                    = 0x08,
////        CBCharacteristicPropertyNotify                                                    = 0x10,
////        CBCharacteristicPropertyIndicate                                                = 0x20,
////        CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
////        CBCharacteristicPropertyExtendedProperties                                        = 0x80,
////        CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x100,
////        CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x200
//        if((p) & 0x01){
//            NSLog(@"Broadcast");
//        }
//        if((p>>1) & 0x01){
//            NSLog(@"Read");
//        }
//        if((p>>2) & 0x01){
//            NSLog(@"WriteWithoutResponse");
//        }
//        if((p>>3) & 0x01){
//            NSLog(@"Write");
//        }
//        if((p>>4) & 0x01){
//              NSLog(@"Notify");
//        }
//        if((p>>5) & 0x01){
//               NSLog(@"Indicate");
//        }
//        if((p>>6) & 0x01){
//            NSLog(@"AuthenticatedSignedWrites");
//        }
//        if((p>>7) & 0x01){
//            NSLog(@"ExtendedProperties");
//        }
//        {
//            NSLog(@"known properties: %lu", pro);
//        }
//    }
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral        The peripheral providing this information.
 *  @param characteristic    A <code>CBCharacteristic</code> object.
 *    @param error            If an error occurred, the cause of the failure.
 *
 *  @discussion                This method returns the result of a {@link writeValue:forCharacteristic:type:} call, when the <code>CBCharacteristicWriteWithResponse</code> type is used.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if(error){
        NSLog(@"Error in writing bluetooth: %@",error);
        if(writeDataDelegate){
            [writeDataDelegate didWriteDataToBle:false];
        }
    }
    
    NSLog(@"Write bluetooth success.");
    if(writeDataDelegate){
        [writeDataDelegate didWriteDataToBle:true];
    }
}
 
@end
