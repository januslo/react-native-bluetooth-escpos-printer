package cn.jystudio.bluetooth.escpos.command.sdk;

import java.io.UnsupportedEncodingException;
import java.util.Arrays;

public class PrinterCommand {

    /**
     * 打印机初始化
     *
     * @return
     */
    public static byte[] POS_Set_PrtInit() {
        return Command.ESC_Init;
    }

    /**
     * 打印并换行
     *
     * @return
     */
    public static byte[] POS_Set_LF() {
        return Command.LF;
    }

    /**
     * 打印并走纸 (0~255)
     *
     * @param feed
     * @return
     */
    public static byte[] POS_Set_PrtAndFeedPaper(int feed) {
        if (feed > 255 | feed < 0) return null;

        byte[] data = Arrays.copyOf(Command.ESC_J, Command.ESC_J.length);
        data[2] = (byte) feed;
        return data;
    }

    /**
     * 打印自检页
     *
     * @return
     */
    public static byte[] POS_Set_PrtSelfTest() {
        return Command.US_vt_eot;
    }

    /**
     * 蜂鸣指令
     *
     * @param m 蜂鸣次数
     * @param t 每次蜂鸣的时间
     * @return
     */
    public static byte[] POS_Set_Beep(int m, int t) {

        if ((m < 1 || m > 9) | (t < 1 || t > 9)) return null;

        byte[] data = Arrays.copyOf(Command.ESC_B_m_n, Command.ESC_B_m_n.length);
        data[2] = (byte) m;
        data[3] = (byte) t;
        return data;
    }

    /**
     * 切刀指令(走纸到切刀位置并切纸)
     *
     * @param cut 0~255
     * @return
     */
    public static byte[] POS_Set_Cut(int cut) {
        if (cut > 255 | cut < 0) return null;

        byte[] data = Arrays.copyOf(Command.GS_V_m_n, Command.GS_V_m_n.length);
        data[3] = (byte) cut;
        return data;
    }

    /**
     * 钱箱指令
     *
     * @param nMode
     * @param nTime1
     * @param nTime2
     * @return
     */
    public static byte[] POS_Set_Cashbox(int nMode, int nTime1, int nTime2) {

        if ((nMode < 0 || nMode > 1) | nTime1 < 0 | nTime1 > 255 | nTime2 < 0 | nTime2 > 255) return null;

        byte[] data = Arrays.copyOf(Command.ESC_p, Command.ESC_p.length);
        data[2] = (byte) nMode;
        data[3] = (byte) nTime1;
        data[4] = (byte) nTime2;
        return data;
    }

    /**
     * 设置绝对打印位置
     *
     * @param absolute
     * @return
     */
    public static byte[] POS_Set_Absolute(int absolute) {
        if (absolute > 65535 | absolute < 0) return null;

        byte[] data = Arrays.copyOf(Command.ESC_Absolute, Command.ESC_Absolute.length);
        data[2] = (byte) (absolute % 0x100);
        data[3] = (byte) (absolute / 0x100);
        return data;
    }

    /**
     * 设置相对打印位置
     *
     * @param relative
     * @return
     */
    public static byte[] POS_Set_Relative(int relative) {
        if (relative < 0 | relative > 65535) return null;

        byte[] data = Arrays.copyOf(Command.ESC_Relative, Command.ESC_Relative.length);
        data[2] = (byte) (relative % 0x100);
        data[3] = (byte) (relative / 0x100);
        return data;
    }

    /**
     * 设置左边距
     *
     * @param left
     * @return
     */
    public static byte[] POS_Set_LeftSP(int left) {
        if (left > 255 | left < 0) return null;

        byte[] data = Arrays.copyOf(Command.GS_LeftSp, Command.GS_LeftSp.length);
        data[2] = (byte) (left % 0x100);
        data[3] = (byte) (left / 0x100);
        return data;
    }

    /**
     * 设置对齐模式
     *
     * @param align
     * @return
     */
    public static byte[] POS_S_Align(int align) {
        if ((align < 0 || align > 2) && (align < 48 || align > 50)) return null;

        byte[] data = Arrays.copyOf(Command.ESC_Align, Command.ESC_Align.length);
        data[2] = (byte) align;
        return data;
    }

    /**
     * 设置打印区域宽度
     *
     * @param width
     * @return
     */
    public static byte[] POS_Set_PrintWidth(int width) {
        if (width < 0 | width > 255) return null;

        byte[] data = Arrays.copyOf(Command.GS_W, Command.GS_W.length);
        data[2] = (byte) (width % 0x100);
        data[3] = (byte) (width / 0x100);
        return data;
    }

    /**
     * 设置默认行间距
     *
     * @return
     */
    public static byte[] POS_Set_DefLineSpace() {
        return Command.ESC_Two;
    }

