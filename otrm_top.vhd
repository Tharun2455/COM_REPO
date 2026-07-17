library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.frame_type.all;

entity otrm_top is
port (

  
 

	RX_LOAD_ADAR1_O   : OUT  std_logic;
	TX_LOAD_ADAR1_O   : OUT  std_logic;
	TR_ADAR1_O        : OUT  std_logic;

    
    
	SCLK_ADAR1_O      : OUT  std_logic;
	CSB_ADAR1_O       : OUT  std_logic;
	SDO_ADAR1_I      : IN  std_logic;
	SDIO_ADAR1_IO     : OUT  std_logic;
    
    RX_LOAD_ADAR2_O   : OUT  std_logic;
	TX_LOAD_ADAR2_O   : OUT  std_logic;
	TR_ADAR2_O        : OUT  std_logic;

	SCLK_ADAR2_O      : OUT  std_logic;
	CSB_ADAR2_O       : OUT  std_logic;
	SDO_ADAR2_I       : IN  std_logic;
	SDIO_ADAR2_IO     : OUT  std_logic ;

    SDI_LVDS_FPGA_I     : IN STD_LOGIC ;
    SDO_LVDS_FPGA_O     : OUT STD_LOGIC ;
    
   
    FPGA_SPI_BUFF_CTRL_G1  : out std_logic ;
    FPGA_SPI_BUFF_CTRL_G2  :out std_logic;

    DC_DC_Control_Buffer : out std_logic;
    BUFF_ENABLE_TX_TR_SW    : OUT  STD_LOGIC ;
    FPGA_EN_n5V_DC_DC7149    : OUT  STD_LOGIC  ;
    FPGA_TX_EN_G1_G2         : out std_logic   ;

    TR_SW_G1                 : out std_logic   ;
    TR_SW_G2                 : out std_logic   ;

    FPGA_EN_28NV_DC_DC7149   : out std_logic ;
    FPGA_3_3v                  :out std_logic; 
    
    PA_ON_1                  : out std_logic ;
    PA_ON_2                  : out std_logic ;
    
    FPGA_RX_EN_G1_G2         : OUT STD_LOGIC;
    
    RX_EN_ADAR_1             : OUT STD_LOGIC;     -- TO ENABLE RX OF  FIRST ADAR OF FIRST GROUP
    RX_EN_ADAR_2             : OUT STD_LOGIC;
    RX_EN_ADAR_5             : OUT STD_LOGIC;
    RX_EN_ADAR_6             : OUT STD_LOGIC

);
end otrm_top;
architecture architecture_otrm_top of otrm_top is


	component uart_rx_wrap is 
    generic (
		uart_speed_in_mpbs   : integer:=10	; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer:=8;
		maximum_word_count   : integer:=20
		); 
	port (
			reset			:in		std_logic ;
			clk_50MHZ		:in		std_logic;	---50mhz		
			clk_10MHz		:in		std_logic;	---10mhz		
			sdi_rx      	:in		std_logic ;-----uart_rx sdi line			

			data_frame_out	:out	frame_50word_8bit;
			new_frame_flag	:out  	std_logic	;
             data_frame_flag_1 :OUT STD_LOGIC  
   );
end component;


component uart_tx_wrap is  
    generic (
		uart_speed_in_mpbs   : integer := 10; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer := 8;
		maximum_pak_size   : integer := 20
		);
		PORT (
				clk_10MHz		: in std_logic;  
				clk_50MHz		: in STD_LOGIC;
				reset    		: in std_logic;  -- Global Reset
				sdo_tx			: out std_logic;
				tx_frame_done	: out std_logic;
				frame_size		: in integer;
				data_frame_in	: in frame_50word_8bit;
				new_frame_flag	: in std_logic				
			);
end component;





component Clocking_Blk is
    -- Port list
    port(
        -- Outputs
        clk_50mhz : out std_logic;
        clk_10mhz : out std_logic;
        clk_5mhz  : out std_logic;
        clk_25mhz : out std_logic 
        );
end component;






