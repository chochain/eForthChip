-- *==============================================================*
-- * FPGA Project:        32-Bit CPU in Altera SOPC Builder       *
-- * File:                ep32.vhd                                *
-- * Author:              C.H.Ting                                *
-- * Description:         ep32 CPU Block                          *
-- *                                                              *
-- * Revision History:                                            *
-- * Date         By Who        Modification                      *
-- * 06/06/05     C.H. Ting     Convert EP24 to 32-bits.          *
-- * 06/10/05     Robyn King    Made compatible with Altera SOPC  *
-- *                            Builder.                          *
-- * 06/27/05     C.H. Ting     Removed Line Drawing Engine.      *
-- * 07/27/05     Robyn King    Cleaned up code.                  *
-- * 08/07/10     C. H. Ting    Return to eP32p                   *
-- * 11/22/21     C. H. Ting    JVM                               *
-- ****************************************************************
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_unsigned.all;

entity eJ32e is 
  generic(width: integer := 31);
  port(
    -- input port
    clk:            in      std_logic;
    clr:            in      std_logic;
    data_i_o:         out      std_logic_vector(7 downto 0);
    -- output port
    icode:          out     std_logic_vector(7 downto 0);
    write_o:          out     std_logic;
    addr_o_o:         out     std_logic_vector(width downto 0);
    data_o_o:     	out     std_logic_vector(7 downto 0);
    t_o:         out     std_logic_vector(width downto 0);
    p_o:     	out     std_logic_vector(width downto 0);
    a_o:         out     std_logic_vector(width downto 0);
    phase_o:     	out     integer range 0 to 5;
    sp_o:     	out     std_logic_vector(4 downto 0);
    rp_o:     	out     std_logic_vector(5 downto 0)
  );
end entity eJ32e;