    /**
     * 设置行间距
     *
     * @param space
     * @return
     */
    public static byte[] POS_Set_LineSpace(int space) {
        if (space < 0 | space > 255) return null;

        byte[] data = Arrays.copyOf(Command.ESC_Three, Command.ESC_Three.length);
        data[2] = (byte) space;
        return data;
    }

    /**
     * 选择字符代码页
     *
     * @param page
     * @return
     */
    public static byte[] POS_Set_CodePage(int page) {
        if (page > 255) return null;

        byte[] data = Arrays.copyOf(Command.ESC_t, Command.ESC_t.length);
        data[2] = (byte) page;
        return data;
    }

    /**
     * 打印文本文档
     *
     * @param pszString    要打印的字符串
     * @param encoding     打印字符对应编码
     * @param codepage     设置代码页(0--255)
     * @param nWidthTimes  倍宽(0--4)
     * @param nHeightTimes 倍高(0--4)
     * @param nFontType    字体类型(只对Ascii码有效)(0,1 48,49)
     */
    public static byte[] POS_Print_Text(String pszString, String encoding, int codepage,
                                        int nWidthTimes, int nHeightTimes, int nFontType) {
        if (codepage < 0 || codepage > 255 || pszString == null || "".equals(pszString) || pszString.length() < 1) {
            return null;
        }

        byte[] pbString = null;
        try {
            pbString = pszString.getBytes(encoding);
        } catch (UnsupportedEncodingException e) {
            return null;
        }

        byte[] intToWidth = {0x00, 0x10, 0x20, 0x30};
        byte[] intToHeight = {0x00, 0x01, 0x02, 0x03};
        byte[] gsExclamationMark = Arrays.copyOf(Command.GS_ExclamationMark, Command.GS_ExclamationMark.length);
        gsExclamationMark[2] = (byte) (intToWidth[nWidthTimes] + intToHeight[nHeightTimes]);
        byte[] escT = Arrays.copyOf(Command.ESC_t, Command.ESC_t.length);
        escT[2] = (byte) codepage;
        byte[] escM = Arrays.copyOf(Command.ESC_M, Command.ESC_M.length);
        escM[2] = (byte) nFontType;
        byte[] data = null;
        if (codepage == 0) {
            data = concatAll(gsExclamationMark, escT, Command.FS_and, escM, pbString);
        } else {
            data = concatAll(gsExclamationMark, escT, Command.FS_dot, escM, pbString);
        }
        return data;
    }

    /**
     * 加粗指令(最低位为1有效)
     *
     * @param bold
     * @return
     */
    public static byte[] POS_Set_Bold(int bold) {
        byte[] escE = Arrays.copyOf(Command.ESC_E, Command.ESC_E.length);
        byte[] escG = Arrays.copyOf(Command.ESC_G, Command.ESC_G.length);

        escE[2] = (byte) bold;
        escG[2] = (byte) bold;
        return concatAll(escE, escG);
    }

    /**
     * 设置倒置打印模式(当最低位为1时有效)
     *
     * @param brace
     * @return
     */
    public static byte[] POS_Set_LeftBrace(int brace) {
        byte[] data = Arrays.copyOf(Command.ESC_LeftBrace, Command.ESC_LeftBrace.length);
        data[2] = (byte) brace;
        return data;
    }

    /**
     * 设置下划线
     *
     * @param line
     * @return
     */
    public static byte[] POS_Set_UnderLine(int line) {
        if ((line < 0 || line > 2)) return null;
        byte[] escMins = Arrays.copyOf(Command.ESC_Minus, Command.ESC_Minus.length);
        escMins[2] = (byte) line;
        byte[] fsMinus = Arrays.copyOf(Command.FS_Minus, Command.FS_Minus.length);
        fsMinus[2] = (byte) line;
        return concatAll(escMins, fsMinus);
    }

    /**
     * 选择字体大小(倍高倍宽)
     *
     * @param size1
     * @param size2
     * @return
     */
    public static byte[] POS_Set_FontSize(int size1, int size2) {
        if (size1 < 0 | size1 > 7 | size2 < 0 | size2 > 7) return null;
        byte[] intToWidth = {0x00, 0x10, 0x20, 0x30, 0x40, 0x50, 0x60, 0x70};
        byte[] intToHeight = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07};
        byte[] data = Arrays.copyOf(Command.GS_ExclamationMark, Command.GS_ExclamationMark.length);
        data[2] = (byte) (intToWidth[size1] + intToHeight[size2]);
        return data;
    }

    /**
     * 设置反显打印
     *
     * @param inverse
     * @return
     */
    public static byte[] POS_Set_Inverse(int inverse) {
        byte[] data = Arrays.copyOf(Command.GS_B, Command.GS_B.length);
        data[2] = (byte) inverse;
        return data;
    }

    /**
     * 设置旋转90度打印
     *
     * @param rotate
     * @return
     */
    public static byte[] POS_Set_Rotate(int rotate) {
        if (rotate < 0 || rotate > 1) return null;

        byte[] data = Arrays.copyOf(Command.ESC_V, Command.ESC_V.length);
        data[2] = (byte) rotate;
        return data;
    }

    /**
     * 选择字体字型
     *
     * @param font
     * @return
     */
    public static byte[] POS_Set_ChoseFont(int font) {
        if (font > 1 | font < 0) return null;

        byte[] data = Arrays.copyOf(Command.ESC_M, Command.ESC_M.length);
        data[2] = (byte) font;
        return data;

    }

