library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_SIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;
library work ;
use work.frame_type.all ;

entity Mode_decoder is
port (
      CLK_50MHz_I       : IN STD_LOGIC;
      CLK_5MHz_I        : IN STD_LOGIC;
      CLK_10MHZ_I       : IN STD_LOGIC;
      SYS_RESET_I       : IN STD_LOGIC;
     --- PRT               : IN STD_LOGIC;
     -- SOB               : IN STD_LOGIC;
      RX_FRAME          : IN frame_50word_8bit;
      FLAG_FRAME        : IN STD_LOGIC;
    
      CMD_TYPE_NOP      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
      STATUS_TYPE       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
      FLASH_CMD         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      FLASH_INPUT_FRAME : OUT frame_10word_8bit; 

      SCLK_ADAR1_O      : OUT  std_logic;
      CSB_ADAR1_O      : OUT  std_logic;
      SDO_ADAR1_I       : IN  std_logic;
      SDIO_ADAR1_IO     : OUT  std_logic;  
      SCLK_ADAR2_O      : OUT  std_logic;
      CSB_ADAR2_O       : OUT  std_logic;
      SDO_ADAR2_I       : IN  std_logic;
      SDIO_ADAR2_IO     : OUT  std_logic; 


	  FPGA_TR_ADAR1      : OUT STD_LOGIC ;
	  FPGA_TR_ADAR2      : OUT STD_LOGIC ;
	  FPGA_TX_LOAD_ADAR1 : OUT STD_LOGIC ;
	  FPGA_RX_LOAD_ADAR1 : OUT STD_LOGIC ;
	  FPGA_TX_LOAD_ADAR2 : OUT STD_LOGIC ;
	  FPGA_RX_LOAD_ADAR2 : OUT STD_LOGIC ;
     
    --------------------------dc_dc_enable to test-----------------------
    FPGA_SPI_BUFF_CTRL_G1_1  : out std_logic ;
    FPGA_SPI_BUFF_CTRL_G2_1  :out std_logic;

    DC_DC_Control_Buffer_1 : out std_logic;
    BUFF_ENABLE_TX_TR_SW_1    : OUT  STD_LOGIC ;
    FPGA_EN_n5V_DC_DC7149_1    : OUT  STD_LOGIC  ;
    FPGA_TX_EN_G1_G2_1         : out std_logic   ;

    TR_SW_G1_1                 : out std_logic   ;
    TR_SW_G2_1                 : out std_logic   ;

    FPGA_EN_28NV_DC_DC7149_1   : out std_logic ;
    FPGA_3_3v_1                  :out std_logic; 
    
    PA_ON_1_1                  : out std_logic ;
    PA_ON_2_1                  : out std_logic ;
    
    FPGA_RX_EN_G1_G2_1         : OUT STD_LOGIC;
    
    RX_EN_ADAR_1_1             : OUT STD_LOGIC;     -- TO ENABLE RX OF  FIRST ADAR OF FIRST GROUP
    RX_EN_ADAR_2_1             : OUT STD_LOGIC;
    RX_EN_ADAR_5_1             : OUT STD_LOGIC;
    RX_EN_ADAR_6_1             : OUT STD_LOGIC
 
);
end Mode_decoder;


architecture architecture_Mode_decoder of Mode_decoder is
component spi_wrap is  
	port (
			----reset			:in		std_logic := '1';
			reset			:in		std_logic:='1' ;
			CLK_50MHz_I				:in		std_logic;	---50mhz		
				
			data_frame_in	:in		frame_70word_24bit;-- :=(x"800001" ,x"800002" ,x"000003" ,x"800004" ,x"800005" ) ;--frame_70word_24bit;
			word_count		:in		integer range 0 to 128 ;
			data_in_flag	:in		std_logic ;
			
			data_frame_out	:out	frame_70word_8bit;--frame_10word_8bit;
			data_frame_o_v  :out  	std_logic;
			busy_flag		:out  	std_logic;
----------spi--------------------------------------------------------
			sdo      		:in	STD_LOGIC ;-----spi sdo line
	        sdio     		:out	STD_LOGIC ;----spi sdio line
            sclk            :out	STD_LOGIC ;
            cs              :out	STD_LOGIC 			
   );
end component;

TYPE ARRAY_PHASE IS ARRAY (0 TO 127 , 0 TO 1) OF STD_LOGIC_VECTOR (7 DOWNTO 0) ;
SIGNAL PHASE_DATA          : ARRAY_PHASE     := (
(x"3F", x"20"),(x"3F", x"21"),(x"3F", x"23"),(x"3F", x"24"),(x"3F", x"26"),(x"3E", x"27"),(x"3E", x"28"),(x"3D", x"2A"),
(x"3D", x"2B"),(x"3C", x"2D"),(x"3C", x"2E"),(x"3B", x"2F"),(x"3A", x"30"),(x"33", x"31"),(x"38", x"33"),(x"37", x"34"),
(x"36", x"35"),(x"35", x"36"),(x"34", x"37"),(x"33", x"38"),(x"32", x"38"),(x"30", x"39"),(x"2F", x"3A"),(x"2E", x"3A"),
(x"2C", x"3B"),(x"2B", x"3C"),(x"2A", x"3C"),(x"28", x"3C"),(x"27", x"3D"),(x"25", x"3D"),(x"24", x"3D"),(x"22", x"3D"),
(x"21", x"3D"),(x"01", x"3D"),(x"03", x"3D"),(x"04", x"3D"),(x"06", x"3D"),(x"07", x"3C"),(x"08", x"3C"),(x"0A", x"3C"),
(x"0B", x"3B"),(x"0D", x"3A"),(x"0E", x"3A"),(x"0F", x"39"),(x"11", x"38"),(x"12", x"38"),(x"13", x"37"),(x"14", x"36"),
(x"16", x"35"),(x"17", x"34"),(x"18", x"33"),(x"19", x"31"),(x"19", x"30"),(x"1A", x"2F"),(x"1B", x"2E"),(x"1C", x"2D"),
(x"1C", x"2B"),(x"1D", x"2A"),(x"1E", x"28"),(x"1E", x"27"),(x"1E", x"26"),(x"1F", x"24"),(x"1F", x"23"),(x"1F", x"21"),
(x"1F", x"20"),(x"1F", x"01"),(x"1F", x"03"),(x"1F", x"04"),(x"1F", x"06"),(x"1E", x"07"),(x"1E", x"08"),(x"1D", x"0A"),
(x"1D", x"0B"),(x"1C", x"0D"),(x"1C", x"0E"),(x"1B", x"0F"),(x"1A", x"10"),(x"19", x"11"),(x"18", x"13"),(x"17", x"14"),
(x"16", x"15"),(x"15", x"16"),(x"14", x"17"),(x"13", x"18"),(x"12", x"10"),(x"10", x"19"),(x"0F", x"1A"),(x"0E", x"1A"),
(x"0C", x"1B"),(x"0B", x"1C"),(x"0A", x"1C"),(x"08", x"1C"),(x"07", x"1D"),(x"05", x"1D"),(x"04", x"1D"),(x"02", x"1D"),
(x"01", x"1D"),(x"21", x"1D"),(x"23", x"1D"),(x"24", x"1D"),(x"26", x"1D"),(x"27", x"1C"),(x"28", x"1C"),(x"2A", x"1C"),
(x"2B", x"1B"),(x"2D", x"1A"),(x"2E", x"1A"),(x"2F", x"19"),(x"31", x"18"),(x"32", x"18"),(x"33", x"17"),(x"34", x"16"),
(x"36", x"15"),(x"37", x"14"),(x"38", x"13"),(x"39", x"11"),(x"39", x"10"),(x"3A", x"0F"),(x"3B", x"0E"),(x"3C", x"0D"),
(x"3C", x"0B"),(x"3D", x"0A"),(x"3E", x"08"),(x"3E", x"07"),(x"3E", x"06"),(x"3F", x"04"),(x"3F", x"03"),(x"3F", x"01"));

TYPE ATTEN_ARRAY IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR (7 DOWNTO 0) ;
SIGNAL ATTEN_DATA_RX  : ATTEN_ARRAY     := (
(X"FF"),(X"FC"),(X"F8"),(X"F3"),(X"EE"),(X"E8"),(X"E3"),(X"DD"),
(X"D7"),(X"D0"),(X"CA"),(X"C4"),(X"BE"),(X"B8"),(X"B4"),(X"B0"),
(X"AC"),(X"A8"),(X"A4"),(X"A2"),(X"9E"),(X"9C"),(X"99"),(X"97"),
(X"95"),(X"93"),(X"91"),(X"90"),(X"8E"),(X"8D"),(X"8B"),(X"7F"),
(X"7C"),(X"77"),(X"73"),(X"6D"),(X"68"),(X"62"),(X"5D"),(X"57"),
(X"50"),(X"4A"),(X"44"),(X"3D"),(X"3A"),(X"33"),(X"2F"),(X"2C"),
(X"28"),(X"25"),(X"22"),(X"1F"),(X"1C"),(X"19"),(X"17"),(X"15"),
(X"13"),(X"12"),(X"10"),(X"0E"),(X"0C"),(X"0B"),(X"0A"),(X"09"));
SIGNAL ATTEN_DATA_TX  : ATTEN_ARRAY     := (
(x"FF"),(x"F6"),(x"EE"),(x"E9"),(x"E3"),(x"DD"),(x"D9"),(x"D4"),
(x"CE"),(x"CA"),(x"C5"),(x"C1"),(x"BD"),(x"B9"),(x"B5"),(x"B2"),
(x"AF"),(x"AC"),(x"A9"),(x"A7"),(x"A4"),(x"A2"),(x"A0"),(x"9E"),
(x"9C"),(x"9B"),(x"99"),(x"97"),(x"96"),(x"95"),(x"94"),(x"7F"),
(x"75"),(x"6E"),(x"68"),(x"63"),(x"5D"),(x"58"),(x"53"),(x"4E"),
(x"49"),(x"45"),(x"41"),(x"3D"),(x"39"),(x"35"),(x"32"),(x"2F"),
(x"2C"),(x"29"),(x"27"),(x"24"),(x"22"),(x"20"),(x"1E"),(x"1C"),
(x"1A"),(x"19"),(x"17"),(x"16"),(x"15"),(x"13"),(x"12"),(x"11"));

