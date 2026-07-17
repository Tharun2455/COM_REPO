
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
library work;
use work.frame_type.all;

entity uart_tx_wrap is  
    generic (
		uart_speed_in_mpbs   : integer := 10	; -----ex 5 for 5mbps, 10 for 10mbps
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
end uart_tx_wrap;

architecture Behavioral of uart_tx_wrap is

component	uart_tx is
    generic (
		uart_speed_in_mpbs   : integer	; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer
		);
		PORT (
				clk_10MHz		: in std_logic;  
				clk_50MHz		: in STD_LOGIC;
				reset    		: in std_logic;  -- Global Reset
				Serial_out		: out std_logic;
				tx_done			: out std_logic;
				data_in		: in std_logic_VECTOR( uart_data_width_in_bit-1 DOWNTO 0);
				flag_new_data	: in std_logic				
			);
end component;

			type	uart_tx_word	is	(word_state_ideal,word_state_1,word_state_1_0,word_state_2,word_state_3,word_state_4);
			signal	word_state	:	uart_tx_word;
			signal 	new_frame_flag_1,new_frame_flag_2,new_frame_flag_3,new_frame_flag_4	:	STD_LOGIC :='0';
			signal 	tx_done,tx_done_1,tx_done_2,tx_done_3,tx_done_4	:	STD_LOGIC :='0';
			signal	new_frame_flag_s	:STD_LOGIC :='0';
			signal	flag_new_data_s	:STD_LOGIC :='0';
			signal	tx_done_s		:STD_LOGIC :='0';
			signal	sdo_tx_s		:STD_LOGIC ;
            signal 	data_frame_in_s	:frame_50word_8bit;
			signal	packet_size	:integer range 0 to 1000:=0;
			signal	frame_size_s	:integer range 0 to 1000:=0;
			signal	word_count,count_2, pkg_identifier	:integer range 0 to 1000 :=0;
            signal data_frame_flag_1 :std_logic;
            signal data_from_tx:std_logic_vector(7 downto 0);
signal 	tx_frame_done_s		:STD_LOGIC :='0';
			signal	DATA_out_s,pkg_identifier_s,checksum_cal,checksum_cal_verification,footer_data      :STD_LOGIC_vector(uart_data_width_in_bit-1 downto 0):=x"00";			
			
begin
inst_uart_tx :uart_tx 
       generic map(
			uart_speed_in_mpbs	=>10,
			uart_data_width_in_bit	=>8
		)
		port map(			
		    clk_10MHz           =>clk_10MHz,
		    clk_50MHz        	=>clk_50MHz,
			reset           	=>reset,
		    Serial_out         	=>sdo_tx_s,
		    tx_done         	=>tx_done,
		    data_in          	=>DATA_out_s,
		    flag_new_data       =>flag_new_data_s
		);
flag_received	:process(reset,clk_50MHz,new_frame_flag,tx_done)
	begin 
		if (reset = '1') then
			new_frame_flag_1<='0';
            new_frame_flag_2<='0';
            new_frame_flag_3<='0';
            new_frame_flag_4<='0';
        elsif(clk_50MHz'event and clk_50MHz = '0') then
            new_frame_flag_1 <=new_frame_flag;
            new_frame_flag_2 <=new_frame_flag_1;
            new_frame_flag_3 <=new_frame_flag_2;
            new_frame_flag_4 <=new_frame_flag_3;
        end if; 
		if (reset = '1') then
			tx_done_1<='0';
            tx_done_2<='0';
            tx_done_3<='0';
            tx_done_4<='0';
        elsif(clk_50MHz'event and clk_50MHz = '0') then
            tx_done_1 <=tx_done;
            tx_done_2 <=tx_done_1;
            tx_done_3 <=tx_done_2;
            tx_done_4 <=tx_done_3;
        end if;
end process;

new_frame_flag_s<= new_frame_flag_2 and (not new_frame_flag_4);
tx_done_s<= tx_done_1 and (not tx_done_2);-----new word edge detection;	
tx_frame_done <=tx_frame_done_s;
sdo_tx<=sdo_tx_s;	
pkg_identifier <= (conv_integer(pkg_identifier_s)); -----std logic vector to interger conversion
packet_size <=  pkg_identifier * 5 +10 ; ---------package size calculation	















word_transfer	:process (reset,clk_50MHz,tx_done_s,new_frame_flag_s)
begin
		if (reset = '1') then
			pkg_identifier_s	<=x"00";
			flag_new_data_s	<='0';
			tx_frame_done_s	<='0';
			word_state		<=word_state_ideal;
			data_out_s<=(others=>'0');
        elsif(clk_50MHz'event and clk_50MHz = '1') then
			case word_state is  
				when word_state_ideal =>
						flag_new_data_s<='0';
						tx_frame_done_s<='0';
						word_count		<=0;
						count_2		<=0;
					if new_frame_flag_s ='1'	then
						data_frame_in_s<=data_frame_in;
						pkg_identifier_s<=data_frame_in(word_count +1);
						--checksum_cal <=data_frame_in(word_count);
						checksum_cal <=x"00";
					--	checksum_cal_verification <=data_frame_in(1)  xor data_frame_in(2)  xor   data_frame_in(3)  xor data_frame_in(4)  xor data_frame_in(5)  xor data_frame_in(6)  xor data_frame_in(7)  xor data_frame_in(9)  xor data_frame_in(10) xor data_frame_in(11) xor data_frame_in(12) xor data_frame_in(13) xor data_frame_in(14) xor data_frame_in(15) xor data_frame_in(16) xor  data_frame_in(17) xor data_frame_in(18) xor data_frame_in(19);
						word_state	<=word_state_1;
						frame_size_s<=frame_size;
					else
						word_state	<=word_state_ideal;
					end if;
				when word_state_1 =>
						data_out_s<=data_frame_in_s(word_count);
						flag_new_data_s<='1';
						checksum_cal<= checksum_cal xor data_frame_in_s(word_count);
						word_state	<=word_state_1_0;
				when word_state_1_0 =>
						
					if ( tx_done_s ='1') then
						word_count		<=word_count + 1;
						--checksum_cal <= checksum_cal xor data_frame_in_s(word_count);
						--checksum_cal <= data_frame_in_s(word_count) xor data_frame_in_s(word_count+1);
					--elsif(word_count = packet_size-1) then
					elsif(word_count = packet_size) then
						word_count		<= 0;
					else	
						word_count		<=word_count;
						flag_new_data_s<='0';
					end if;	
					
					--if( word_count < packet_size-1 and tx_done_s ='1')	then
					if( word_count < packet_size-2 and tx_done_s ='1')	then
						word_state	<=word_state_1;
					elsif(word_count = packet_size-1) then
						word_state	<=word_state_2;
					else
						word_state	<=word_state_1_0;
					end if;	
					
				when word_state_2 =>
--						data_out_s<=checksum_cal;
--						flag_new_data_s<='1';
--						word_state	<=word_state_1_0;
						
					if frame_size_s < packet_size 	then
						data_out_s<=checksum_cal;
						flag_new_data_s<='1';
						word_state	<=word_state_3;
					elsif frame_size_s = packet_size then
						--data_out_s<=x"AE";---
						data_out_s<=footer_data;---
						flag_new_data_s<='1';
						word_state	<=word_state_3;
					else
						word_state	<=word_state_4;
						--tx_frame_done_s<='1';
						data_frame_in_s<=(others => (others => '0'));
					end if;	
					
				when word_state_3 =>
					if ( tx_done_s ='1') then
						word_state	<=word_state_4;
						--tx_frame_done_s<='1';
						data_frame_in_s<=(others => (others => '0'));
					else	
						flag_new_data_s<='0';
						word_state	<=word_state_3;
					end if;
					
				when word_state_4 =>
						
						data_frame_in_s<=(others => (others => '0'));
					if (  count_2 < 4 ) then
						count_2		<=count_2 + 1;
						word_state	<=word_state_4;
						tx_frame_done_s<='1';						
					else	
						count_2		<=0;
						word_state	<=word_state_ideal;
					end if;
				when others=> 			           			
	                word_state<=word_state_ideal;
			end case;	
		end if;
      
end process;			
end Behavioral;