//***********************************以下函数为公开函数***********************************************************//

    /**
     * 二维码打印函数
     *
     * @param str                   打印二维码数据
     * @param nVersion              二维码类型
     * @param nErrorCorrectionLevel 纠错级别
     * @param nMagnification        放大倍数
     * @return
     */
    public static byte[] getQRCodeCommand(String str, int nVersion, int nErrorCorrectionLevel,
                                       int nMagnification) {

        if (nVersion < 0 | nVersion > 19 | nErrorCorrectionLevel < 0 | nErrorCorrectionLevel > 3
                | nMagnification < 1 | nMagnification > 8) {
            return null;
        }

        byte[] bCodeData = null;
        try {
            bCodeData = str.getBytes("GBK");

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return null;
        }

        byte[] command = new byte[bCodeData.length + 7];

        command[0] = 27;
        command[1] = 90;
        command[2] = ((byte) nVersion);
        command[3] = ((byte) nErrorCorrectionLevel);
        command[4] = ((byte) nMagnification);
        command[5] = (byte) (bCodeData.length & 0xff);
        command[6] = (byte) ((bCodeData.length & 0xff00) >> 8);
        System.arraycopy(bCodeData, 0, command, 7, bCodeData.length);

        return command;
    }

    /**
     * 打印一维条码
     *
     * @param str              打印条码字符
     * @param nType            条码类型(65~73)
     * @param nWidthX          条码宽度
     * @param nHeight          条码高度
     * @param nHriFontType     HRI字型
     * @param nHriFontPosition HRI位置
     * @return
     */
    public static byte[] getBarCodeCommand(String str, int nType, int nWidthX, int nHeight,
                                           int nHriFontType, int nHriFontPosition) {

        if (nType < 0x41 | nType > 0x49 | nWidthX < 2 | nWidthX > 6
                | nHeight < 1 | nHeight > 255 | str.length() == 0)
            return null;

        byte[] bCodeData = null;
        try {
            bCodeData = str.getBytes("GBK");

        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return null;
        }

        byte[] command = new byte[bCodeData.length + 16];

        command[0] = 29;
        command[1] = 119;
        command[2] = ((byte) nWidthX);
        command[3] = 29;
        command[4] = 104;
        command[5] = ((byte) nHeight);
        command[6] = 29;
        command[7] = 102;
        command[8] = ((byte) (nHriFontType & 0x01));
        command[9] = 29;
        command[10] = 72;
        command[11] = ((byte) (nHriFontPosition & 0x03));
        command[12] = 29;
        command[13] = 107;
        command[14] = ((byte) nType);
        command[15] = (byte) (byte) bCodeData.length;
        System.arraycopy(bCodeData, 0, command, 16, bCodeData.length);


        return command;
    }

    /**
     * 设置打印模式(选择字体(font:A font:B),加粗,字体倍高倍宽(最大4倍高宽))
     *
     * @param str        打印的字符串
     * @param bold       加粗
     * @param font       选择字型
     * @param widthsize  倍宽
     * @param heigthsize 倍高
     * @return
     */
    public static byte[] POS_Set_Font(String str, int bold, int font, int widthsize, int heigthsize) {

        if (str.length() == 0 | widthsize < 0 | widthsize > 4 | heigthsize < 0 | heigthsize > 4
                | font < 0 | font > 1)
            return null;

        byte[] strData = null;
        try {
            strData = str.getBytes("GBK");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
            return null;
        }

        byte[] command = new byte[strData.length + 9];

        byte[] intToWidth = {0x00, 0x10, 0x20, 0x30};//最大四倍宽
        byte[] intToHeight = {0x00, 0x01, 0x02, 0x03};//最大四倍高

        command[0] = 27;
        command[1] = 69;
        command[2] = ((byte) bold);
        command[3] = 27;
        command[4] = 77;
        command[5] = ((byte) font);
        command[6] = 29;
        command[7] = 33;
        command[8] = (byte) (intToWidth[widthsize] + intToHeight[heigthsize]);

        System.arraycopy(strData, 0, command, 9, strData.length);
        return command;
    }

//**********************************************************************************************************//

    public static byte[] concatAll(byte[] first, byte[]... rest) {
        int totalLength = first.length;
        for (byte[] array : rest) {
            totalLength += array.length;
        }
        byte[] result = Arrays.copyOf(first, totalLength);
        int offset = first.length;
        for (byte[] array : rest) {
            System.arraycopy(array, 0, result, offset, array.length);
            offset += array.length;
        }
        return result;
    }
}