component Mode_decoder is
port (
      CLK_50MHz_I       : IN STD_LOGIC;
      CLK_5MHz_I        : IN STD_LOGIC;
      CLK_10MHZ_I       : IN STD_LOGIC;
      SYS_RESET_I       : IN STD_LOGIC;
      ---PRT               : IN STD_LOGIC;
      --PRT_status         : IN STD_LOGIC;
      ---SOB               : IN STD_LOGIC;
      RX_FRAME          : IN frame_50word_8bit;
      FLAG_FRAME        : IN STD_LOGIC;
   --   CAL_FLAG          : OUT STD_LOGIC;  
      CMD_TYPE_NOP      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);  
      STATUS_TYPE       : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); 
      FLASH_CMD         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      FLASH_INPUT_FRAME : OUT frame_10word_8bit; 

      SCLK_ADAR1_O      : OUT  std_logic;
      CSB_ADAR1_O       : OUT  std_logic;
      SDO_ADAR1_I       : IN  std_logic;
      SDIO_ADAR1_IO     : INOUT  std_logic;  
      SCLK_ADAR2_O      : OUT  std_logic;
      CSB_ADAR2_O       : OUT  std_logic;
      SDO_ADAR2_I       : IN  std_logic;
      SDIO_ADAR2_IO     : INOUT  std_logic; 

  
	  
	  FPGA_TR_ADAR1      : OUT STD_LOGIC ;
	  FPGA_TR_ADAR2      : OUT STD_LOGIC ;
	  FPGA_TX_LOAD_ADAR1 : OUT STD_LOGIC ;
	  FPGA_RX_LOAD_ADAR1 : OUT STD_LOGIC ;
	  FPGA_TX_LOAD_ADAR2 : OUT STD_LOGIC ;
	  FPGA_RX_LOAD_ADAR2 : OUT STD_LOGIC ;
    FPGA_SPI_BUFF_CTRL_G1_1  : out std_logic ;
    FPGA_SPI_BUFF_CTRL_G2_1  :out std_logic;

    DC_DC_Control_Buffer_1     : out std_logic;
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
end component;

component status_wrap is
port (
    --<port_name> : <direction> <type>;
        
           CLK_50MHZ_I      : in  STD_LOGIC;
           CLK_10MHZ_I      : in  STD_LOGIC;
           CLK_5MHZ_I       : in  STD_LOGIC;
           Reset            : in  STD_LOGIC;
           status_type      : in  std_logic_vector (3 downto 0) ;
           status_data      : OUT frame_50word_8bit;
           FLAG_TX          : OUT STD_LOGIC;
           cmd_type_nop     : in  std_logic_vector (7 downto 0) 
); 
end component status_wrap ;


SIGNAL data_frame_flag_1 :STD_LOGIC;
SIGNAL SDO_ADAR2_I_KEEP :std_logic;
SIGNAL SDO_ADAR1_I_KEEP :std_logic;
signal SDO_LVDS_FPGA_O_KEEP:STD_LOGIC;

SIGNAL SDI_LVDS_FPGA_I_KEEP :std_logic; 
attribute syn_keep : boolean;
attribute syn_keep of SDI_LVDS_FPGA_I_KEEP : signal is true;
attribute syn_keep of SDO_LVDS_FPGA_O_KEEP : signal is true;



attribute syn_keep of SDO_ADAR2_I_KEEP : signal is true;
attribute syn_keep of SDO_ADAR1_I_KEEP : signal is true;




attribute syn_preserve : boolean;
attribute syn_preserve of SDO_ADAR2_I_KEEP : signal is true;
attribute syn_preserve of SDO_ADAR1_I_KEEP : signal is true;
attribute syn_preserve of SDO_LVDS_FPGA_O_KEEP : signal is true;





attribute syn_preserve of SDI_LVDS_FPGA_I_KEEP : signal is true;

signal clk_10mhz, clk_50mhz, clk_5mhz , clk_25mhz : std_logic;
signal por_rst : std_logic;
signal por_rst_cnt : std_logic_vector(23 downto 0) := (others => '0');
signal temp1_valid,temp2_valid,temp3_valid,temp4_valid,temp5_valid : std_logic;
signal TEMP1_Data,TEMP2_Data,TEMP3_Data,TEMP4_Data,TEMP5_Data : std_logic_vector(9 downto 0) := (others => '0');

signal data4adc_12bit1_ADC1,data4adc_12bit1_ADC2 : frame_8words_12bits;
 