SIGNAL CMD_TYPE              : STD_LOGIC_VECTOR (7 DOWNTO 0) ;
SIGNAL CHANNEL_SEL           : STD_LOGIC_VECTOR (7 DOWNTO 0) := X"00" ;
signal clk_10mhz, clk_50mhz, clk_5mhz : std_logic;
signal por_rst : std_logic;
signal por_rst_cnt : std_logic_vector(15 downto 0) := (others => '0');
signal word_count :integer range 0 to 128:= 11;
signal data_frame_in :	frame_70word_24bit;
signal data_frame_out_1,data_frame_out_2 :	frame_70word_8bit;
signal data_frame_o_v_1,data_frame_o_v_2  :  	std_logic;
signal busy_flag_1,busy_flag_2		:  	std_logic;

signal adar_rst_cnt  : std_logic_vector (27 downto 0) := (others => '0') ;
signal data_adar_flag : std_logic ;
--
--signal pw_i : std_logic_vector(19 downto 0) := x"00FA0";  --400u        commented by tharun 
--signal pri_i : std_logic_vector(19 downto 0) := x"13880";  --1000us
--signal prt_cnt : std_logic_vector(19 downto 0) := x"00000";  --1000us
--signal int_trp : std_logic := '0';



signal pw_i : std_logic_vector(19 downto 0) := x"003E8";  --1000 
signal pri_i : std_logic_vector(19 downto 0) := x"04E20"; --20000        
signal prt_cnt : std_logic_vector(19 downto 0) := x"00000";  
signal int_trp : std_logic := '0';
--signal por_rst : std_logic;
--signal por_rst_cnt : std_logic_vector(23 downto 0) := (others => '0');

SIGNAL CH1_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_ATTN_TX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_ATTN_TX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_ATTN_TX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_PHASE_TX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_PHASE_TX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH2_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH3_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH4_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH5_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH6_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH7_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;
SIGNAL CH8_PHASE_TX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0)  := "000000" ;

SIGNAL CH1_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_PHASE_RX          : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_PHASE_RX_CURRENT  : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_PHASE_RX_NEXT     : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_ATTN_RX           : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_ATTN_RX_CURRENT   : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL CH1_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH2_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH3_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH4_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH5_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH6_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH7_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;
SIGNAL CH8_ATTN_RX_NEXT      : STD_LOGIC_VECTOR (5 DOWNTO 0) := "000000" ;

SIGNAL TX_ATTN_DATA_CH1      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH2      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH3      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH4      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH5      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH6      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH7      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_ATTN_DATA_CH8      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');

SIGNAL TX_PHASEI_CH1         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH2         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH3         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH4         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH5         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH6         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH7         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEI_CH8         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
							 
SIGNAL TX_PHASEQ_CH1         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH2         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH3         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH4         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH5         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH6         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH7         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL TX_PHASEQ_CH8         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
							 							 
SIGNAL RX_ATTN_DATA_CH1      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH2      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH3      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH4      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH5      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH6      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH7      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_ATTN_DATA_CH8      : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');

SIGNAL RX_PHASEI_CH1         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH2         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH3         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH4         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH5         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH6         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH7         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEI_CH8         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
							 
SIGNAL RX_PHASEQ_CH1         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH2         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH3         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH4         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH5         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH6         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH7         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');
SIGNAL RX_PHASEQ_CH8         : STD_LOGIC_VECTOR (7 DOWNTO 0)     := (OTHERS => '0');

SIGNAL S_DATA                : frame_127word_24bit ;
-----------------------------SPI_SIGNAL---------------------
signal	ready_flag_adar1_s	    :STD_LOGIC :='0';
signal	ready_flag_adar2_s	    :STD_LOGIC :='0';
signal 	data_frame_in_adar1_s	:frame_70word_24bit;
signal 	data_frame_in_adar2_s	:frame_70word_24bit;
signal	word_count_adar1_s		:integer range 0 to 127:=0;
signal	word_count_adar2_s		:integer range 0 to 127:=0;
signal	data_in_flag_adar1_s	:STD_LOGIC :='0';
signal	data_in_flag_adar2_s    :STD_LOGIC :='0';
signal	data_in_flag	    	:STD_LOGIC :='0';
signal 	data_frame_out_adar1_s	:frame_16word_8bit;
signal 	data_frame_out_adar2_s	:frame_16word_8bit;
signal 	data_frame_out			:frame_16word_8bit;
signal	data_out_flag_adar1_s	:STD_LOGIC :='0';
signal	data_out_flag_adar2_s	:STD_LOGIC :='0';
signal	busy_flag_adar1_s	    :STD_LOGIC :='0';
signal	busy_flag_adar2_s	    :STD_LOGIC :='0';
signal	busy_flag_adar1_s1	    :STD_LOGIC :='0';
signal	busy_flag_adar1_s2	    :STD_LOGIC :='0';
signal	busy_flag_adar1_s3	    :STD_LOGIC :='0';
signal	busy_flag_adar1_s4	    :STD_LOGIC :='0';
signal	busy_flag_adar2_s1	    :STD_LOGIC :='0';
signal	busy_flag_adar2_s2      :STD_LOGIC :='0';
signal	busy_flag_adar2_s3	    :STD_LOGIC :='0';
signal	busy_flag_adar2_s4	    :STD_LOGIC :='0';
signal	busy_flag_adar1_pe	    :STD_LOGIC :='0';
signal	busy_flag_adar1_ne	    :STD_LOGIC :='0';
signal	busy_flag_adar2_pe	    :STD_LOGIC :='0';
signal	busy_flag_adar2_ne	    :STD_LOGIC :='0';
signal	adar1_spi_flag	        :STD_LOGIC :='0';
signal	adar2_spi_flag	        :STD_LOGIC :='0';
signal	CMD_TYPE_S	            :STD_LOGIC_VECTOR(7 DOWNTO 0);-- :=0x"00";
signal	CMD_TYPE_NOP_S	        :STD_LOGIC_VECTOR(7 DOWNTO 0);-- :=0x"00";
signal	STATUS_TYPE_S	        :STD_LOGIC_VECTOR(3 DOWNTO 0) :=x"0";
type	state_type	is	(s_ideal,s1,s2,s3,s4);
signal	state_1,state_2	        :state_type;
signal	FLASH_INPUT_FRAME_S	        :frame_10word_8bit;
signal	FLASH_CMD_S	        : STD_LOGIC_VECTOR (7 DOWNTO 0):=x"00";
--
constant CH01_RX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"0010";
constant CH02_RX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"0011";	
constant CH03_RX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"0012";	
constant CH04_RX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"0013";
	
constant CH01_RX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0014";
constant CH01_RX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0015";
constant CH02_RX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0016";
constant CH02_RX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0017";
constant CH03_RX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0018";
constant CH03_RX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0019";
constant CH04_RX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"001a";
constant CH04_RX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"001b";

constant CH01_TX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"001c";
constant CH02_TX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"001d";	
constant CH03_TX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"001e";	
constant CH04_TX_GAIN_ADDR		: std_logic_vector(15 downto 0) := x"001f";

constant CH01_TX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0020";
constant CH01_TX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0021";
constant CH02_TX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0022";
constant CH02_TX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0023";
constant CH03_TX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0024";
constant CH03_TX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0025";
constant CH04_TX_PHASE_I_ADDR	: std_logic_vector(15 downto 0) := x"0026";
constant CH04_TX_PHASE_Q_ADDR	: std_logic_vector(15 downto 0) := x"0027";

BEGIN 
adar1_spi_ctrl_inst: spi_wrap 
	port map(
			reset			=> SYS_RESET_I,
			CLK_50MHz_I		=> CLK_50MHz_I,
				
			data_frame_in	=> data_frame_in_adar1_s,
			word_count		=> word_count_adar1_s,
			data_in_flag	=> data_adar_flag,
			                   
			data_frame_out	=> data_frame_out_1,
			data_frame_o_v  => data_frame_o_v_1,
			busy_flag		=> busy_flag_1,

			sdo      		=> SDO_ADAR1_I,
	        sdio     		=> SDIO_ADAR1_IO,
            sclk            => SCLK_ADAR1_O,
            cs              => CSB_ADAR1_O
   );

adar2_spi_ctrl_inst: spi_wrap 
	port map(
			reset			=> SYS_RESET_I,
			CLK_50MHz_I		=> CLK_50MHz_I,
				
			data_frame_in	=> data_frame_in_adar2_s,
			word_count		=> word_count_adar2_s,
			data_in_flag	=> data_adar_flag, 
			data_frame_out	=> data_frame_out_2,
			data_frame_o_v  => data_frame_o_v_2,
			busy_flag		=> busy_flag_2,

			sdo      		=> SDO_ADAR2_I,
	        sdio     		=> SDIO_ADAR2_IO,
            sclk            => SCLK_ADAR2_O,
            cs              => CSB_ADAR2_O
   );


--process(CLK_5MHz_I) begin               --- commented by tharun
    --if rising_edge(CLK_5MHz_I) then
        --if adar_rst_cnt >= x"2faf080" then
            --adar_rst_cnt <= (others => '0'); 
        --else
            --adar_rst_cnt <= adar_rst_cnt + '1';
        --end if;
