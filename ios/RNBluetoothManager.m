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
    CBPeripheral *peripheral = [self.foundDevices objectForKey:address];
    self.connectResolveBlock = resolve;
    self.connectRejectBlock = reject;
    if(peripheral){
        [self.centralManager connectPeripheral:peripheral options:nil];
        _waitingConnect = nil;
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
    //TODO: peripheral.identifier.UUIDString
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
   
    NSString *pId = peripheral.identifier.UUIDString;
    if(_waitingConnect && _waitingConnect==pId && self.connectResolveBlock){
        [peripheral discoverServices:nil];
      
    }
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

 
@end