signal fwd_pwr_sts :  std_logic_vector(7 downto 0);
signal current_mon_sts :  std_logic_vector(7 downto 0);

signal adc_fwd_thd : std_logic_vector(11 downto 0) := x"030";
signal adc_cur_thd : std_logic_vector(11 downto 0) := x"030";


signal word_count :integer range 0 to 128:= 11;
signal data_frame_in :	frame_70word_24bit;
signal data_frame_out_1,data_frame_out_2 :	frame_70word_8bit;
signal data_frame_o_v_1,data_frame_o_v_2  :  	std_logic;
signal busy_flag_1,busy_flag_2		:  	std_logic;

signal adar_rst_cnt  : std_logic_vector (27 downto 0) := (others => '0') ;
signal data_adar_flag : std_logic ;

signal rx_frame                                 : frame_50word_8bit ;
signal tx_frame_s                                 : frame_50word_8bit ;
signal  data_frame_in_s                           : frame_50word_8bit;
signal  tx_frame_done_s                           : std_logic ;

signal	maximum_pak_size_s	:integer range 0 to 1000:= 0;
signal	data_frame_out_s	:frame_50word_8bit;
signal	new_frame_flag_rx_s	:STD_LOGIC :='0';
signal	new_frame_flag_tx_s	:STD_LOGIC :='0';
signal  CMD_TYPE_NOP_S : STD_LOGIC_VECTOR(7 DOWNTO 0):=X"00";
signal  STATUS_TYPE_S : STD_LOGIC_VECTOR(3 DOWNTO 0):=X"0";

signal  FLASH_CMD_s         : std_logic_vector (7 downto 0) ;         
signal  FLASH_INPUT_FRAME_s : frame_10word_8bit ; 
signal  write_data , state , read_data_shift_reg , read_data_latch_reg , bit_count  : std_logic_vector (7 downto 0) ;
signal  write_address : std_logic_vector (23 downto 0) ;
signal wr_done   : std_logic :='0' ;
signal  count   : std_logic_vector (31 downto 0) ;
signal  temp    : std_logic_vector (3 downto 0) ;
signal  wait_count    : std_logic_vector (3 downto 0) ;

signal debug_reg : std_logic;
signal  data_delay1 : std_logic := '0' ;
signal  data_delay2 : std_logic := '0' ;
signal  t_valid     : std_logic := '0' ;
signal loop1:std_logic;
--
signal pw_i : std_logic_vector(19 downto 0) := x"003E8";  --1000 
signal pri_i : std_logic_vector(19 downto 0) := x"04E20"; --20000        
signal prt_cnt : std_logic_vector(19 downto 0) := x"00000";  
signal int_trp : std_logic := '0';
 
 signal   FPGA_SPI_BUFF_CTRL_G1_1       :std_logic;
 signal   FPGA_SPI_BUFF_CTRL_G2_1 :std_logic;

 signal   DC_DC_Control_Buffer_1  :std_logic;
 signal   BUFF_ENABLE_TX_TR_SW_1  :std_logic;
 signal   FPGA_EN_n5V_DC_DC7149_1 :std_logic;
 signal   FPGA_TX_EN_G1_G2_1      :std_logic;

 signal   TR_SW_G1_1              :std_logic;
 signal   TR_SW_G2_1              :std_logic;

 signal   FPGA_EN_28NV_DC_DC7149_1:std_logic;
 signal   FPGA_3_3v_1             :std_logic;

 signal   PA_ON_1_1               :std_logic;
 signal   PA_ON_2_1               :std_logic;

   signal       FPGA_RX_EN_G1_G2_1      :std_logic;
       
     signal     RX_EN_ADAR_1_1          :std_logic;
    signal      RX_EN_ADAR_2_1          :std_logic;
       signal   RX_EN_ADAR_5_1          :std_logic;
       signal   RX_EN_ADAR_6_1          :std_logic;
 
 
 
 
 
 
 
 
 
 
 
 
 
 begin         
ref_clk_gen_inst: Clocking_Blk
    port map(
        clk_50mhz => clk_50mhz,
        clk_10mhz => clk_10mhz,
        clk_5mhz  => clk_5mhz,
        clk_25mhz  => clk_25mhz
        );