architecture behavioral of eJ32e is
	component ram_memory IS
		PORT
		(
			address		: IN STD_LOGIC_VECTOR (12 DOWNTO 0);
			clock		: IN STD_LOGIC ;
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
		);
	END component;
	component idiv
		PORT
		(
			denom		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			numer		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			quotient		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			remain		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	component imult
		PORT
		(
			dataa		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
		);
	end component;
	component isht
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			direction		: IN STD_LOGIC ;
			distance		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;
	component iushiftr
		PORT
		(
			data		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			distance		: IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			result		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	end component;

	type sstack is array(31 downto 0) of std_logic_vector(width downto 0);
	signal s_stack: sstack;
	type rstack is array(63 downto 0) of std_logic_vector(width downto 0);
	signal r_stack: rstack;
	signal sp,sp1: std_logic_vector(4 downto 0); 
	signal rp,rp4: std_logic_vector(5 downto 0); 
	signal t,s,r,a: std_logic_vector(width downto 0);
	signal t_in,r_in,a_in: std_logic_vector(width downto 0);
	signal r_z,t_z: std_logic;
	signal tload,sload,spush,spopp,rload,rloada,rpush,rpopp,aload: std_logic;
	signal p,p_in,addr_o: std_logic_vector(width downto 0);
	signal code,code_in,data_i,data_o: std_logic_vector(7 downto 0);
	signal phase,phase_in: integer range 0 to 5;
	signal data_sel,data_in: integer range 0 to 3;
	signal write,addrload,addr_sel,addr_in: std_logic;
	signal phaseload,dataload,pload,codeload: std_logic;
	signal quotient,remain: std_logic_vector(width downto 0);
	signal product: std_logic_vector(63 downto 0);
	signal isht_o,iushr_o: std_logic_vector(width downto 0);
	signal right_shift: std_logic;
	signal inptr,outptr: std_logic_vector(width downto 0);
	signal inload,outload: std_logic;
  
  -- machine instructions selected by code

	constant nop        : std_logic_vector(7 downto 0) :="00000000";
	constant aconst_null: std_logic_vector(7 downto 0) :="00000001";
	constant iconst_m1  : std_logic_vector(7 downto 0) :="00000010";
	constant iconst_0   : std_logic_vector(7 downto 0) :="00000011";

	constant iconst_1 : std_logic_vector(7 downto 0) :="00000100";
	constant iconst_2 : std_logic_vector(7 downto 0) :="00000101";
	constant iconst_3 : std_logic_vector(7 downto 0) :="00000110";
	constant iconst_4 : std_logic_vector(7 downto 0) :="00000111";

	constant iconst_5 : std_logic_vector(7 downto 0) :="00001000";
	constant lconst_0 : std_logic_vector(7 downto 0) :="00001001";
	constant lconst_1 : std_logic_vector(7 downto 0) :="00001010";
	constant fconst_0 : std_logic_vector(7 downto 0) :="00001011";

	constant fconst_1 : std_logic_vector(7 downto 0) :="00001100";
	constant fconst_2 : std_logic_vector(7 downto 0) :="00001101";
	constant dconst_0 : std_logic_vector(7 downto 0) :="00001110";
	constant dconst_1 : std_logic_vector(7 downto 0) :="00001111";

	constant bipush   : std_logic_vector(7 downto 0) :="00010000";
	constant sipush   : std_logic_vector(7 downto 0) :="00010001";
	constant ldc      : std_logic_vector(7 downto 0) :="00010010";
	constant ldc_w    : std_logic_vector(7 downto 0) :="00010011";

	constant ldc2_w   : std_logic_vector(7 downto 0) :="00010100";
	constant iload    : std_logic_vector(7 downto 0) :="00010101";
	constant lload    : std_logic_vector(7 downto 0) :="00010110";
	constant fload    : std_logic_vector(7 downto 0) :="00010111";

	constant dload    : std_logic_vector(7 downto 0) :="00011000";
	constant jaload   : std_logic_vector(7 downto 0) :="00011001";
	constant iload_0  : std_logic_vector(7 downto 0) :="00011010";
	constant iload_1  : std_logic_vector(7 downto 0) :="00011011";

	constant iload_2  : std_logic_vector(7 downto 0) :="00011100";
	constant iload_3  : std_logic_vector(7 downto 0) :="00011101";
	constant lload_0  : std_logic_vector(7 downto 0) :="00011110";
	constant lload_1  : std_logic_vector(7 downto 0) :="00011111";

	constant lload_2  : std_logic_vector(7 downto 0) :="00100000";
	constant lload_3  : std_logic_vector(7 downto 0) :="00100001";
	constant fload_0  : std_logic_vector(7 downto 0) :="00100010";
	constant fload_1  : std_logic_vector(7 downto 0) :="00100011";

	constant fload_2  : std_logic_vector(7 downto 0) :="00100100";
	constant fload_3  : std_logic_vector(7 downto 0) :="00100101";
	constant dload_0  : std_logic_vector(7 downto 0) :="00100110";
	constant dload_1  : std_logic_vector(7 downto 0) :="00100111";

	constant dload_2  : std_logic_vector(7 downto 0) :="00101000";
	constant dload_3  : std_logic_vector(7 downto 0) :="00101001";
	constant aload_0  : std_logic_vector(7 downto 0) :="00101010";
	constant aload_1  : std_logic_vector(7 downto 0) :="00101011";

	constant aload_2  : std_logic_vector(7 downto 0) :="00101100";
	constant aload_3  : std_logic_vector(7 downto 0) :="00101101";
	constant iaload   : std_logic_vector(7 downto 0) :="00101110";
	constant laload   : std_logic_vector(7 downto 0) :="00101111";

	constant faload   : std_logic_vector(7 downto 0) :="00110000";
	constant daload   : std_logic_vector(7 downto 0) :="00110001";
	constant aaload   : std_logic_vector(7 downto 0) :="00110010";
	constant baload   : std_logic_vector(7 downto 0) :="00110011";

	constant caload   : std_logic_vector(7 downto 0) :="00110100";
	constant saload   : std_logic_vector(7 downto 0) :="00110101";
	constant istore   : std_logic_vector(7 downto 0) :="00110110";
	constant lstore   : std_logic_vector(7 downto 0) :="00110111";

	constant fstore   : std_logic_vector(7 downto 0) :="00111000";
	constant dstore   : std_logic_vector(7 downto 0) :="00111001";
	constant astore   : std_logic_vector(7 downto 0) :="00111010";
	constant istore_0 : std_logic_vector(7 downto 0) :="00111011";

	constant istore_1 : std_logic_vector(7 downto 0) :="00111100";
	constant istore_2 : std_logic_vector(7 downto 0) :="00111101";
	constant istore_3 : std_logic_vector(7 downto 0) :="00111110";
	constant lstore_0 : std_logic_vector(7 downto 0) :="00111111";

	constant lstore_1 : std_logic_vector(7 downto 0) :="01000000";
	constant lstore_2 : std_logic_vector(7 downto 0) :="01000001";
	constant lstore_3 : std_logic_vector(7 downto 0) :="01000010";
	constant fstore_0 : std_logic_vector(7 downto 0) :="01000011";

	constant fstore_1 : std_logic_vector(7 downto 0) :="01000100";
	constant fstore_2 : std_logic_vector(7 downto 0) :="01000101";
	constant fstore_3 : std_logic_vector(7 downto 0) :="01000110";
	constant dstore_0 : std_logic_vector(7 downto 0) :="01000111";

	constant dstore_1 : std_logic_vector(7 downto 0) :="01001000";
	constant dstore_2 : std_logic_vector(7 downto 0) :="01001001";
	constant dstore_3 : std_logic_vector(7 downto 0) :="01001010";
	constant astore_0 : std_logic_vector(7 downto 0) :="01001011";

	constant astore_1 : std_logic_vector(7 downto 0) :="01001100";
	constant astore_2 : std_logic_vector(7 downto 0) :="01001101";
	constant astore_3 : std_logic_vector(7 downto 0) :="01001110";
	constant iastore  : std_logic_vector(7 downto 0) :="01001111";

	constant lastore  : std_logic_vector(7 downto 0) :="01010000";
	constant fastore  : std_logic_vector(7 downto 0) :="01010001";
	constant diastore : std_logic_vector(7 downto 0) :="01010010";
	constant aastore  : std_logic_vector(7 downto 0) :="01010011";

	constant bastore  : std_logic_vector(7 downto 0) :="01010100";
	constant castore  : std_logic_vector(7 downto 0) :="01010101";
	constant sastore  : std_logic_vector(7 downto 0) :="01010110";
	constant pop      : std_logic_vector(7 downto 0) :="01010111";

	constant pop2     : std_logic_vector(7 downto 0) :="01011000";
	constant dup      : std_logic_vector(7 downto 0) :="01011001";
	constant dup_x1   : std_logic_vector(7 downto 0) :="01011010";
	constant dup_x2   : std_logic_vector(7 downto 0) :="01011011";

	constant dup2     : std_logic_vector(7 downto 0) :="01011100";
	constant dup2_x1  : std_logic_vector(7 downto 0) :="01011101";
	constant dup2_x   : std_logic_vector(7 downto 0) :="01011110";
	constant swap     : std_logic_vector(7 downto 0) :="01011111";

	constant iadd     : std_logic_vector(7 downto 0) :="01100000";
	constant ladd     : std_logic_vector(7 downto 0) :="01100001";
	constant fadd     : std_logic_vector(7 downto 0) :="01100010";
	constant dadd     : std_logic_vector(7 downto 0) :="01100011";

	constant isub     : std_logic_vector(7 downto 0) :="01100100";
	constant lsub     : std_logic_vector(7 downto 0) :="01100101";
	constant fsub     : std_logic_vector(7 downto 0) :="01100110";
	constant dsub     : std_logic_vector(7 downto 0) :="01100111";

	constant imul  : std_logic_vector(7 downto 0) :="01101000";
	constant lmul  : std_logic_vector(7 downto 0) :="01101001";
	constant fmul  : std_logic_vector(7 downto 0) :="01101010";
	constant dmul  : std_logic_vector(7 downto 0) :="01101011";

	constant idivv  : std_logic_vector(7 downto 0) :="01101100";
	constant ldiv  : std_logic_vector(7 downto 0) :="01101101";
	constant fdiv  : std_logic_vector(7 downto 0) :="01101110";
	constant ddiv  : std_logic_vector(7 downto 0) :="01101111";

	constant irem  : std_logic_vector(7 downto 0) :="01110000";
	constant lrem  : std_logic_vector(7 downto 0) :="01110001";
	constant frem  : std_logic_vector(7 downto 0) :="01110010";
	constant drem  : std_logic_vector(7 downto 0) :="01110011";

	constant ineg  : std_logic_vector(7 downto 0) :="01110100";
	constant lneg  : std_logic_vector(7 downto 0) :="01110101";
	constant fneg  : std_logic_vector(7 downto 0) :="01110110";
	constant dneg  : std_logic_vector(7 downto 0) :="01110111";

	constant ishl  : std_logic_vector(7 downto 0) :="01111000";
	constant lshl  : std_logic_vector(7 downto 0) :="01111001";
	constant ishr  : std_logic_vector(7 downto 0) :="01111010";
	constant lshr  : std_logic_vector(7 downto 0) :="01111011";

	constant iushr : std_logic_vector(7 downto 0) :="01111100";
	constant lushr : std_logic_vector(7 downto 0) :="01111101";
	constant iand  : std_logic_vector(7 downto 0) :="01111110";
	constant land  : std_logic_vector(7 downto 0) :="01111111";

	constant ior   : std_logic_vector(7 downto 0) :="10000000";
	constant lor   : std_logic_vector(7 downto 0) :="10000001";
	constant ixor  : std_logic_vector(7 downto 0) :="10000010";
	constant lxor  : std_logic_vector(7 downto 0) :="10000011";

	constant iinc  : std_logic_vector(7 downto 0) :="10000100";
	constant i2l   : std_logic_vector(7 downto 0) :="10000101";
	constant i2f   : std_logic_vector(7 downto 0) :="10000110";
	constant i2d   : std_logic_vector(7 downto 0) :="10000111";

	constant l2i   : std_logic_vector(7 downto 0) :="10001000";
	constant l2f   : std_logic_vector(7 downto 0) :="10001001";
	constant l2d   : std_logic_vector(7 downto 0) :="10001010";
	constant f2i   : std_logic_vector(7 downto 0) :="10001011";

	constant f2l   : std_logic_vector(7 downto 0) :="10001100";
	constant f2d   : std_logic_vector(7 downto 0) :="10001101";
	constant d2i   : std_logic_vector(7 downto 0) :="10001110";
	constant d2l   : std_logic_vector(7 downto 0) :="10001111";

	constant d2f   : std_logic_vector(7 downto 0) :="10010000";
	constant i2b   : std_logic_vector(7 downto 0) :="10010001";
	constant i2c   : std_logic_vector(7 downto 0) :="10010010";
	constant i2s   : std_logic_vector(7 downto 0) :="10010011";

	constant lcmp  : std_logic_vector(7 downto 0) :="10010100";
	constant fcmpl : std_logic_vector(7 downto 0) :="10010101";
	constant fcmpg : std_logic_vector(7 downto 0) :="10010110";
	constant dcmpl : std_logic_vector(7 downto 0) :="10010111";

	constant dcmpg : std_logic_vector(7 downto 0) :="10011000";
	constant ifeq  : std_logic_vector(7 downto 0) :="10011001";
	constant ifne  : std_logic_vector(7 downto 0) :="10011010";
	constant iflt  : std_logic_vector(7 downto 0) :="10011011";

	constant ifge  : std_logic_vector(7 downto 0) :="10011100";
	constant ifgt  : std_logic_vector(7 downto 0) :="10011101";
	constant ifle  : std_logic_vector(7 downto 0) :="10011110";
	constant if_icmpeq : std_logic_vector(7 downto 0) :="10011111";

	constant if_icmpne : std_logic_vector(7 downto 0) :="10100000";
	constant if_icmplt : std_logic_vector(7 downto 0) :="10100001";
	constant if_icmpge : std_logic_vector(7 downto 0) :="10100010";
	constant if_icmpgt : std_logic_vector(7 downto 0) :="10100011";

	constant if_icmple : std_logic_vector(7 downto 0) :="10100100";
	constant if_acmpeq : std_logic_vector(7 downto 0) :="10100101";
	constant if_acmpne : std_logic_vector(7 downto 0) :="10100110";
	constant goto      : std_logic_vector(7 downto 0) :="10100111";

	constant jsr       : std_logic_vector(7 downto 0) :="10101000";
	constant ret       : std_logic_vector(7 downto 0) :="10101001";
	constant tableswitch : std_logic_vector(7 downto 0) :="10101010";
	constant lookupswitch  : std_logic_vector(7 downto 0) :="10101011";

	constant ireturn   : std_logic_vector(7 downto 0) :="10101100";
	constant lreturn   : std_logic_vector(7 downto 0) :="10101101";
	constant freturn   : std_logic_vector(7 downto 0) :="10101110";
	constant dreturn   : std_logic_vector(7 downto 0) :="10101111";

	constant areturn   : std_logic_vector(7 downto 0) :="10110000";
	constant jreturn    : std_logic_vector(7 downto 0) :="10110001";
	constant getstatic : std_logic_vector(7 downto 0) :="10110010";
	constant putstatic : std_logic_vector(7 downto 0) :="10110011";

	constant getfield  : std_logic_vector(7 downto 0) :="10110100";
	constant putfield  : std_logic_vector(7 downto 0) :="10110101";
	constant invokevirtual : std_logic_vector(7 downto 0) :="10110110";
	constant invokespecial : std_logic_vector(7 downto 0) :="10110111";

	constant invokestatic  : std_logic_vector(7 downto 0) :="10111000";
	constant invokeinterface : std_logic_vector(7 downto 0) :="10111001";
	constant invokedynamic : std_logic_vector(7 downto 0) :="10111010";
	constant jnew        : std_logic_vector(7 downto 0) :="10111011";

	constant newarray   : std_logic_vector(7 downto 0) :="10111100";
	constant anewarray  : std_logic_vector(7 downto 0) :="10111101";
	constant arraylength: std_logic_vector(7 downto 0) :="10111110";
	constant athrow     : std_logic_vector(7 downto 0) :="10111111";

	constant checkcast  : std_logic_vector(7 downto 0) :="11000000";
	constant instanceof : std_logic_vector(7 downto 0) :="11000001";
	constant monitorenter : std_logic_vector(7 downto 0) :="11000010";
	constant monitorexit  : std_logic_vector(7 downto 0) :="11000011";

	constant wide       : std_logic_vector(7 downto 0) :="11000100";
	constant multianewarray : std_logic_vector(7 downto 0) :="11000101";
	constant ifnull     : std_logic_vector(7 downto 0) :="11000110";
	constant ifnonnull  : std_logic_vector(7 downto 0) :="11000111";

	constant goto_w     : std_logic_vector(7 downto 0) :="11001000";
	constant jsr_w      : std_logic_vector(7 downto 0) :="11001001";
	constant donext     : std_logic_vector(7 downto 0) :="11001010";
	constant ldi        : std_logic_vector(7 downto 0) :="11001011";

	constant popr       : std_logic_vector(7 downto 0) :="11001100";
	constant pushr      : std_logic_vector(7 downto 0) :="11001101";
	constant dupr       : std_logic_vector(7 downto 0) :="11001110";
	constant ext        : std_logic_vector(7 downto 0) :="11001111";

	constant get        : std_logic_vector(7 downto 0) :="11010000";
	constant put        : std_logic_vector(7 downto 0) :="11010001";

	constant zeros      : std_logic_vector(23 downto 0) :=(others => '0');
begin
	ram_memory_inst : ram_memory PORT MAP (
		address	 => addr_o(12 downto 0),
		clock	 => not clk,
		data	 => data_o,
		wren	 => write,
		q	 	 => data_i
	);
	idiv_inst : idiv PORT MAP (
		denom	 => t,
		numer	 => s,
		quotient	 => quotient,
		remain	 => remain
	);
	imult_inst : imult PORT MAP (
		dataa	 => t,
		datab	 => s,
		result	 => product
	);
	isht_inst : isht PORT MAP (
		data	 => s,
		direction	 => right_shift,
		distance	 => t(4 downto 0),
		result	 => isht_o
	);
	iushiftr_inst : iushiftr PORT MAP (
		data	 => a,
		distance	 => t(4 downto 0),
		result	 => iushr_o
	);
	data_i_o <= data_i ;
	data_o_o <= data_o ;
	addr_o_o <= addr_o ;
	write_o  <= write ;
	t_o      <= t ;
	p_o      <= p ;
	a_o      <= a ;
	phase_o  <= phase ;
	sp_o     <= sp ;
	rp_o     <= rp ;
	data_o <= t(7 downto  0) when (data_sel = 3)  
		else t(15 downto  8) when (data_sel = 2) 
		else t(23 downto 16) when (data_sel = 1) 
		else t(31 downto 24) when (data_sel = 0) ;
	addr_o   <= a when (addr_sel = '1') else p ;
	icode    <= code ;
	s        <= s_stack(conv_integer(sp));
	r        <= r_stack(conv_integer(rp));
	t_z      <= '1' when (t = 0) else '0' ;
	r_z      <= '1' when (r = 0) else '0' ;

  -- sequential assignments, with phase and code
  decode: process(code,a,t_z,r_z,t,r,s,p,phase,data_i,r_stack,rp,s_stack,sp,
				  product,quotient,remain,isht_o,iushr_o) 
	begin
		aload     <= '0';
		tload     <= '0'; 
		sload     <= '0'; 
		spush     <= '0'; 
		spopp     <= '0';
		rload     <= '0'; 
		rpush     <= '0'; 
		rpopp     <= '0'; 
		pload     <= '1';
		p_in      <= p + 1 ;
		addrload  <= '1';
		addr_in   <= '0';
		dataload  <= '0'; 
		data_in   <=  3 ; 
		phaseload <= '0'; 
		phase_in  <=  0 ; 
		codeload  <= '1'; 
		code_in   <= data_i ; 
		write     <= '0'; 
		right_shift<= '0'; 
		t_in <= (others => '0');
		a_in <= (others => '0');
		r_in <= (others => '0');
		inload    <= '0'; 
		outload   <= '0'; 

	case code is
        when nop         => phaseload <= '1' ; phase_in <= 0 ; 
        when aconst_null => t_in <= (others => '0') ; tload <= '1' ; spush <= '1' ;
        when iconst_m1   => t_in <= (others => '1') ; tload <= '1' ; spush <= '1' ;
        when iconst_0    => t_in <= (others => '0') ; tload <= '1' ; spush <= '1' ;
        when iconst_1    => t_in <= zeros & "00000001"  ; tload <= '1' ; spush <= '1' ;
        when iconst_2    => t_in <= zeros & "00000010"  ; tload <= '1' ; spush <= '1' ;
        when iconst_3    => t_in <= zeros & "00000011"  ; tload <= '1' ; spush <= '1' ;
        when iconst_4    => t_in <= zeros & "00000100"  ; tload <= '1' ; spush <= '1' ;
        when iconst_5    => t_in <= zeros & "00000101"  ; tload <= '1' ; spush <= '1' ;
        when bipush =>
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= zeros & data_i ; tload <= '1' ; spush <= '1' ;
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
        when sipush =>
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= zeros & data_i ; tload <= '1' ; spush <= '1' ;
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ; 
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
		when iload =>
			t_in <= r_stack(conv_integer(rp - data_i)) ; tload <= '1' ;
			p_in <= p + 1 ;  spush <= '1' ;
		when iload_0 =>
			t_in <= r_stack(conv_integer(rp)) ; tload <= '1' ;
			spush <= '1' ;
		when iload_1 =>
			t_in <= r_stack(conv_integer(rp - 1)) ; tload <= '1' ;
			spush <= '1' ;
		when iload_2 =>
			t_in <= r_stack(conv_integer(rp - 2)) ; tload <= '1' ;
			spush <= '1' ;
		when iload_3 =>
			t_in <= r_stack(conv_integer(rp - 3)) ; tload <= '1' ;
			spush <= '1' ;
		when iaload =>
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= t ; aload <= '1' ; addr_in <= '1' ;
					codeload <= '0' ; pload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					a_in <= a + 1 ; aload <= '1' ; addr_in <= '1' ;
					t_in <= zeros & data_i ; tload <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 2 => phaseload <= '1' ; phase_in <= 3 ; 
					a_in <= a + 1 ; aload <= '1' ; addr_in <= '1' ;
					t_in <= t(23 downto 0) & data_i ; tload <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 3 => phaseload <= '1' ; phase_in <= 4 ; 
					a_in <= a + 1 ; aload <= '1' ; addr_in <= '1' ;
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 4 => phaseload <= '1' ; phase_in <= 5 ; 
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
			end case ;
		when baload =>
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= t ; aload <= '1' ; addr_in <= '1' ;
					codeload <= '0' ; p_in <= p - 1 ; pload <= '1' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ; 
					t_in <= zeros & data_i ; tload <= '1' ; 
					code_in <= nop ; codeload <= '1' ; pload <= '1' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ; 
			end case ;
		when saload =>
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= t ; aload <= '1' ; addr_in <= '1' ;
					codeload <= '0' ; pload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					a_in <= a + 1 ; aload <= '1' ; addr_in <= '1' ;
					t_in <= zeros & data_i ; tload <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 2 => phaseload <= '1' ; phase_in <= 3 ; 
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
			end case ;
--		when istore =>
--			case phase is
--				when 0 => phaseload <= '1' ; phase_in <= 1 ;
--					a_in <= sp - t ; aload <= '1' ; 
--					t_in <= s ; tload <= '1' ; spopp <= '1' ;
--					codeload <= '0' ; pload <= '0' ; 
--				when others => phaseload <= '1' ; phase_in <= 0 ;
--					rloada <= '1' ;
--					t_in <= s ; tload <= '1' ; spopp <= '1' ;
--			end case ;
		when istore_0 =>
			r_in <= t ; rload <= '1' ;
			t_in <= s ; tload <= '1' ; spopp <= '1' ;
--		when istore_1 =>
--			r_in <= t ; rloada <= '1' ;
--			t_in <= s ; tload <= '1' ; spopp <= '1' ;
--		when istore_2 =>
--			r_stack(conv_integer(rp - 2)) <= t ; rload <= '1' ;
--			spush <= '1' ;
--		when istore_3 =>
--			r_stack(conv_integer(rp - 3)) <= t ; rload <= '1' ;
--			spush <= '1' ;
		when iastore =>
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= s ; aload <= '1' ; addr_in <= '1' ; spopp <= '1' ;
					dataload <= '1' ; data_in <= 0 ; 
					codeload <= '0' ; pload <= '0' ;
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					a_in <= a + 1   ; aload <= '1' ; addr_in <= '1' ; 
					dataload <= '1' ; data_in <= 1 ; write <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 2 => phaseload <= '1' ; phase_in <= 3 ;
					a_in <= a + 1   ; aload <= '1' ; addr_in <= '1' ; 
					dataload <= '1' ; data_in <= 2 ; write <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 3 => phaseload <= '1' ; phase_in <= 4 ;
					a_in <= a + 1   ; aload <= '1' ; addr_in <= '1' ; 
					dataload <= '1' ; data_in <= 3 ; write <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when 4 => phaseload <= '1' ; phase_in <= 5 ;
					a_in <= a + 1   ; aload <= '1' ; 
					dataload <= '1' ; data_in <= 3 ; write <= '1' ; 
					t_in <= s ; tload <= '1' ; spopp <= '1' ;
					codeload <= '0' ; pload <= '0' ;
					p_in <= p ;
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
		when bastore =>
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= s ; aload <= '1' ; addr_in <= '1' ; spopp <= '1' ;
					codeload <= '0' ; p_in <= p - 1 ; pload <= '1' ;
				when others => phaseload <= '1' ; phase_in <= 0 ;
					t_in <= s ; tload <= '1' ; spopp <= '1' ;
					code_in <= nop ; codeload <= '1' ; pload <= '1' ;
					dataload <= '1' ; write <= '1' ; addr_in <= '0' ;  
			end case ;
		when sastore =>
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= s ; aload <= '1' ; addr_in <= '1' ; spopp <= '1' ;
					codeload <= '0' ; pload <= '0' ;
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					a_in <= a + 1 ; aload <= '1' ; addr_in <= '1' ; 
					dataload <= '1' ; data_in <= 2 ; write <= '1' ; 
					codeload <= '0' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ;
					t_in <= s ; tload <= '1' ; spopp <= '1' ;
					dataload <= '1' ; write <= '1' ; addr_in <= '1' ; 
					code_in <= nop ; codeload <= '1' ; pload <= '0' ;
			end case ;
		when pop => 
			t_in <= s ; tload <= '1' ; spopp <= '1' ;
		when pop2 => 
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= s ; tload <= '1' ; spopp <= '1' ;
					codeload <= '0' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1' ;
			end case ;
		when dup =>  
			spush <= '1';
		when dup_x1 => 
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= s ; aload <= '1' ;
					codeload <= '0' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= a ; spush <= '1' ; tload <= '1' ;
			end case ;
		when dup_x2 => 
			t_in <= s_stack(conv_integer(sp - 1)) ; spush <= '1' ; tload <= '1' ; 
		when dup2 =>  
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= s ; aload <= '1' ;
					codeload <= '0' ; pload <= '0' ;
				when 1 => phaseload <= '1' ; phase_in <= 2 ; 
					t_in <= a ; spush <= '1' ; tload <= '1' ;
					codeload <= '0' ; pload <= '0' ;
				when 2 => phaseload <= '1' ; phase_in <= 3 ;
					a_in <= s ; aload <= '1' ;
					codeload <= '0' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= a ; spush <= '1' ; tload <= '1' ;
			end case ;
		when swap => 
			t_in <= s ; tload <= '1' ; sload <= '1' ; 
		when iadd => 
			t_in <= s + t ; tload <= '1' ; spopp <= '1' ;
		when isub => 
			t_in <= s - t ; tload <= '1' ; spopp <= '1' ;
		when imul => 
			t_in <= product(width downto 0) ; tload <= '1' ; spopp <= '1' ;
		when idivv => 
			t_in <= quotient ; tload <= '1' ; spopp <= '1' ;
		when irem => 
			t_in <= remain ; tload <= '1' ; spopp <= '1' ;
		when ineg => 
			t_in <= 0 - t ; tload <= '1' ; spopp <= '1' ;
		when ishl =>
			t_in <= isht_o ; tload <= '1'; spopp <= '1' ;
		when ishr => right_shift <= '1' ; 
			t_in <= isht_o ; tload <= '1'; spopp <= '1' ;
		when iushr => 
			t_in <= iushr_o ; tload <= '1'; spopp <= '1' ;
		when iand => 
			t_in <= s and t ; tload <= '1'; spopp <= '1' ;
		when ior => 
			t_in <= s or t ; tload <= '1'; spopp <= '1' ;
		when ixor => 
			t_in <= s xor t ; tload <= '1'; spopp <= '1' ;
		when iinc => 
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= s ; aload <= '1' ; addrload <= '1' ; addr_in <= '1' ;
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					t_in <= t + data_i ; sload <= '1' ; addrload <= '1' ; addr_in <= '1' ;
					spopp <= '1' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ;
					t_in <= s ; tload <= '1' ;
					dataload <= '1' ; data_in <= 0 ; write <= '1' ; 
					addrload <= '1' ; pload <= '0' ;
			end case ;
		when ifeq => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t_z = '1' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when ifne => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t_z = '0' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when iflt => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t(31) = '1' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when ifge => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t(31) = '0' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when ifgt => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if (t(31)='0') and (t_z='0') then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when ifle => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if (t(31)='1') or (t_z='1') then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when if_icmpeq => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= s - t ; tload <= '1' ; spopp <= '1' ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t_z = '1' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when if_icmpne => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= s - t ; tload <= '1' ; spopp <= '1' ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t_z = '0' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when if_icmplt => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= s - t ; tload <= '1' ; spopp <= '1' ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if t(31) = '1' then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when if_icmpgt => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					t_in <= s - t ; tload <= '1' ; spopp <= '1' ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					codeload <= '0' ; 
					if (t(31)='0') and (t_z='0') then
						p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					end if ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					t_in <= s ; tload <= '1' ; spopp <= '1'; 
			end case ;
		when goto => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					p_in <= a(23 downto 0 ) & data_i ; 
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
		when jsr => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= t ; aload <= '1' ; addrload <= '1' ; addr_in <= '1' ;
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					a_in <= a + 1 ; aload <= '1' ; addrload <= '1' ; addr_in <= '1' ; 
					t_in <= zeros & data_i ; tload <= '1' ; pload <= '0' ;
				when others => phaseload <= '1' ; phase_in <= 0 ; 
					p_in <= t(23 downto 0 ) & data_i ; 
					t_in <= p + 2 ; tload <= '1' ; spush <= '1' ;
			end case ;
		when ret =>
			p_in <= r ;
		when jreturn =>
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					p_in <= r ; rpopp <= '1' ;
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
		when invokevirtual => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					r_in <= p + 2 ; rpush <= '1' ; 
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					p_in <= a(23 downto 0 ) & data_i ; aload <= '1' ;
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
		when donext => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= zeros & data_i ; aload <= '1' ; 
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ;
					if r_z = '1' then
						rpopp <= '1' ;
					else
						r_in <= r - 1 ; rload <= '1' ;
						p_in <= a(23 downto 0 ) & data_i ;
					end if ;
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
			end case ;
		when ldi =>
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <=1 ; 
					t_in <= zeros & data_i ; tload <= '1' ; spush <= '1' ;
					codeload <= '0' ; 
				when 1 => phaseload <= '1' ; phase_in <= 2 ; 
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ;
					codeload <= '0' ; 
				when 2 => phaseload <= '1' ; phase_in <= 3 ; 
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ;
					codeload <= '0' ; 
				when 3 => phaseload <= '1' ; phase_in <= 4 ; 
					t_in <= t(23 downto 0 ) & data_i ; tload <= '1' ;
					codeload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ; 
			end case ;
		when popr => 
			t_in <= r ; tload <= '1' ; spush <= '1' ; rpopp <= '1' ;
		when pushr => 
			t_in <= s ; tload <= '1'; spopp <= '1';
			r_in <= t ;  rpush <= '1';
		when dupr => 
			t_in <= r ; tload <= '1'; spush <= '1';
		when get => 
			case phase is
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= inptr ; aload <= '1' ; addr_in <= '1' ;
					codeload <= '0' ; pload <= '0' ; spush <= '1' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
					t_in <= zeros & data_i ; tload <= '1' ; 
					code_in <= nop ; codeload <= '1' ; pload <= '0' ; 
					inload <= '1' ;
			end case ;
		when put => 
			case phase is 
				when 0 => phaseload <= '1' ; phase_in <= 1 ;
					a_in <= outptr ; aload <= '1' ; addr_in <= '1' ;
					data_in <= 3 ; dataload <= '1' ; 
					codeload <= '0' ; pload <= '0' ; 
				when others => phaseload <= '1' ; phase_in <= 0 ;
					t_in <= s ; tload <= '1'; spopp <= '1' ;
					data_in <= 3 ; dataload <= '1' ; write <= '1' ; 
					code_in <= nop ; codeload <= '1' ; pload <= '0' ; 
					outload <= '1' ;
			end case ;
        when others => phase_in <= 0 ; 
	end case;
	end process decode;

-- finite state machine, processor control unit	
	sync: process(clk,clr) begin
		if clr = '1' then -- master reset
			phase    <= 0;
			addr_sel <= '0' ;
			data_sel <= 3 ; 
			sp  <= "00000";
			sp1 <= "00001";
			rp  <= "000000";
			rp4 <= "000100";
			inptr  <= "00000000000000000001000000000000" ;
			outptr <= "00000000000000000001010000000000" ;
			t   <= (others => '0');
			a   <= (others => '0');
			p   <= (others => '0');
			code<= (others => '0');
			for ii in s_stack'range loop
				s_stack(ii) <= (others => '0');
			end loop;
			for ii in r_stack'range loop
				r_stack(ii) <= (others => '0');
			end loop;
		elsif (clk'event and clk = '1') then
			if pload = '1' then
				p <= p_in ; 
			end if;
			if aload = '1' then
				a <= a_in;
			end if;
			if codeload = '1' then
				code <= code_in ;
			end if;
			if phaseload = '1' then
				phase <= phase_in ; 
			end if;
			if addrload = '1' then
				addr_sel <= addr_in ; 
			end if;
			if dataload = '1' then
				data_sel <= data_in ; 
			end if;
			if tload = '1' then
				t <= t_in;
			end if;
			if sload = '1' then
				s_stack(conv_integer(sp)) <= t;
			end if;
			if spush = '1' then
				s_stack(conv_integer(sp1)) <= t;
				sp <= sp + 1;
				sp1 <= sp1 + 1;
			end if;
			if spopp = '1' then
				sp <= sp - 1;
				sp1 <= sp1 - 1;
			end if;
			if rload = '1' then
				r_stack(conv_integer(rp)) <= r_in;
			end if;
			if rpush = '1' then
				r_stack(conv_integer(rp4)) <= r_in;
				rp <= rp + 4;
				rp4 <= rp4 + 4;
			end if;
			if rpopp = '1' then
				rp <= rp - 4;
				rp4 <= rp4 - 4;
			end if;
			if inload = '1' then
				inptr <= inptr + 1 ;
			end if;
			if outload = '1' then
				outptr <= outptr + 1 ;
			end if;
		end if;
	end process sync;

end behavioral;