--
  --
        --if adar_rst_cnt = x"00000ff" then
            --data_adar_flag <= '1';
        --else
             --data_adar_flag <= '0';                    
        --end if;
--
--end if;
--end process;


process(CLK_5MHz_I) begin
    if rising_edge(CLK_5MHz_I) then
        if por_rst_cnt > x"7A120" then
            por_rst <= '0';
        else
             por_rst <= '1';           
             por_rst_cnt <= por_rst_cnt + '1';           
        end if;
end if;
end process;




process(CLK_50MHz_I) begin
    if por_rst = '1' then
       adar_rst_cnt <= (others => '0');
       data_adar_flag <= '0';
    elsif rising_edge(CLK_50MHz_I) then
        if adar_rst_cnt >= x"04C4B40" then
            --adar_rst_cnt <= (others => '0'); 
            adar_rst_cnt <= x"04C4B40";
        else
            adar_rst_cnt <= adar_rst_cnt + '1';
        end if;

        if adar_rst_cnt = x"00000ff" then   --04C4B3F --000C350
            data_adar_flag <= '1';
        else
             data_adar_flag <= '0';                    
        end if;
    end if;
end process;


CMD_TYPE_S       <= RX_FRAME  (2) (7 DOWNTO 0) WHEN FLAG_FRAME = '1' ;
CHANNEL_SEL      <= RX_FRAME  (5) (7 DOWNTO 0) WHEN FLAG_FRAME = '1' ;
CMD_TYPE_NOP     <= CMD_TYPE_NOP_S ;
STATUS_TYPE      <= STATUS_TYPE_S ;
FLASH_CMD       <=FLASH_CMD_S;
FLASH_INPUT_FRAME<=FLASH_INPUT_FRAME_S;




------------------------------OPERATIONAl AND NON OPERATIONAL COMMAND IDENTIFICATION-----------------
PROCESS (CLK_50MHz_I , SYS_RESET_I , CMD_TYPE_S) 
BEGIN 
IF (SYS_RESET_I = '1') THEN
        CMD_TYPE <=X"00";
        CMD_TYPE_NOP_s <=X"00";