process (clk_50mhz)  
begin
    if rising_edge (clk_50mhz) then
        data_delay1 <= new_frame_flag_rx_s ;
        data_delay2 <= data_delay1 ;
    end if ;
end process ;




t_valid <= data_delay2  and new_frame_flag_tx_s ;



inst_uart_rx_wrap_1: uart_rx_wrap 

generic map(
		uart_speed_in_mpbs  => 10, -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   =>8,
		maximum_word_count   => 20
		)
	port map (
			reset			=>por_rst,
			clk_50MHZ		=>clk_50mhz,---50mhz		
			clk_10MHz		=>clk_10mhz,---10mhz		
			sdi_rx      	=>SDI_LVDS_FPGA_I_KEEP,-----uart_rx sdi line			
			data_frame_out	=>data_frame_out_s,
			new_frame_flag	=>new_frame_flag_rx_s,
          data_frame_flag_1  => data_frame_flag_1 
   );
SDI_LVDS_FPGA_I_KEEP<=SDI_LVDS_FPGA_I;

inst_uart_tx: uart_tx_wrap    
		PORT map(
				clk_50MHz		=>clk_50mhz,
				clk_10MHz		=>clk_10mhz,				
				reset    		=>por_rst,
				sdo_tx			=>SDO_LVDS_FPGA_O,
				tx_frame_done	=>tx_frame_done_s,
				frame_size		=>maximum_pak_size_s, -----assign the pkt size
				data_frame_in	=>data_frame_in_s,
				new_frame_flag	=>t_valid

);
--loop1<=SDI_LVDS_FPGA_I_KEEP;
--SDO_LVDS_FPGA_O_KEEP<=loop1;


mode_decoder_inst   : Mode_decoder
port map (
      CLK_50MHz_I               => clk_50mhz ,
      CLK_5MHz_I                => clk_5mhz ,
      CLK_10MHZ_I               => clk_10mhz ,
      SYS_RESET_I               => por_rst , 
     --- PRT                       => PRT_I ,
      --SOB                       => SOB_I ,
      RX_FRAME                  => data_frame_out_s ,       -------data coming from uart 
      FLAG_FRAME                =>new_frame_flag_rx_s ,     -----high signal when full frame is received 
                   
      CMD_TYPE_NOP              => CMD_TYPE_NOP_S ,            -----non operational commands i.e when cmd should not work
      STATUS_TYPE               => STATUS_TYPE_S ,
      FLASH_CMD                 => FLASH_CMD_s ,
      FLASH_INPUT_FRAME         => FLASH_INPUT_FRAME_s ,
         
      SCLK_ADAR1_O              => SCLK_ADAR1_O ,   
      CSB_ADAR1_O               => CSB_ADAR1_O  ,   
      SDO_ADAR1_I               => SDO_ADAR1_I_KEEP  ,   
      SDIO_ADAR1_IO             => SDIO_ADAR1_IO,   
      SCLK_ADAR2_O              => SCLK_ADAR2_O ,   
      CSB_ADAR2_O               => CSB_ADAR2_O  ,   
      SDO_ADAR2_I               => SDO_ADAR2_I_KEEP  ,   
      SDIO_ADAR2_IO             => SDIO_ADAR2_IO,   
         
      --FPGA_LNA_CTRL             => lna_sw_ctrl ,
      --FPGA_28PA_CTRL            => pa_28v_ctrl ,
	  --FPGA_PA_SW_CTRL           => pa_sw_ctrl ,

    FPGA_TR_ADAR1             => TR_ADAR1_O,
    FPGA_TR_ADAR2             => TR_ADAR2_O,
    FPGA_TX_LOAD_ADAR1        => TX_LOAD_ADAR1_O,      
    FPGA_RX_LOAD_ADAR1        => RX_LOAD_ADAR1_O,
    FPGA_TX_LOAD_ADAR2        => TX_LOAD_ADAR2_O,
    FPGA_RX_LOAD_ADAR2        => RX_LOAD_ADAR2_O,
    FPGA_SPI_BUFF_CTRL_G1_1     =>  FPGA_SPI_BUFF_CTRL_G1,
    FPGA_SPI_BUFF_CTRL_G2_1     =>  FPGA_SPI_BUFF_CTRL_G2 ,
   
    DC_DC_Control_Buffer_1      =>  DC_DC_Control_Buffer ,
    BUFF_ENABLE_TX_TR_SW_1      => BUFF_ENABLE_TX_TR_SW ,
    FPGA_EN_n5V_DC_DC7149_1     => FPGA_EN_n5V_DC_DC7149,
    FPGA_TX_EN_G1_G2_1          => FPGA_TX_EN_G1_G2,     

    TR_SW_G1_1                  => TR_SW_G1,             
    TR_SW_G2_1                  =>  TR_SW_G2,            

    FPGA_EN_28NV_DC_DC7149_1   =>  FPGA_EN_28NV_DC_DC7149,
    FPGA_3_3v_1                =>  FPGA_3_3v,           

    PA_ON_1_1                  =>  PA_ON_1,             
    PA_ON_2_1                  =>  PA_ON_2,              

    FPGA_RX_EN_G1_G2_1         =>  FPGA_RX_EN_G1_G2,      

    RX_EN_ADAR_1_1             =>   RX_EN_ADAR_1,                          
    RX_EN_ADAR_2_1             =>   RX_EN_ADAR_2,         
    RX_EN_ADAR_5_1             =>   RX_EN_ADAR_5,       
    RX_EN_ADAR_6_1             =>  RX_EN_ADAR_6          

);
TR_ADAR1_O<='0';
TR_ADAR2_O<='0';

