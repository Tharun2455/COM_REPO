
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
library work;
use work.frame_type.all;

entity spi_wrap is  
	port (
			reset			:in		std_logic ;
			CLK_50MHz_I				:in		std_logic;	---50mhz		
				
			data_frame_in	:in		frame_70word_24bit;-- :=(x"800001" ,x"800002" ,x"000003" ,x"800004" ,x"800005" ) ;--frame_70word_24bit;
			word_count		:in		integer range 0 to 128 ;
			data_in_flag	:in		std_logic := '0';
			
			data_frame_out	:out	frame_70word_8bit;--frame_10word_8bit;
			data_frame_o_v  :out  	std_logic;
			busy_flag		:out  	std_logic;
----------spi--------------------------------------------------------
			sdo      		:in	STD_LOGIC ;-----spi sdo line
	        sdio     		:out	STD_LOGIC ;----spi sdio line
            sclk            :out	STD_LOGIC ;
            cs              :out	STD_LOGIC 			
   );
end spi_wrap;

architecture Behavioral of spi_wrap is


component adar_spi_shift is

    Port ( 
            clk         : in  STD_LOGIC; 
            reset       : in  STD_LOGIC;
            en          : in  STD_LOGIC;
            data_in     : in  STD_LOGIC_VECTOR (23 downto 0);

            data_out    : out  STD_LOGIC_VECTOR (7 downto 0);
            data_out_v  : out  STD_LOGIC;
            spi_busy    : out  STD_LOGIC;

            cs          : out  STD_LOGIC;
            sdi         : in  STD_LOGIC;
            sdo         : out  STD_LOGIC;
            sck         : out  STD_LOGIC
);
end component;


			type	spi_word	is	(idle,push_data, spi_busy_delay ,spi_busy_check,total_cnt_check,end_state);
			signal	word_state	:	spi_word;

			signal	data_in_flag_s	:STD_LOGIC :='0';
			signal	write_flag_s	:STD_LOGIC :='0';
			signal	read_done_s		:STD_LOGIC :='0';
			signal	write_done_s	:STD_LOGIC :='0';
			signal	word_count_s	:integer range 0 to 128:=0;
			signal	count_1,count_2	:integer range 0 to 128 :=0;		

			signal	DATA_IN_s       :STD_LOGIC_vector(23 downto 0):=x"000000";
			signal	DATA_out_s      :STD_LOGIC_vector(7 downto 0):=x"00";

			signal 	busy_flag_s		:STD_LOGIC :='0';
			
			
			signal spi_busy : std_logic;
begin

inst_spi: adar_spi_shift

    Port map( 
            clk         => CLK_50MHz_I,
            reset       => reset,
            en          => write_flag_s,
            data_in     => DATA_IN_s,

            data_out    => DATA_out_s,
            data_out_v  => read_done_s,
            spi_busy    => spi_busy,

            cs          => cs,
            sdi         => sdo,
            sdo         => sdio,
            sck         => sclk
);

word_transfer	:process (CLK_50MHz_I)
begin
		if (reset = '1') then
			word_count_s	<=0;
			busy_flag_s	<='0';
			data_frame_o_v	<='0';
			word_state		<=idle;
        elsif rising_edge(CLK_50MHz_I) then
			case word_state is  
				when idle =>
						
						count_1		<=0;

					if data_in_flag ='1'	then
					--	data_frame_in_s<=data_frame_in;  --not required
--						word_count_s<=word_count;
						busy_flag_s<='1';
						word_state	<= push_data;
					else
						word_state	<=idle;
						busy_flag_s<='0';
					end if;
					
				when push_data =>
						DATA_IN_s<=data_frame_in(count_1);
						write_flag_s<='1';
						word_state	<=spi_busy_delay;
				
				when spi_busy_delay =>
				        word_state  <= spi_busy_check;
				        write_flag_s <='0';
												
				when spi_busy_check =>		
					if ( spi_busy ='0') then
						word_state	<= total_cnt_check;
				--		data_frame_out(count_1)<= DATA_out_s;						
					else
						word_state	<= spi_busy_check;
					end if;	
																			
				when total_cnt_check =>
					if count_1 < word_count 	then
						word_state	<=push_data;
						
					else
						word_state	<= end_state;
					end if;
					
					count_1		<=count_1 + 1;
					
				when end_state =>
						word_state	<=idle;
						count_1		<=0;
						data_frame_o_v		<= '1';
						busy_flag_s	<='0';
						
				when others=> 			           			
	                word_state<=idle;
			end case;	
		end if;
      
end process;			
end Behavioral;