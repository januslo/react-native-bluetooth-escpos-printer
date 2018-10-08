
import { NativeModules } from 'react-native';
 const {BluetoothManager,BluetoothEscposPrinter,BluetoothTscPrinter}= NativeModules;

BluetoothTscPrinter.DIRECTION = {
    FORWARD: 0,
    BACKWARD: 1
};

BluetoothTscPrinter.DENSITY = {
    DNESITY0: 0,
    DNESITY1: 1,
    DNESITY2: 2,
    DNESITY3: 3,
    DNESITY4: 4,
    DNESITY5: 5,
    DNESITY6: 6,
    DNESITY7: 7,
    DNESITY8: 8,
    DNESITY9: 9,
    DNESITY10: 10,
    DNESITY11: 11,
    DNESITY12: 12,
    DNESITY13: 13,
    DNESITY14: 14,
    DNESITY15: 15
};
BluetoothTscPrinter.BARCODETYPE = {
    CODE128: "128",
    CODE128M: "128M",
    EAN128: "EAN128",
    ITF25: "25",
    ITF25C: "25C",
    CODE39: "39",
    CODE39C: "39C",
    CODE39S: "39S",
    CODE93: "93",
    EAN13: "EAN13",
    EAN13_2: "EAN13+2",
    EAN13_5: "EAN13+5",
    EAN8: "EAN8",
    EAN8_2: "EAN8+2",
    EAN8_5: "EAN8+5",
    CODABAR: "CODA",
    POST: "POST",
    UPCA: "EAN13",
    UPCA_2: "EAN13+2",
    UPCA_5: "EAN13+5",
    UPCE: "EAN13",
    UPCE_2: "EAN13+2",
    UPCE_5: "EAN13+5",
    CPOST: "CPOST",
    MSI: "MSI",
    MSIC: "MSIC",
    PLESSEY: "PLESSEY",
    ITF14: "ITF14",
    EAN14: "EAN14"
};
BluetoothTscPrinter.FONTTYPE = {
    FONT_1: "1",
    FONT_2: "2",
    FONT_3: "3",
    FONT_4: "4",
    FONT_5: "5",
    FONT_6: "6",
    FONT_7: "7",
    FONT_8: "8",
    SIMPLIFIED_CHINESE: "TSS24.BF2",
    TRADITIONAL_CHINESE: "TST24.BF2",
    KOREAN: "K"
};
BluetoothTscPrinter.EEC = {
    LEVEL_L: "L",
    LEVEL_M: "M",
    LEVEL_Q: "Q",
    LEVEL_H: "H"

};
BluetoothTscPrinter.ROTATION = {
    ROTATION_0: 0,
    ROTATION_90: 90,
    ROTATION_180: 180,
    ROTATION_270: 270
};
 BluetoothTscPrinter.FONTMUL = {
    MUL_1: 1,
    MUL_2: 2,
    MUL_3: 3,
    MUL_4: 4,
    MUL_5: 5,
    MUL_6: 6,
    MUL_7: 7,
    MUL_8: 8,
    MUL_9: 9,
    MUL_10: 10
};
BluetoothTscPrinter.BITMAP_MODE = {
    OVERWRITE: 0,
    OR: 1,
    XOR: 2
};
BluetoothTscPrinter.PRINT_SPEED = {
    SPEED1DIV5:1,
    SPEED2:2,
    SPEED3:3,
    SPEED4:4
};
BluetoothTscPrinter.TEAR = {
	ON:'ON',
	OFF:'OFF'
};
BluetoothTscPrinter.READABLE={
  DISABLE:0,
  EANBLE:1
};

BluetoothEscposPrinter.ERROR_CORRECTION = {
    L:1,
    M:0,
    Q:3,
    H:2
};

BluetoothEscposPrinter.BARCODETYPE={
    UPC_A:65,//11<=n<=12
    UPC_E:66,//11<=n<=12
    JAN13:67,//12<=n<=12
    JAN8:68,//7<=n<=8
    CODE39:69,//1<=n<=255
    ITF:70,//1<=n<=255(even numbers)
    CODABAR:71,//1<=n<=255
    CODE93:72,//1<=n<=255
    CODE128:73//2<=n<=255
};
BluetoothEscposPrinter.ROTATION={
    OFF:0,
    ON:1
};
BluetoothEscposPrinter.ALIGN={
    LEFT:0,
    CENTER:1,
    RIGHT:2
};

 module.exports ={
    BluetoothManager,BluetoothEscposPrinter,BluetoothTscPrinter};
