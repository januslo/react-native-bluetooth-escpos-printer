package cn.jystudio.bluetooth.escpos.command.sdk;

public class Command {

	private static final byte ESC = 0x1B;
	private static final byte FS = 0x1C;
	private static final byte GS = 0x1D;
	private static final byte US = 0x1F;
	private static final byte DLE = 0x10;
	private static final byte DC4 = 0x14;
	private static final byte DC1 = 0x11;
	private static final byte SP = 0x20;
	private static final byte NL = 0x0A;
	private static final byte FF = 0x0C;
	public static final byte PIECE = (byte) 0xFF;
	public static final byte NUL = (byte) 0x00;
	
	//打印机初始化
	public static byte[] ESC_Init = new byte[] {ESC, '@' };
	
	/**
	 * 打印命令
	 */
	//打印并换行
	public static byte[] LF = new byte[] {NL};
	
	//打印并走纸
	public static byte[] ESC_J = new byte[] {ESC, 'J', 0x00 };
	public static byte[] ESC_d = new byte[] {ESC, 'd', 0x00 };
	
	//打印自检页
	public static byte[] US_vt_eot = new byte[] {US, DC1, 0x04 };
	
	 //蜂鸣指令
    public static byte[] ESC_B_m_n = new byte[] {ESC, 'B', 0x00, 0x00 };
	
    //切刀指令
    public static byte[] GS_V_n = new byte[] {GS, 'V', 0x00 };
    public static byte[] GS_V_m_n = new byte[] {GS, 'V', 'B', 0x00 };
    public static byte[] GS_i = new byte[] {ESC, 'i' };
    public static byte[] GS_m = new byte[] {ESC, 'm' };
	
	/**
	 * 字符设置命令
	 */
	//设置字符右间距
	public static byte[] ESC_SP = new byte[] {ESC, SP, 0x00 };
	
	//设置字符打印字体格式
	public static byte[] ESC_ExclamationMark = new byte[] {ESC, '!', 0x00 };
	
	//设置字体倍高倍宽
	public static byte[] GS_ExclamationMark = new byte[] {GS, '!', 0x00 };
	
	//设置反显打印
	public static byte[] GS_B = new byte[] {GS, 'B', 0x00 };
	
	//取消/选择90度旋转打印
	public static byte[] ESC_V = new byte[] {ESC, 'V', 0x00 };
	
	//选择字体字型(主要是ASCII码)
	public static byte[] ESC_M = new byte[] {ESC, 'M', 0x00 };
	
	//选择/取消加粗指令
	public static byte[] ESC_G = new byte[] {ESC, 'G', 0x00 };
	public static byte[] ESC_E = new byte[] {ESC, 'E', 0x00 };
	
	//选择/取消倒置打印模式
	public static byte[] ESC_LeftBrace = new byte[] {ESC, '{', 0x00 };
	
	//设置下划线点高度(字符)
	public static byte[] ESC_Minus = new byte[] {ESC, 45, 0x00 };
	
	//字符模式
	public static byte[] FS_dot = new byte[] {FS, 46 };
	
	//汉字模式
	public static byte[] FS_and = new byte[] {FS, '&' };
	
	//设置汉字打印模式
	public static byte[] FS_ExclamationMark = new byte[] {FS, '!', 0x00 };
	
	//设置下划线点高度(汉字)
	public static byte[] FS_Minus = new byte[] {FS, 45, 0x00 };
	
	//设置汉字左右间距
	public static byte[] FS_S = new byte[] {FS, 'S', 0x00, 0x00 };
	
	//选择字符代码页
	public static byte[] ESC_t = new byte[] {ESC, 't', 0x00 };
	
	/**
	 * 格式设置指令
	 */
	//设置默认行间距
	public static byte[] ESC_Two = new byte[] {ESC, 50}; 
	
	//设置行间距
	public static byte[] ESC_Three = new byte[] {ESC, 51, 0x00 };
	
	//设置对齐模式
	public static byte[] ESC_Align = new byte[] {ESC, 'a', 0x00 };
	
	//设置左边距
	public static byte[] GS_LeftSp = new byte[] {GS, 'L', 0x00 , 0x00 };
	
	//设置绝对打印位置
	//将当前位置设置到距离行首（nL + nH x 256）处。
	//如果设置位置在指定打印区域外，该命令被忽略
	public static byte[] ESC_Absolute  = new byte[] {ESC, '$', 0x00, 0x00 };
	
	//设置相对打印位置
	public static byte[] ESC_Relative = new byte[] {ESC, 92, 0x00, 0x00 };
	
	//设置打印区域宽度
	public static byte[] GS_W = new byte[] {GS, 'W', 0x00, 0x00 };

	/**
	 * 状态指令
	 */
	//实时状态传送指令
	public static byte[] DLE_eot = new byte[] {DLE, 0x04, 0x00 };
	
	//实时弹钱箱指令
	public static byte[] DLE_DC4 = new byte[] {DLE, DC4, 0x00, 0x00, 0x00 };
	
	//标准弹钱箱指令
	public static byte[] ESC_p = new byte[] {ESC, 'F', 0x00, 0x00, 0x00 };
	
	/**
	 * 条码设置指令
	 */
	//选择HRI打印方式
	public static byte[] GS_H = new byte[] {GS, 'H', 0x00 };
	
	//设置条码高度
	public static byte[] GS_h = new byte[] {GS, 'h', (byte) 0xa2 };
	
	//设置条码宽度
	public static byte[] GS_w = new byte[] {GS, 'w', 0x00 };
	
	//设置HRI字符字体字型
	public static byte[] GS_f = new byte[] {GS, 'f', 0x00 };
	
	//条码左偏移指令
	public static byte[] GS_x = new byte[] {GS, 'x', 0x00 };
	
	//打印条码指令
	public static byte[] GS_k = new byte[] {GS, 'k', 'A', FF };

	//二维码相关指令		
    public static byte[] GS_k_m_v_r_nL_nH = new byte[] { ESC, 'Z', 0x03, 0x03, 0x08, 0x00, 0x00 };
	
}