SDO_ADAR2_I_KEEP<=SDO_ADAR2_I;
SDO_ADAR1_I_KEEP<=SDO_ADAR1_I;

inst_status_wrap : status_wrap 
port map (

           CLK_50MHZ_I          => clk_50mhz ,  
           CLK_10MHZ_I          => clk_10mhz ,
           CLK_5MHZ_I           => clk_5mhz ,
           Reset                => por_rst ,            
           status_type          => STATUS_TYPE_S ,
           status_data          => data_frame_in_s ,     
           FLAG_TX              => new_frame_flag_tx_s ,
           cmd_type_nop         => CMD_TYPE_NOP_S 
           
);


--
FPGA_EN_n5V_DC_DC7149  <= '1';    --- 5 negative voltage
FPGA_EN_28NV_DC_DC7149 <= '1';    --- 28 negative voltage
FPGA_3_3v              <= '1';
FPGA_SPI_BUFF_CTRL_G1  <= '0' ;
FPGA_SPI_BUFF_CTRL_G2   <='0';
   --
BUFF_ENABLE_TX_TR_SW   <= '0';   --U159 Buffer --0 - ON , 1 - Off
DC_DC_Control_Buffer  <= '0';

FPGA_RX_EN_G1_G2            <= '0';

--PA_ON_1     <= '1' ;  -- PA biasing pulse
---PA_ON_2     <= '1';

TR_SW_G1    <= '0' ; 
TR_SW_G2    <= '0';     -- VC1 = -28v ,  vc2 = 0v (Transmit) , VC1 = 0V , VC2 = -28V (Receive) U96
    
-- VC1 = -28v ,  vc2 = 0v (Transmit) , VC1 = 0V , VC2 = -28V (Receive)
---FPGA_TX_EN_G1_G2    <= '1' ;  ---drain control  Schematic Page - 20
--
--TR_ADAR2_O  <= int_trp ;
--TR_ADAR1_O <= int_trp;
--
RX_EN_ADAR_1   <= '1';
RX_EN_ADAR_2   <= '1';
RX_EN_ADAR_5   <= '1';
RX_EN_ADAR_6   <= '1';





--process(clk_50mhz)
--begin
  --if rising_edge(clk_50mhz) then
    --debug_reg <= SDI_LVDS_FPGA_I;
  --end if;
--end process;

--process(CLK_10MHZ) begin
    --if rising_edge(CLK_10MHZ) then
--
        --if prt_cnt > pri_i then
            --prt_cnt <= (others => '0');
        --else
            --prt_cnt <= prt_cnt + '1';
        --end if;
--
        --if ((prt_cnt < pw_i) and (prt_cnt > 0)) then
            --int_trp <= '1';
        --else
            --int_trp <= '0'; 
        --end if;
       --
--end if;
--
--end process;





end architecture_otrm_top;