---ELSIF (CLK_50MHz_I 'EVENT AND CLK_50MHz_I = '1') THEN
ELSE

        IF (CMD_TYPE_S = X"01" OR CMD_TYPE_S = X"02"  OR CMD_TYPE_S = X"03" OR CMD_TYPE_S = X"04" OR CMD_TYPE_S = X"05" OR CMD_TYPE_S = X"06" OR CMD_TYPE_S = X"07" ) THEN
            CMD_TYPE <=CMD_TYPE_S;    
        ELSIF(CMD_TYPE_S = X"08"  ) THEN
            CMD_TYPE_NOP_S <=CMD_TYPE_S;
            STATUS_TYPE_S<= RX_FRAME  (5) (3 DOWNTO 0) ;
       ELSIF(CMD_TYPE_S = X"0A"  ) THEN
            FLASH_CMD_S <=CMD_TYPE_S;
            
            FOR I IN 0 TO 9 LOOP
            FLASH_INPUT_FRAME_S(I)<= RX_FRAME(I); 
            END LOOP;
                   
        ELSE
             CMD_TYPE_NOP_S <=CMD_TYPE_NOP_S;
             STATUS_TYPE_S <=STATUS_TYPE_S;
        END IF;
END IF;
END PROCESS;


--------------------------------------------------------------------------------------------------
-------------------receiving uart frame to current(for calibration) and next(for dwell) regester---
-------------------also to current register on reception of SOB SIGNAL(FOR DWELL)-------------------
PROCESS (CLK_50MHz_I , SYS_RESET_I , CMD_TYPE ) 
BEGIN 
   IF (SYS_RESET_I = '1') THEN
           CH1_PHASE_RX_NEXT    	<= "000000" ;	CH2_PHASE_RX_NEXT    	<= "000000" ;	CH3_PHASE_RX_NEXT    	<= "000000" ;	CH4_PHASE_RX_NEXT    	<= "000000" ;
           CH5_PHASE_RX_NEXT    	<= "000000" ;	CH6_PHASE_RX_NEXT    	<= "000000" ;	CH7_PHASE_RX_NEXT    	<= "000000" ; 	CH8_PHASE_RX_NEXT    	<= "000000" ;
           CH1_PHASE_RX_CURRENT  	<= "000000" ;   CH2_PHASE_RX_CURRENT  	<= "000000" ;   CH3_PHASE_RX_CURRENT  	<= "000000" ;   CH4_PHASE_RX_CURRENT  	<= "000000" ;
           CH5_PHASE_RX_CURRENT  	<= "000000" ;   CH6_PHASE_RX_CURRENT  	<= "000000" ;   CH7_PHASE_RX_CURRENT  	<= "000000" ;   CH8_PHASE_RX_CURRENT  	<= "000000" ;
           CH1_PHASE_TX_NEXT     	<= "000000" ;   CH2_PHASE_TX_NEXT     	<= "000000" ;   CH3_PHASE_TX_NEXT     	<= "000000" ;   CH4_PHASE_TX_NEXT     	<= "000000" ;   
           CH5_PHASE_TX_NEXT     	<= "000000" ;   CH6_PHASE_TX_NEXT     	<= "000000" ;   CH7_PHASE_TX_NEXT     	<= "000000" ;   CH8_PHASE_TX_NEXT     	<= "000000" ; 
           CH1_PHASE_TX_CURRENT  	<= "000000" ;   CH2_PHASE_TX_CURRENT  	<= "000000" ;   CH3_PHASE_TX_CURRENT  	<= "000000" ;   CH4_PHASE_TX_CURRENT  	<= "000000" ;  
           CH5_PHASE_TX_CURRENT  	<= "000000" ;   CH6_PHASE_TX_CURRENT  	<= "000000" ;   CH7_PHASE_TX_CURRENT  	<= "000000" ;   CH8_PHASE_TX_CURRENT  	<= "000000" ;  
           CH1_ATTN_RX_CURRENT   	<= "111111" ;	CH2_ATTN_RX_CURRENT   	<= "111111" ;	CH3_ATTN_RX_CURRENT   	<= "111111" ;	CH4_ATTN_RX_CURRENT   	<= "111111" ;
           CH5_ATTN_RX_CURRENT   	<= "111111" ;	CH6_ATTN_RX_CURRENT   	<= "111111" ;	CH7_ATTN_RX_CURRENT   	<= "111111" ;	CH8_ATTN_RX_CURRENT   	<= "111111" ;
           CH1_ATTN_RX_NEXT      	<= "111111" ;	CH2_ATTN_RX_NEXT      	<= "111111" ;	CH3_ATTN_RX_NEXT      	<= "111111" ;	CH4_ATTN_RX_NEXT      	<= "111111" ;
           CH5_ATTN_RX_NEXT      	<= "111111" ;	CH6_ATTN_RX_NEXT      	<= "111111" ;	CH7_ATTN_RX_NEXT      	<= "111111" ;	CH8_ATTN_RX_NEXT      	<= "111111" ;
           CH1_ATTN_TX_CURRENT   	<= "111111" ;	CH2_ATTN_TX_CURRENT   	<= "111111" ;	CH3_ATTN_TX_CURRENT   	<= "111111" ;	CH4_ATTN_TX_CURRENT   	<= "111111" ;
           CH5_ATTN_TX_CURRENT   	<= "111111" ;	CH6_ATTN_TX_CURRENT   	<= "111111" ;	CH7_ATTN_TX_CURRENT   	<= "111111" ;	CH8_ATTN_TX_CURRENT   	<= "111111" ;
           CH1_ATTN_TX_NEXT      	<= "111111" ;	CH2_ATTN_TX_NEXT      	<= "111111" ;	CH3_ATTN_TX_NEXT      	<= "111111" ;	CH4_ATTN_TX_NEXT      	<= "111111" ;
           CH5_ATTN_TX_NEXT      	<= "111111" ;	CH6_ATTN_TX_NEXT      	<= "111111" ;	CH7_ATTN_TX_NEXT      	<= "111111" ;	CH8_ATTN_TX_NEXT      	<= "111111" ;

  ELSIF (CLK_50MHz_I 'EVENT AND CLK_50MHz_I = '1') THEN
   IF (FLAG_FRAME = '1') THEN
      IF (CMD_TYPE = X"01") THEN                 -- DWELL MODE
      
        CH1_PHASE_TX_NEXT  <= RX_FRAME (10) (5 DOWNTO 0) ;
        CH2_PHASE_TX_NEXT  <= RX_FRAME (15) (5 DOWNTO 0) ;
        CH3_PHASE_TX_NEXT  <= RX_FRAME (20) (5 DOWNTO 0) ;
        CH4_PHASE_TX_NEXT  <= RX_FRAME (25) (5 DOWNTO 0) ;
        CH5_PHASE_TX_NEXT  <= RX_FRAME (30) (5 DOWNTO 0) ;
        CH6_PHASE_TX_NEXT  <= RX_FRAME (35) (5 DOWNTO 0) ;
        CH7_PHASE_TX_NEXT  <= RX_FRAME (40) (5 DOWNTO 0) ;
        CH8_PHASE_TX_NEXT  <= RX_FRAME (45) (5 DOWNTO 0) ;

        CH1_ATTN_TX_NEXT   <= RX_FRAME (11) (5 DOWNTO 0) ;
        CH2_ATTN_TX_NEXT   <= RX_FRAME (16) (5 DOWNTO 0) ;
        CH3_ATTN_TX_NEXT   <= RX_FRAME (21) (5 DOWNTO 0) ;
        CH4_ATTN_TX_NEXT   <= RX_FRAME (26) (5 DOWNTO 0) ;
        CH5_ATTN_TX_NEXT   <= RX_FRAME (31) (5 DOWNTO 0) ;
        CH6_ATTN_TX_NEXT   <= RX_FRAME (36) (5 DOWNTO 0) ;
        CH7_ATTN_TX_NEXT   <= RX_FRAME (41) (5 DOWNTO 0) ;
        CH8_ATTN_TX_NEXT   <= RX_FRAME (46) (5 DOWNTO 0) ;
      
        CH1_PHASE_RX_NEXT  <= RX_FRAME (12) (5 DOWNTO 0) ;
        CH2_PHASE_RX_NEXT  <= RX_FRAME (17) (5 DOWNTO 0) ;
        CH3_PHASE_RX_NEXT  <= RX_FRAME (22) (5 DOWNTO 0) ;
        CH4_PHASE_RX_NEXT  <= RX_FRAME (27) (5 DOWNTO 0) ;
        CH5_PHASE_RX_NEXT  <= RX_FRAME (32) (5 DOWNTO 0) ;
        CH6_PHASE_RX_NEXT  <= RX_FRAME (37) (5 DOWNTO 0) ;
        CH7_PHASE_RX_NEXT  <= RX_FRAME (42) (5 DOWNTO 0) ;
        CH8_PHASE_RX_NEXT  <= RX_FRAME (47) (5 DOWNTO 0) ;
        
        CH1_ATTN_RX_NEXT   <= RX_FRAME (13) (5 DOWNTO 0) ;
        CH2_ATTN_RX_NEXT   <= RX_FRAME (18) (5 DOWNTO 0) ;
        CH3_ATTN_RX_NEXT   <= RX_FRAME (23) (5 DOWNTO 0) ;
        CH4_ATTN_RX_NEXT   <= RX_FRAME (28) (5 DOWNTO 0) ;
        CH5_ATTN_RX_NEXT   <= RX_FRAME (33) (5 DOWNTO 0) ;
        CH6_ATTN_RX_NEXT   <= RX_FRAME (38) (5 DOWNTO 0) ;
        CH7_ATTN_RX_NEXT   <= RX_FRAME (43) (5 DOWNTO 0) ;
        CH8_ATTN_RX_NEXT   <= RX_FRAME (48) (5 DOWNTO 0) ;
                
  ELSIF (CMD_TYPE = X"02" ) THEN               --RX CALIBRATION
  
        IF (CHANNEL_SEL  = "00000000") THEN
				CH6_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH6_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE
				CH6_PHASE_RX_CURRENT <= "000000" ;
				CH6_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000001") THEN
				CH5_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH5_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH5_PHASE_RX_CURRENT <= "000000" ;
				CH5_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000010") THEN
				CH8_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH8_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH8_PHASE_RX_CURRENT <= "000000" ;
				CH8_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000011") THEN
				CH7_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH7_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH7_PHASE_RX_CURRENT <= "000000" ;
				CH7_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000100") THEN
				CH2_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH2_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH2_PHASE_RX_CURRENT <= "000000" ;
				CH2_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000101") THEN
				CH1_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH1_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH1_PHASE_RX_CURRENT <= "000000" ;
				CH1_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000110") THEN
				CH4_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH4_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH4_PHASE_RX_CURRENT <= "000000" ;
				CH4_ATTN_RX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000111") THEN
				CH3_PHASE_RX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH3_ATTN_RX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH3_PHASE_RX_CURRENT <= "000000" ;
				CH3_ATTN_RX_CURRENT  <= "111111" ;
		END IF;

        CH1_PHASE_TX_CURRENT <= "000000" ; 
        CH2_PHASE_TX_CURRENT <= "000000" ; 
        CH3_PHASE_TX_CURRENT <= "000000" ; 
        CH4_PHASE_TX_CURRENT <= "000000" ; 
        CH5_PHASE_TX_CURRENT <= "000000" ; 
        CH6_PHASE_TX_CURRENT <= "000000" ; 
        CH7_PHASE_TX_CURRENT <= "000000" ; 
        CH8_PHASE_TX_CURRENT <= "000000" ;
        
        CH1_ATTN_TX_CURRENT  <= "111111" ;
        CH2_ATTN_TX_CURRENT  <= "111111" ;
        CH3_ATTN_TX_CURRENT  <= "111111" ;
        CH4_ATTN_TX_CURRENT  <= "111111" ;
        CH5_ATTN_TX_CURRENT  <= "111111" ;
        CH6_ATTN_TX_CURRENT  <= "111111" ;
        CH7_ATTN_TX_CURRENT  <= "111111" ;
        CH8_ATTN_TX_CURRENT  <= "111111" ;
 
  ELSIF (CMD_TYPE = X"03") THEN       -- TX CALIBRATION
  
  		 IF (CHANNEL_SEL  = "00000000") THEN
				CH6_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH6_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE
				CH6_PHASE_TX_CURRENT <= "000000" ;
				CH6_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000001") THEN
				CH5_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH5_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH5_PHASE_TX_CURRENT <= "000000" ;
				CH5_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000010") THEN
				CH8_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH8_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH8_PHASE_TX_CURRENT <= "000000" ;
				CH8_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000011") THEN
				CH7_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH7_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH7_PHASE_TX_CURRENT <= "000000" ;
				CH7_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000100") THEN
				CH2_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH2_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH2_PHASE_TX_CURRENT <= "000000" ;
				CH2_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000101") THEN
				CH1_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH1_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH1_PHASE_TX_CURRENT <= "000000" ;
				CH1_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000110") THEN
				CH4_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH4_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH4_PHASE_TX_CURRENT <= "000000" ;
				CH4_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
		IF (CHANNEL_SEL  = "00000111") THEN
				CH3_PHASE_TX_CURRENT <= RX_FRAME (6) (5 DOWNTO 0) ;
				CH3_ATTN_TX_CURRENT  <= RX_FRAME (7) (5 DOWNTO 0) ;
		ELSE      
				CH3_PHASE_TX_CURRENT <= "000000" ;
				CH3_ATTN_TX_CURRENT  <= "111111" ;
		END IF;
        CH1_ATTN_RX_CURRENT  <= "111111" ;
        CH2_ATTN_RX_CURRENT  <= "111111" ;
        CH3_ATTN_RX_CURRENT  <= "111111" ;
        CH4_ATTN_RX_CURRENT  <= "111111" ;
        CH5_ATTN_RX_CURRENT  <= "111111" ;
        CH6_ATTN_RX_CURRENT  <= "111111" ;
        CH7_ATTN_RX_CURRENT  <= "111111" ;
        CH8_ATTN_RX_CURRENT  <= "111111" ;
        CH1_PHASE_RX_CURRENT  <= "000000" ;
        CH2_PHASE_RX_CURRENT  <= "000000" ;
        CH3_PHASE_RX_CURRENT  <= "000000" ;
        CH4_PHASE_RX_CURRENT  <= "000000" ;
        CH5_PHASE_RX_CURRENT  <= "000000" ;
        CH6_PHASE_RX_CURRENT  <= "000000" ;
        CH7_PHASE_RX_CURRENT  <= "000000" ;
        CH8_PHASE_RX_CURRENT  <= "000000" ;                        
    END IF ;
  END IF ; 
--IF (SOB = '1' AND CMD_TYPE = X"01") THEN                      -- DWELL MODE
     if (CMD_TYPE =X"01")THEN
        CH1_ATTN_TX_CURRENT   <= CH1_ATTN_TX_NEXT ;
        CH2_ATTN_TX_CURRENT   <= CH2_ATTN_TX_NEXT ;
        CH3_ATTN_TX_CURRENT   <= CH3_ATTN_TX_NEXT ;
        CH4_ATTN_TX_CURRENT   <= CH4_ATTN_TX_NEXT ;
        CH5_ATTN_TX_CURRENT   <= CH5_ATTN_TX_NEXT ;
        CH6_ATTN_TX_CURRENT   <= CH6_ATTN_TX_NEXT ;
        CH7_ATTN_TX_CURRENT   <= CH7_ATTN_TX_NEXT ;
        CH8_ATTN_TX_CURRENT   <= CH8_ATTN_TX_NEXT ;
        CH1_PHASE_TX_CURRENT  <= CH1_PHASE_TX_NEXT ;
        CH2_PHASE_TX_CURRENT  <= CH2_PHASE_TX_NEXT ;
        CH3_PHASE_TX_CURRENT  <= CH3_PHASE_TX_NEXT ;
        CH4_PHASE_TX_CURRENT  <= CH4_PHASE_TX_NEXT ;
        CH5_PHASE_TX_CURRENT  <= CH5_PHASE_TX_NEXT ;
        CH6_PHASE_TX_CURRENT  <= CH6_PHASE_TX_NEXT ;
        CH7_PHASE_TX_CURRENT  <= CH7_PHASE_TX_NEXT ;
        CH8_PHASE_TX_CURRENT  <= CH8_PHASE_TX_NEXT ;

        CH1_ATTN_RX_CURRENT   <= CH1_ATTN_RX_NEXT ;
        CH2_ATTN_RX_CURRENT   <= CH2_ATTN_RX_NEXT ;
        CH3_ATTN_RX_CURRENT   <= CH3_ATTN_RX_NEXT ;
        CH4_ATTN_RX_CURRENT   <= CH4_ATTN_RX_NEXT ;
        CH5_ATTN_RX_CURRENT   <= CH5_ATTN_RX_NEXT ;
        CH6_ATTN_RX_CURRENT   <= CH6_ATTN_RX_NEXT ;
        CH7_ATTN_RX_CURRENT   <= CH7_ATTN_RX_NEXT ;
        CH8_ATTN_RX_CURRENT   <= CH8_ATTN_RX_NEXT ;
        CH1_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH2_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH3_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH4_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH5_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH6_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH7_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
        CH8_PHASE_RX_CURRENT  <= CH1_PHASE_RX_NEXT ;
      
END IF;
END IF;
END PROCESS ;
----------------------------------------------------------------------------------------------------------
-----TX_RX-------PHASE_I,PHASE_Q AND ATTENUATION DATA MAPPING  --------------------------------------------
PROCESS(CLK_50MHz_I, SYS_RESET_I)
BEGIN

    IF (SYS_RESET_I = '1') THEN

        TX_ATTN_DATA_CH1    <= X"00";
        TX_ATTN_DATA_CH2    <= X"00";
        TX_ATTN_DATA_CH3    <= X"00";
        TX_ATTN_DATA_CH4    <= X"00";
        TX_ATTN_DATA_CH5    <= X"00";
        TX_ATTN_DATA_CH6    <= X"00";
        TX_ATTN_DATA_CH7    <= X"00";
        TX_ATTN_DATA_CH8    <= X"00";

        TX_PHASEI_CH1       <= X"00";
        TX_PHASEI_CH2       <= X"00";
        TX_PHASEI_CH3       <= X"00";
        TX_PHASEI_CH4       <= X"00";
        TX_PHASEI_CH5       <= X"00";
        TX_PHASEI_CH6       <= X"00";
        TX_PHASEI_CH7       <= X"00";
        TX_PHASEI_CH8       <= X"00";

        TX_PHASEQ_CH1       <= X"00";
        TX_PHASEQ_CH2       <= X"00";
        TX_PHASEQ_CH3       <= X"00";
        TX_PHASEQ_CH4       <= X"00";
        TX_PHASEQ_CH5       <= X"00";
        TX_PHASEQ_CH6       <= X"00";
        TX_PHASEQ_CH7       <= X"00";
        TX_PHASEQ_CH8       <= X"00";

        RX_ATTN_DATA_CH1    <= X"00";
        RX_ATTN_DATA_CH2    <= X"00";
        RX_ATTN_DATA_CH3    <= X"00";
        RX_ATTN_DATA_CH4    <= X"00";
        RX_ATTN_DATA_CH5    <= X"00";
        RX_ATTN_DATA_CH6    <= X"00";
        RX_ATTN_DATA_CH7    <= X"00";
        RX_ATTN_DATA_CH8    <= X"00";

        RX_PHASEI_CH1       <= X"00";
        RX_PHASEI_CH2       <= X"00";
        RX_PHASEI_CH3       <= X"00";
        RX_PHASEI_CH4       <= X"00";
        RX_PHASEI_CH5       <= X"00";
        RX_PHASEI_CH6       <= X"00";
        RX_PHASEI_CH7       <= X"00";
        RX_PHASEI_CH8       <= X"00";
                     
        RX_PHASEQ_CH1       <= X"00";
        RX_PHASEQ_CH2       <= X"00";
        RX_PHASEQ_CH3       <= X"00";
        RX_PHASEQ_CH4       <= X"00";
        RX_PHASEQ_CH5       <= X"00";
        RX_PHASEQ_CH6       <= X"00";
        RX_PHASEQ_CH7       <= X"00";
        RX_PHASEQ_CH8       <= X"00";

    ELSIF RISING_EDGE (CLK_50MHz_I) THEN

        TX_ATTN_DATA_CH1    <= ATTEN_DATA_TX (to_integer(unsigned(CH1_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH2    <= ATTEN_DATA_TX (to_integer(unsigned(CH2_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH3    <= ATTEN_DATA_TX (to_integer(unsigned(CH3_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH4    <= ATTEN_DATA_TX (to_integer(unsigned(CH4_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH5    <= ATTEN_DATA_TX (to_integer(unsigned(CH5_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH6    <= ATTEN_DATA_TX (to_integer(unsigned(CH6_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH7    <= ATTEN_DATA_TX (to_integer(unsigned(CH7_ATTN_TX_CURRENT)));
        TX_ATTN_DATA_CH8    <= ATTEN_DATA_TX (to_integer(unsigned(CH8_ATTN_TX_CURRENT)));
 
        TX_PHASEI_CH1       <= PHASE_DATA ((to_integer(unsigned(CH1_PHASE_TX_CURRENT))), 0);
        TX_PHASEI_CH2       <= PHASE_DATA ((to_integer(unsigned(CH2_PHASE_TX_CURRENT))), 0); 
        TX_PHASEI_CH3       <= PHASE_DATA ((to_integer(unsigned(CH3_PHASE_TX_CURRENT))), 0); 
        TX_PHASEI_CH4       <= PHASE_DATA ((to_integer(unsigned(CH4_PHASE_TX_CURRENT))), 0); 
        TX_PHASEI_CH5       <= PHASE_DATA ((to_integer(unsigned(CH5_PHASE_TX_CURRENT))), 0); 
        TX_PHASEI_CH6       <= PHASE_DATA ((to_integer(unsigned(CH6_PHASE_TX_CURRENT))), 0); 
        TX_PHASEI_CH7       <= PHASE_DATA ((to_integer(unsigned(CH7_PHASE_TX_CURRENT))), 0); 
        TX_PHASEI_CH8       <= PHASE_DATA ((to_integer(unsigned(CH8_PHASE_TX_CURRENT))), 0);

        TX_PHASEQ_CH1       <= PHASE_DATA ((to_integer(unsigned(CH1_PHASE_TX_CURRENT))), 1);
        TX_PHASEQ_CH2       <= PHASE_DATA ((to_integer(unsigned(CH2_PHASE_TX_CURRENT))), 1); 
        TX_PHASEQ_CH3       <= PHASE_DATA ((to_integer(unsigned(CH3_PHASE_TX_CURRENT))), 1); 
        TX_PHASEQ_CH4       <= PHASE_DATA ((to_integer(unsigned(CH4_PHASE_TX_CURRENT))), 1); 
        TX_PHASEQ_CH5       <= PHASE_DATA ((to_integer(unsigned(CH5_PHASE_TX_CURRENT))), 1); 
        TX_PHASEQ_CH6       <= PHASE_DATA ((to_integer(unsigned(CH6_PHASE_TX_CURRENT))), 1); 
        TX_PHASEQ_CH7       <= PHASE_DATA ((to_integer(unsigned(CH7_PHASE_TX_CURRENT))), 1); 
        TX_PHASEQ_CH8       <= PHASE_DATA ((to_integer(unsigned(CH8_PHASE_TX_CURRENT))), 1); 

        RX_ATTN_DATA_CH1    <= ATTEN_DATA_RX (to_integer(unsigned(CH1_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH2    <= ATTEN_DATA_RX (to_integer(unsigned(CH2_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH3    <= ATTEN_DATA_RX (to_integer(unsigned(CH3_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH4    <= ATTEN_DATA_RX (to_integer(unsigned(CH4_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH5    <= ATTEN_DATA_RX (to_integer(unsigned(CH5_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH6    <= ATTEN_DATA_RX (to_integer(unsigned(CH6_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH7    <= ATTEN_DATA_RX (to_integer(unsigned(CH7_ATTN_RX_CURRENT)));
        RX_ATTN_DATA_CH8    <= ATTEN_DATA_RX (to_integer(unsigned(CH8_ATTN_RX_CURRENT)));

        RX_PHASEI_CH1       <= PHASE_DATA ((to_integer(unsigned(CH1_PHASE_RX_CURRENT))), 0);
        RX_PHASEI_CH2       <= PHASE_DATA ((to_integer(unsigned(CH2_PHASE_RX_CURRENT))), 0); 
        RX_PHASEI_CH3       <= PHASE_DATA ((to_integer(unsigned(CH3_PHASE_RX_CURRENT))), 0); 
        RX_PHASEI_CH4       <= PHASE_DATA ((to_integer(unsigned(CH4_PHASE_RX_CURRENT))), 0); 
        RX_PHASEI_CH5       <= PHASE_DATA ((to_integer(unsigned(CH5_PHASE_RX_CURRENT))), 0); 
        RX_PHASEI_CH6       <= PHASE_DATA ((to_integer(unsigned(CH6_PHASE_RX_CURRENT))), 0); 
        RX_PHASEI_CH7       <= PHASE_DATA ((to_integer(unsigned(CH7_PHASE_RX_CURRENT))), 0); 
        RX_PHASEI_CH8       <= PHASE_DATA ((to_integer(unsigned(CH8_PHASE_RX_CURRENT))), 0); 

        RX_PHASEQ_CH1       <= PHASE_DATA ((to_integer(unsigned(CH1_PHASE_RX_CURRENT))), 1);
        RX_PHASEQ_CH2       <= PHASE_DATA ((to_integer(unsigned(CH2_PHASE_RX_CURRENT))), 1); 
        RX_PHASEQ_CH3       <= PHASE_DATA ((to_integer(unsigned(CH3_PHASE_RX_CURRENT))), 1); 
        RX_PHASEQ_CH4       <= PHASE_DATA ((to_integer(unsigned(CH4_PHASE_RX_CURRENT))), 1); 
        RX_PHASEQ_CH5       <= PHASE_DATA ((to_integer(unsigned(CH5_PHASE_RX_CURRENT))), 1); 
        RX_PHASEQ_CH6       <= PHASE_DATA ((to_integer(unsigned(CH6_PHASE_RX_CURRENT))), 1); 
        RX_PHASEQ_CH7       <= PHASE_DATA ((to_integer(unsigned(CH7_PHASE_RX_CURRENT))), 1); 
        RX_PHASEQ_CH8       <= PHASE_DATA ((to_integer(unsigned(CH8_PHASE_RX_CURRENT))), 1); 

    END IF;

END PROCESS;



PROCESS (CLK_50MHz_I , SYS_RESET_I , CMD_TYPE , CHANNEL_SEL , busy_flag_adar1_s,busy_flag_adar2_s,FLAG_FRAME)    
BEGIN
IF (SYS_RESET_I = '1') THEN
    data_frame_in_adar1_s     <= (OTHERS => X"000000") ;
    data_frame_in_adar2_s     <= (OTHERS => X"000000") ;
    --FPGA_LNA_CTRL             <= "00000000" ;
    --FPGA_28PA_CTRL            <= "00000000" ;
    --FPGA_PA_SW_CTRL           <= "00000000" ;
    
ELSIF (CLK_50MHz_I 'EVENT AND CLK_50MHz_I = '1') THEN
 CASE CMD_TYPE IS
  WHEN X"02" =>            -- RX_CALIBRATION    
        
          data_frame_in_adar1_s (0)    <= "0"&"10"&"00"&"000"&x"0081";   
          data_frame_in_adar1_s (1)    <= "0"&"10"&"00"&"000"&x"0018";   
          data_frame_in_adar1_s (2)    <= "0"&"10"&"00"&"100"&x"0055";    
          data_frame_in_adar1_s (3)    <= "0"&"10"&"00"&"000"&x"2E7F";    
          data_frame_in_adar1_s (4)    <= "0"&"10"&"00"&"000"&x"3104";    
          data_frame_in_adar1_s (5)    <= "0"&"10"&"00"&"000"&x"3860";    
          data_frame_in_adar1_s (6)    <= "0"&"10"&"00"&"000"&x"3408";    
          data_frame_in_adar1_s (7)    <= "0"&"10"&"00"&"000"&x"3555";

          data_frame_in_adar1_s (8)    <= "0"&"10"&"00"&"000"&x"10FF";--Address: 0x010, Reset: 0x00, Name: CH1_RX_GAIN        
          data_frame_in_adar1_s (9)    <= "0"&"10"&"00"&"000"&x"11FF";--Address: 0x011, Reset: 0x00, Name: CH2_RX_GAIN
          data_frame_in_adar1_s (10)   <= "0"&"10"&"00"&"000"&x"12FF";--Address: 0x012, Reset: 0x00, Name: CH3_RX_GAIN 
          data_frame_in_adar1_s (11)   <= "0"&"10"&"00"&"000"&x"13FF"; --Address: 0x013, Reset: 0x00, Name: CH4_RX_GAIN 
          data_frame_in_adar1_s (12)   <= "0"&"10"&"00"&"000"&x"143F";--Address: 0x014, Reset: 0x00, Name: CH1_RX_PHASE_I  
          data_frame_in_adar1_s (13)   <= "0"&"10"&"00"&"000"&x"1520";--Address: 0x015, Reset: 0x00, Name: CH1_RX_PHASE_Q  
          data_frame_in_adar1_s (14)   <= "0"&"10"&"00"&"000"&x"163F";--Address: 0x016, Reset: 0x00, Name: CH2_RX_PHASE_I  
          data_frame_in_adar1_s (15)   <= "0"&"10"&"00"&"000"&x"1720";--Address: 0x017, Reset: 0x00, Name: CH2_RX_PHASE_Q  
          data_frame_in_adar1_s (16)   <= "0"&"10"&"00"&"000"&x"183F";--Address: 0x018, Reset: 0x00, Name: CH3_RX_PHASE_I  
          data_frame_in_adar1_s (17)   <= "0"&"10"&"00"&"000"&x"1920";--Address: 0x019, Reset: 0x00, Name: CH3_RX_PHASE_Q
          data_frame_in_adar1_s (18)   <= "0"&"10"&"00"&"000"&x"1A3F";--Address: 0x01A, Reset: 0x00, Name: CH4_RX_PHASE_I
          data_frame_in_adar1_s (19)   <= "0"&"10"&"00"&"000"&x"1B20";--Address: 0x01B, Reset: 0x00, Name: CH4_RX_PHASE_Q
          data_frame_in_adar1_s (20)   <= "0"&"10"&"00"&"000"&x"2DFF";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v) 
          data_frame_in_adar1_s (21)   <= "0"&"10"&"00"&"000"&x"3050";--Address: 0x030, Reset: 0x00, Name: MISC_ENABLES
          data_frame_in_adar1_s (22)   <= "0"&"10"&"00"&"000"&x"4AFF";--Address: 0x04A, Reset: 0x00, Name: LNA_BIAS_OFF







         
         
          data_frame_in_adar2_s (0)   <= "0"&"01"&"00"&"000"&x"0081";   
          data_frame_in_adar2_s (1)   <= "0"&"01"&"00"&"000"&x"0018";   
          data_frame_in_adar2_s (2)   <= "0"&"01"&"00"&"100"&x"0055";   
          data_frame_in_adar2_s (3)   <= "0"&"01"&"00"&"000"&x"2e7f";  
          data_frame_in_adar2_s (4)   <= "0"&"01"&"00"&"000"&x"3104";  
          data_frame_in_adar2_s (5)   <= "0"&"01"&"00"&"000"&x"3860";  
          data_frame_in_adar2_s (6)   <= "0"&"01"&"00"&"000"&x"3408";   
          data_frame_in_adar2_s (7)   <= "0"&"01"&"00"&"000"&x"3555";
    
          data_frame_in_adar2_s (8)   <= "0"&"01"&"00"&"000"&x"10FF";--Address: 0x010, Reset: 0x00, Name: CH1_RX_GAIN        
          data_frame_in_adar2_s (9)   <= "0"&"01"&"00"&"000"&x"11FF";--Address: 0x011, Reset: 0x00, Name: CH2_RX_GAIN
          data_frame_in_adar2_s (10)  <= "0"&"01"&"00"&"000"&x"12FF";--Address: 0x012, Reset: 0x00, Name: CH3_RX_GAIN 
          data_frame_in_adar2_s (11)  <= "0"&"01"&"00"&"000"&x"13FF"; --Address: 0x013, Reset: 0x00, Name: CH4_RX_GAIN 
          data_frame_in_adar2_s (12)  <= "0"&"01"&"00"&"000"&x"143F";--Address: 0x014, Reset: 0x00, Name: CH1_RX_PHASE_I  
          data_frame_in_adar2_s (13)  <= "0"&"01"&"00"&"000"&x"1520";--Address: 0x015, Reset: 0x00, Name: CH1_RX_PHASE_Q  
          data_frame_in_adar2_s (14)  <= "0"&"01"&"00"&"000"&x"163F";--Address: 0x016, Reset: 0x00, Name: CH2_RX_PHASE_I  
          data_frame_in_adar2_s (15)  <= "0"&"01"&"00"&"000"&x"1720";--Address: 0x017, Reset: 0x00, Name: CH2_RX_PHASE_Q  
          data_frame_in_adar2_s (16)  <= "0"&"01"&"00"&"000"&x"183F";--Address: 0x018, Reset: 0x00, Name: CH3_RX_PHASE_I  
          data_frame_in_adar2_s (17)  <= "0"&"01"&"00"&"000"&x"1920";--Address: 0x019, Reset: 0x00, Name: CH3_RX_PHASE_Q
          data_frame_in_adar2_s (18)  <= "0"&"01"&"00"&"000"&x"1A3F";--Address: 0x01A, Reset: 0x00, Name: CH4_RX_PHASE_I
          data_frame_in_adar2_s (19)  <= "0"&"01"&"00"&"000"&x"1B20";--Address: 0x01B, Reset: 0x00, Name: CH4_RX_PHASE_Q
          data_frame_in_adar2_s (20)  <= "0"&"01"&"00"&"000"&x"2DFF";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 (-1.3v)
          data_frame_in_adar2_s (21)  <= "0"&"01"&"00"&"000"&x"3050";--Address: 0x030, Reset: 0x00, Name: MISC_ENABLES
          data_frame_in_adar2_s (22)  <= "0"&"01"&"00"&"000"&x"4AFF";--Address: 0x04A, Reset: 0x00, Name: LNA_BIAS_OFF
          


      
          --
    --IF (CHANNEL_SEL  = x"00") THEN
           --
          ----data_frame_in_adar2_s (8)    <=  CH02_RX_GAIN_ADDR    & RX_ATTN_DATA_CH6 ;
          ----data_frame_in_adar2_s (9)    <=  CH02_RX_PHASE_Q_ADDR & RX_PHASEQ_CH6 ;
          ----data_frame_in_adar2_s (10)    <= CH02_RX_PHASE_I_ADDR & RX_PHASEI_CH6 ;
          --data_frame_in_adar1_s (23)   <= "0"&"10"&"00"&"000"&x"10FF";--Address: 0x010, Reset: 0x00, Name: CH1_RX_GAIN
          --data_frame_in_adar1_s (24)   <= "0"&"10"&"00"&"000"&x"143F";--Address: 0x014, Reset: 0x00, Name: CH1_RX_PHASE_I  
          --data_frame_in_adar1_s (25)   <= "0"&"10"&"00"&"000"&x"1520";--Address: 0x015, Reset: 0x00, Name: CH1_RX_PHASE_Q
          --data_frame_in_adar1_s (26)   <= "0"&"10"&"00"&"000"&x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45-1.3)
          --data_frame_in_adar1_s (27)   <= "0"&"10"&"00"&"000"&x"2801"; 
--
          --word_count_adar2_s<= 42;
          ----FPGA_LNA_CTRL     <= "00100000" ; 
          --FPGA_TR_ADAR1     <= '0' ;
--
          --
    --ELSIF (CHANNEL_SEL  = x"10") THEN
          --
          ----data_frame_in_adar2_s (8)    <= CH01_RX_GAIN_ADDR     & RX_ATTN_DATA_CH5 ;
          ----data_frame_in_adar2_s (9)    <= CH01_RX_PHASE_Q_ADDR  & RX_PHASEQ_CH5 ;
          ----data_frame_in_adar2_s (10)   <= CH01_RX_PHASE_I_ADDR  & RX_PHASEI_CH5 ;
          --data_frame_in_adar1_s (28)    <="0"&"10"&"00"&"000"& x"11FF";--Address: 0x011, Reset: 0x00, Name: CH2_RX_GAIN
          --data_frame_in_adar1_s (29)    <="0"&"10"&"00"&"000"& x"163F";--Address: 0x016, Reset: 0x00, Name: CH2_RX_PHASE_I  
          --data_frame_in_adar1_s (30)    <="0"&"10"&"00"&"000"& x"1720";--Address: 0x017, Reset: 0x00, Name: CH2_RX_PHASE_Q 
          --data_frame_in_adar1_s (31)    <="0"&"10"&"00"&"000"& x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 
          --data_frame_in_adar1_s (32)    <="0"&"10"&"00"&"000"& x"2801";
    --
          --word_count_adar2_s<= 42;
          ----FPGA_LNA_CTRL     <= "00010000" ;
          --FPGA_TR_ADAR1     <= '0' ;
--
    IF (CHANNEL_SEL  = x"01") THEN
          
          --data_frame_in_adar2_s (8)     <= CH04_RX_GAIN_ADDR    & RX_ATTN_DATA_CH8 ;
          --data_frame_in_adar2_s (9)     <= CH04_RX_PHASE_Q_ADDR & RX_PHASEQ_CH8 ;
          --data_frame_in_adar2_s (10)    <= CH04_RX_PHASE_I_ADDR & RX_PHASEI_CH8 ;
          data_frame_in_adar1_s (23)   <="0"&"01"&"00"&"000"& x"12FF";--Address: 0x012, Reset: 0x00, Name: CH3_RX_GAIN
          data_frame_in_adar1_s (24)   <="0"&"01"&"00"&"000"& x"183F";--Address: 0x018, Reset: 0x00, Name: CH3_RX_PHASE_I  
          data_frame_in_adar1_s (25)   <="0"&"01"&"00"&"000"& x"1920";--Address: 0x019, Reset: 0x00, Name: CH3_RX_PHASE_Q
          data_frame_in_adar1_s (26)   <="0"&"01"&"00"&"000"& x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 (-1.3v)
          data_frame_in_adar1_s (27)   <="0"&"01"&"00"&"000"& x"2801";
        
          word_count_adar2_s<= 27;

          --FPGA_LNA_CTRL     <= "10000000" ;
          FPGA_TR_ADAR1     <= '0' ;
--
    --ELSIF (CHANNEL_SEL  = x"11") THEN
         --
          ----data_frame_in_adar2_s (8)     <= CH03_RX_GAIN_ADDR    & RX_ATTN_DATA_CH7 ;
          ----data_frame_in_adar2_s (9)     <= CH03_RX_PHASE_Q_ADDR & RX_PHASEQ_CH7 ;
          ----data_frame_in_adar2_s (10)    <= CH03_RX_PHASE_I_ADDR & RX_PHASEI_CH7 ; 
          --data_frame_in_adar1_s (38)   <= "0"&"11"&"00"&"000"&x"13FF"; --Address: 0x013, Reset: 0x00, Name: CH4_RX_GAIN 
          --data_frame_in_adar1_s (39)   <= "0"&"11"&"00"&"000"&x"1A3F";--Address: 0x01A, Reset: 0x00, Name: CH4_RX_PHASE_I
          --data_frame_in_adar1_s (40)   <= "0"&"11"&"00"&"000"&x"1B20";--Address: 0x01B, Reset: 0x00, Name: CH4_RX_PHASE_Q
          --data_frame_in_adar1_s (41)   <= "0"&"11"&"00"&"000"&x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 (-1.3v)
          --data_frame_in_adar1_s (42)   <= "0"&"11"&"00"&"000"&x"2801";
        --
          --word_count_adar2_s<= 42;
    --
          ----FPGA_LNA_CTRL     <= "01000000" ;
          --FPGA_TR_ADAR1    <= '0' ;
--
     --ELSIF (CHANNEL_SEL  = "00000100") THEN                                     
         --
          ----data_frame_in_adar1_s (8)    <= CH02_RX_GAIN_ADDR     & RX_ATTN_DATA_CH2 ;
          ----data_frame_in_adar1_s (9)    <= CH02_RX_PHASE_Q_ADDR  & RX_PHASEQ_CH2 ;
          ----data_frame_in_adar1_s (10)   <= CH02_RX_PHASE_I_ADDR  & RX_PHASEI_CH2 ;
          --data_frame_in_adar2_s (23)    <="0"&"00"&"00"&"000"&x"10FF";--Address: 0x010, Reset: 0x00, Name: CH1_RX_GAIN
          --data_frame_in_adar2_s (24)    <="0"&"00"&"00"&"000"&x"143F";--Address: 0x014, Reset: 0x00, Name: CH1_RX_PHASE_I  
          --data_frame_in_adar2_s (25)   <="0"&"00"&"00"&"000"&x"1520";--Address: 0x015, Reset: 0x00, Name: CH1_RX_PHASE_Q
          --data_frame_in_adar2_s (26)   <="0"&"00"&"00"&"000"&x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45-1.3)
          --data_frame_in_adar2_s (27)   <= "0"&"00"&"00"&"000"&x"2801"; 
          --word_count_adar2_s<= 42;
          ----FPGA_LNA_CTRL     <= "00000010" ;
          --FPGA_TR_ADAR2     <= '0' ;
--
    --ELSIF (CHANNEL_SEL  = "00000101") THEN                                     
          --
          ----data_frame_in_adar1_s (8)    <= CH01_RX_GAIN_ADDR    & RX_ATTN_DATA_CH1 ;
          ----data_frame_in_adar1_s (9)    <= CH01_RX_PHASE_Q_ADDR & RX_PHASEQ_CH1 ;
          ----data_frame_in_adar1_s (10)   <= CH01_RX_PHASE_I_ADDR & RX_PHASEI_CH1 ;
          --data_frame_in_adar2_s (28)    <="0"&"10"&"00"&"000"& x"11FF";--Address: 0x011, Reset: 0x00, Name: CH2_RX_GAIN
          --data_frame_in_adar2_s (29)    <="0"&"10"&"00"&"000"& x"163F";--Address: 0x016, Reset: 0x00, Name: CH2_RX_PHASE_I  
          --data_frame_in_adar2_s (30)    <="0"&"10"&"00"&"000"& x"1720";--Address: 0x017, Reset: 0x00, Name: CH2_RX_PHASE_Q 
          --data_frame_in_adar2_s (31)    <="0"&"10"&"00"&"000"& x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 
          --data_frame_in_adar2_s (32)    <="0"&"10"&"00"&"000"& x"2801";
--
          --word_count_adar2_s<= 42;
          ----FPGA_LNA_CTRL     <= "00000001" ;
          --FPGA_TR_ADAR2    <= '0' ;
--
    --ELSIF (CHANNEL_SEL  = "00000110") THEN                                   
          --
          ----data_frame_in_adar1_s (8)     <= CH04_RX_GAIN_ADDR     & RX_ATTN_DATA_CH4 ;
          ----data_frame_in_adar1_s (9)     <= CH04_RX_PHASE_Q_ADDR  & RX_PHASEQ_CH4 ;
          ----data_frame_in_adar1_s (10)    <= CH04_RX_PHASE_I_ADDR  & RX_PHASEI_CH4 ;
          --data_frame_in_adar2_s (33)   <="0"&"01"&"00"&"000"& x"12FF";--Address: 0x012, Reset: 0x00, Name: CH3_RX_GAIN
          --data_frame_in_adar2_s (34)   <="0"&"01"&"00"&"000"& x"183F";--Address: 0x018, Reset: 0x00, Name: CH3_RX_PHASE_I  
          --data_frame_in_adar2_s (35)   <="0"&"01"&"00"&"000"& x"1920";--Address: 0x019, Reset: 0x00, Name: CH3_RX_PHASE_Q
          --data_frame_in_adar2_s (36)   <="0"&"01"&"00"&"000"& x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 (-1.3v)
          --data_frame_in_adar2_s (37)   <="0"&"01"&"00"&"000"& x"2801";
          --
--
          --word_count_adar2_s<= 42;
          ----FPGA_LNA_CTRL     <= "00001000" ;
          --FPGA_TR_ADAR2     <= '0' ;
--
    --ELSIF (CHANNEL_SEL  = "00000111") THEN                                   
         --
          ----data_frame_in_adar1_s (8)     <= CH03_RX_GAIN_ADDR    & RX_ATTN_DATA_CH3 ;
          ----data_frame_in_adar1_s (9)     <= CH03_RX_PHASE_Q_ADDR & RX_PHASEQ_CH3 ;
          ----data_frame_in_adar1_s (10)    <= CH03_RX_PHASE_I_ADDR & RX_PHASEI_CH3 ;
          --data_frame_in_adar2_s (38)   <= "0"&"11"&"00"&"000"&x"13FF"; --Address: 0x013, Reset: 0x00, Name: CH4_RX_GAIN 
          --data_frame_in_adar2_s (39)   <= "0"&"11"&"00"&"000"&x"1A3F";--Address: 0x01A, Reset: 0x00, Name: CH4_RX_PHASE_I
          --data_frame_in_adar2_s (40)   <= "0"&"11"&"00"&"000"&x"1B20";--Address: 0x01B, Reset: 0x00, Name: CH4_RX_PHASE_Q
          --data_frame_in_adar2_s (41)   <= "0"&"11"&"00"&"000"&x"2D22";--Address: 0x02D, Reset: 0x00, Name: LNA_BIAS_ON-- BEFORE 2D79 -- 2D3C (-1.1v)  2D45 (-1.3v)
          --data_frame_in_adar1_s (42)   <= "0"&"11"&"00"&"000"&x"2801";
          --
          --word_count_adar2_s<= 42;
          ----FPGA_LNA_CTRL     <= "00000100" ;
          --FPGA_TR_ADAR2     <= '0' ;
    --END IF ;
--
--
--WHEN X"03" =>   
         --data_frame_in_adar1_s (0)    <= X"000081";   
          --data_frame_in_adar1_s (1)   <= X"000018";   
          --data_frame_in_adar1_s (2)   <= X"040055";    
          --data_frame_in_adar1_s (3)   <= X"002F7F";    
          --data_frame_in_adar1_s (4)   <= X"003104";    
          --data_frame_in_adar1_s (5)   <= X"003860";    
          --data_frame_in_adar1_s (6)   <= X"00362D";    
          --data_frame_in_adar1_s (7)   <= X"003706";
--
         --
         --
          --data_frame_in_adar2_s (0)   <= X"000081";   
          --data_frame_in_adar2_s (1)   <= X"000018";   
          --data_frame_in_adar2_s (2)   <= X"040055";   
          --data_frame_in_adar2_s (3)   <= X"002F7F";  
          --data_frame_in_adar2_s (4)   <= X"003104";  
          --data_frame_in_adar2_s (5)   <= X"003860";  
          --data_frame_in_adar2_s (6)   <= X"00362D";   
          --data_frame_in_adar2_s (7)   <= X"003706";
--
     --IF (CHANNEL_SEL  = "00000000") THEN
     --data_frame_in_adar2_s (8)    <=  CH02_TX_GAIN_ADDR    & TX_ATTN_DATA_CH6 ;
          --data_frame_in_adar2_s (9)    <=  CH02_TX_PHASE_Q_ADDR & TX_PHASEQ_CH6 ;
          --data_frame_in_adar2_s (10)   <=  CH02_TX_PHASE_I_ADDR & TX_PHASEI_CH6 ;
          --data_frame_in_adar2_s (11)    <=  x"002802"; 
--
          --word_count_adar2_s  <= 11;
--
          ----FPGA_28PA_CTRL      <= "00100000" ; 
          ----FPGA_PA_SW_CTRL(5)  <= PRT ; 
         ----- FPGA_TR_ADAR2       <= PRT ;-
          --FPGA_TR_ADAR2       <= int_trp ;
--
          --
    --ELSIF (CHANNEL_SEL  = "00000001") THEN
    --
    --
   --
     --
          --
          --data_frame_in_adar2_s (8)    <= CH01_TX_GAIN_ADDR     & TX_ATTN_DATA_CH5 ;
          --data_frame_in_adar2_s (9)    <= CH01_TX_PHASE_Q_ADDR  & TX_PHASEQ_CH5 ;
          --data_frame_in_adar2_s (10)   <= CH01_TX_PHASE_I_ADDR  & TX_PHASEI_CH5 ;
          --data_frame_in_adar2_s (11)    <= x"002802";
    --
          --word_count_adar2_s  <= 11;
----
          ----FPGA_28PA_CTRL      <= "00010000" ;
          ----FPGA_PA_SW_CTRL(4)  <= PRT ;
          --FPGA_TR_ADAR2       <= int_trp ;
--
    --ELSIF (CHANNEL_SEL  = "00000010") THEN
    --
    --
--
     --
          --
          --data_frame_in_adar2_s (8)     <= CH04_TX_GAIN_ADDR    & TX_ATTN_DATA_CH8 ;
          --data_frame_in_adar2_s (9)     <= CH04_TX_PHASE_Q_ADDR & TX_PHASEQ_CH8 ;
          --data_frame_in_adar2_s (10)    <= CH04_TX_PHASE_I_ADDR & TX_PHASEI_CH8 ;
          --data_frame_in_adar2_s (11)    <= x"002802";
        --
          --word_count_adar2_s<= 11;
--
          ----FPGA_28PA_CTRL      <= "10000000" ;
          ----FPGA_PA_SW_CTRL(7)  <= PRT ;
          --FPGA_TR_ADAR2       <= int_trp ;
--
    --ELSIF (CHANNEL_SEL  = "00000011") THEN
   --
         --
          --data_frame_in_adar2_s (8)     <= CH03_TX_GAIN_ADDR    & TX_ATTN_DATA_CH7 ;
          --data_frame_in_adar2_s (9)     <= CH03_TX_PHASE_Q_ADDR & TX_PHASEQ_CH7 ;
          --data_frame_in_adar2_s (10)    <= CH03_TX_PHASE_I_ADDR & TX_PHASEI_CH7 ; 
          --data_frame_in_adar2_s (11)    <= x"002802";
        --
          --word_count_adar2_s<= 11;
    --
          ----FPGA_28PA_CTRL      <= "01000000" ;
          ----FPGA_PA_SW_CTRL(6)  <= PRT ;
          --FPGA_TR_ADAR2       <= int_trp ;
--
     --ELSIF (CHANNEL_SEL  = "00000100") THEN 
--
          --
         --
          --data_frame_in_adar1_s (8)    <= CH02_TX_GAIN_ADDR     & TX_ATTN_DATA_CH2 ;
          --data_frame_in_adar1_s (9)    <= CH02_TX_PHASE_Q_ADDR  & TX_PHASEQ_CH2 ;
          --data_frame_in_adar1_s (10)   <= CH02_TX_PHASE_I_ADDR  & TX_PHASEI_CH2 ;
          --data_frame_in_adar1_s (11)    <= x"002802";
   --
          --word_count_adar1_s<= 11;
          ----FPGA_28PA_CTRL      <= "00000010" ;
          ----FPGA_PA_SW_CTRL(1)  <= PRT;
          --FPGA_TR_ADAR1       <= int_trp ;
--
    --ELSIF (CHANNEL_SEL  = "00000101") THEN      
--
--
          --data_frame_in_adar1_s (8)    <= CH01_TX_GAIN_ADDR    & TX_ATTN_DATA_CH1 ;
          --data_frame_in_adar1_s (9)    <= CH01_TX_PHASE_Q_ADDR & TX_PHASEQ_CH1 ;
          --data_frame_in_adar1_s (10)   <= CH01_TX_PHASE_I_ADDR & TX_PHASEI_CH1 ;
          --data_frame_in_adar1_s (11)    <= x"002802";
--
          --word_count_adar1_s<= 11;
          ----FPGA_28PA_CTRL      <= "00000001" ;
          ----FPGA_PA_SW_CTRL(0)  <= PRT ;
          --FPGA_TR_ADAR1       <= int_trp ;
--
    --ELSIF (CHANNEL_SEL  = "00000110") THEN     
--
          --
          --data_frame_in_adar1_s (8)     <= CH04_TX_GAIN_ADDR     & TX_ATTN_DATA_CH4 ;
          --data_frame_in_adar1_s (9)     <= CH04_TX_PHASE_Q_ADDR  & TX_PHASEQ_CH4 ;
          --data_frame_in_adar1_s (10)    <= CH04_TX_PHASE_I_ADDR  & TX_PHASEI_CH4 ;
          --data_frame_in_adar1_s (11)    <= x"002802";
          --
--
          --word_count_adar1_s  <= 11;
          ----FPGA_28PA_CTRL      <= "00001000" ;
          ----FPGA_PA_SW_CTRL(3)  <= PRT ;
          --FPGA_TR_ADAR1       <= int_trp ;
--
    --ELSIF (CHANNEL_SEL  = "00000111") THEN          
--
--
          --data_frame_in_adar1_s (8)     <= CH03_TX_GAIN_ADDR    & TX_ATTN_DATA_CH3 ;
          --data_frame_in_adar1_s (9)     <= CH03_TX_PHASE_Q_ADDR & TX_PHASEQ_CH3 ;
          --data_frame_in_adar1_s (10)    <= CH03_TX_PHASE_I_ADDR & TX_PHASEI_CH3 ;
          --data_frame_in_adar1_s (11)  <= x"002802";   
          --word_count_adar1_s  <= 11;
          ----FPGA_28PA_CTRL      <= "00000100" ;
          ----FPGA_PA_SW_CTRL(2)  <= PRT ;
          --FPGA_TR_ADAR1       <= int_trp ;
    END IF ;
--
--WHEN X"04" =>       --RX ISOLATION
--
          --data_frame_in_adar1_s     <= (others => x"000000");
          --data_frame_in_adar2_s     <= (others => x"000000");
          ----FPGA_LNA_CTRL             <= "00000000" ;
--
--WHEN X"05" =>       -- TX ISOLATION
--
          --data_frame_in_adar1_s     <= (others => x"000000");
          --data_frame_in_adar2_s     <= (others => x"000000");
          ----FPGA_28PA_CTRL    <= "00000000" ;
          ----FPGA_PA_SW_CTRL   <= "00000000" ;
          

WHEN OTHERS =>
          data_frame_in_adar1_s      <= (others =>x"000000");
          data_frame_in_adar2_s      <= (others =>x"000000");
          --FPGA_LNA_CTRL     <= "00000000" ;
          --FPGA_28PA_CTRL    <= "00000000" ;
          --FPGA_PA_SW_CTRL   <= "00000000" ;
    END CASE ;
END IF ;
END PROCESS ;

process(CLK_10MHZ_I) begin
    if rising_edge(CLK_10MHZ_I) then

        if prt_cnt > pri_i then
            prt_cnt <= (others => '0');
        else
            prt_cnt <= prt_cnt + '1';
        end if;

        if ((prt_cnt < pw_i) and (prt_cnt > 0)) then
            int_trp <= '1';
        else
            int_trp <= '0'; 
        end if;
       
end if;

end process;

end architecture_Mode_decoder;