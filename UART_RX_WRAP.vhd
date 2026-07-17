
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.numeric_bit.all;
library work;
use work.frame_type.all;

entity uart_rx_wrap is 
    generic (
		uart_speed_in_mpbs   : integer:=10	; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer:=8;
		maximum_word_count   : integer	:= 20
		); 
	port (
			reset			:in		std_logic ;
			clk_50MHZ		:in		std_logic;	---50mhz		
			clk_10MHz		:in		std_logic;	---10mhz		
			sdi_rx      	:in		std_logic ;-----uart_rx sdi line			
			data_frame_out	:out	frame_50word_8bit;
			new_frame_flag		:out  	std_logic	;
            data_frame_flag_1 :OUT STD_LOGIC  
   );
end uart_rx_wrap;

architecture Behavioral of uart_rx_wrap is

component	uart_rx	is
      generic(
		uart_speed_in_mpbs   : integer:=10 ; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer:=8	
		);
	port(
				clk_10MHz		: in std_logic;  
				clk_50MHz		: in STD_LOGIC;
				reset    		: in std_logic;  -- Global Reset
				Serial_in		: in std_logic;
				data_out		: out std_logic_VECTOR( uart_data_width_in_bit-1 DOWNTO 0);
				flag_new_data	: out std_logic	
        );
end component;
----special note for generic----
----footer check and checksum error make it generic---------
            signal	packet_size		:integer range 0 to 1000 ;
--            SUBTYPE frame is  std_logic_VECTOR( uart_data_width_in_bit-1 DOWNTO 0);
--			--type frame1 is array  (0 to frame_number-1 ) of frame;
--			type frame1 is array  (0 to packet_size-1 ) of frame;
			   SIGNAL CHECK_SUM_FLAG:INTEGER RANGE 0 TO 90;
			type	uart_rx_word	is	(word_state_ideal,word_state_1,word_state_1_0,word_state_2,word_state_3,word_state_4,word_state_5);
			signal	word_state	:	uart_rx_word;
			signal 	flag_new_data_1,flag_new_data_2,flag_new_data_3,flag_new_data_4	:	STD_LOGIC :='0';
			signal	flag_new_data_s,flag_new_data	:STD_LOGIC :='0';
			signal	new_frame_flag_s	:STD_LOGIC :='0';
			signal	footer_error_s	:STD_LOGIC :='0';	
			signal	checksum_error_s	:STD_LOGIC :='0';	
			signal	header_error_s	:STD_LOGIC :='0';	
			signal	pkg_identifier_s	:STD_LOGIC_vector(uart_data_width_in_bit-1 downto 0):=x"0a";
			--signal	pkg_identifier_s	:STD_LOGIC_vector(7 downto 0):=x"0a";
			signal	header_data, footer_data, checksum_data,checksum_cal:STD_LOGIC_vector(uart_data_width_in_bit-1 downto 0):=x"00";
			signal	pkg_identifier		:integer range 0 to 100:=0;
			---signal	test		: unsigned(7 downto 0);
			---  signal data_frame_flag_1 :std_logic;
			signal	count_1		:integer range 0 to 1000:=0;
			signal	count_2	:integer range 0 to 4 :=0;
			signal	DATA_out_s      :STD_LOGIC_vector(uart_data_width_in_bit-1 downto 0):= x"00" ;
			signal 	data_frame_in_s	:frame_50word_8bit;
			--signal 	data_frame_out_s:frame1;
			--signal 	busy_flag_s		:STD_LOGIC :='0';
begin
inst_uart_rx : uart_rx 
       generic map(
			uart_speed_in_mpbs	=>uart_speed_in_mpbs,
			uart_data_width_in_bit	=>uart_data_width_in_bit
		)
		port map(			
		    clk_10MHz           =>clk_10MHz,
		    clk_50MHz        	=>clk_50MHz,
			reset           	=>reset,
		    Serial_in         	=>sdi_rx,
		    DATA_out        	=>DATA_out_s,
		    flag_new_data      	=>flag_new_data
		);
flag_received	:process(reset,clk_50MHz,flag_new_data_s)----- new word  edge detection
	begin 
		if (reset = '1') then
			flag_new_data_1<='0';
            flag_new_data_2<='0';
            flag_new_data_3<='0';
            flag_new_data_4<='0';
        elsif(clk_50MHz'event and clk_50MHz = '0') then
            flag_new_data_1 <=flag_new_data;
            flag_new_data_2 <=flag_new_data_1;
            flag_new_data_3 <=flag_new_data_2;
            flag_new_data_4 <=flag_new_data_3;
        end if; 
end process;

	flag_new_data_s<= flag_new_data_1 and (not flag_new_data_2);-----new word edge detection;
	pkg_identifier <= (conv_integer(pkg_identifier_s)); -----std logic vector to interger conversion
	packet_size <=  pkg_identifier * 5 +10 ; ---------package size calculation
    new_frame_flag<=new_frame_flag_s;
word_frame_receiver	:process (reset,clk_50MHz,flag_new_data_s,packet_size)
begin
		if (reset = '1') then
			new_frame_flag_s	<='0';
			header_error_s	<='0';
			footer_error_s	<='0';
			pkg_identifier_s<=(others => '0');
			--DATA_out_s		<=(others => '0');			
			word_state		<=word_state_ideal;
        elsif(clk_50MHz'event and clk_50MHz = '1') then
			case word_state is  
				when word_state_ideal =>
						new_frame_flag_s	<='0';
						header_error_s	<='0';
						footer_error_s	<='0';
						count_1			<=0;
						pkg_identifier_s<=(others => '0');
						--DATA_out_s		<=(others => '0');
					if flag_new_data_s ='1'	then     -----first word
						header_data 	<= DATA_out_s;   -----header data copy
						word_state		<=word_state_1_0;
					else
						word_state		<=word_state_ideal;
					end if;
					
				when word_state_1_0 =>
					if header_data =x"AA"	then   ------header check
						header_data 			<= DATA_out_s;
						data_frame_in_s(count_1)<= header_data;
						checksum_cal			<= header_data; -------header copy fro checksum calculation
						count_1					<=count_1 + 1;
						word_state				<=word_state_1;
					else
						header_error_s	<='1';   -------header error acknowledgement
						word_state		<=word_state_ideal;
					end if;				
						
				when word_state_1 =>
					if flag_new_data_s ='1'	then   ------2nd word copy for package identifier
						pkg_identifier_s		<=DATA_out_s;
						data_frame_in_s(count_1)<= DATA_out_s;
						checksum_cal 			<= checksum_cal xor DATA_out_s;			--------checksum calculation
						count_1					<=count_1 + 1;
						word_state				<=word_state_2;
					else
						word_state				<=word_state_1;
					end if;	
				when word_state_2 =>				
					if flag_new_data_s ='1'	then                ----new word
						data_frame_in_s(count_1)<= DATA_out_s;
						count_1					<=count_1 + 1;						
					end if;
					if (flag_new_data_s ='1' and count_1 < packet_size -1) then
						checksum_cal 			<= checksum_cal xor DATA_out_s;			--------checksum calculation			
					end if;
					if count_1 < packet_size 	then
						word_state	<=word_state_2;
					else
						word_state	<=word_state_3;
						count_1		<=0;
						--data_frame_out<=data_frame_in_s;
					end if;					
					if count_1 = packet_size -1 then     --------last word
						footer_data		<= DATA_out_s;
						checksum_data 	<= DATA_out_s;
					end if;	
										
				when word_state_3 =>
--					if footer_data =x"AE"	then   ------footer check
--						footer_error_s<='0';
--                        word_state	<=word_state_4;
--						data_frame_out<=data_frame_in_s;
--					else
--						footer_error_s<='1';
--                        word_state	<=word_state_ideal;
--					end if;				
					if checksum_cal = checksum_data	then  ----checksum error check
						checksum_error_s<='0';
						word_state	<=word_state_4;
						data_frame_out<=data_frame_in_s;
                        CHECK_SUM_FLAG<=87;
					else
						checksum_error_s<='1';              --- changed for ILA checksum 0
						word_state	<=word_state_ideal;
                      --  data_frame_out<=data_frame_in_s;
					end if;

				when word_state_4 =>
						word_state		<=word_state_5;
						count_1			<=0;----word count reset to zero
						new_frame_flag_s<='1';   --------valid signal for new frame afrer no error
						pkg_identifier_s<= x"00";--------pkg_identifier_s reset -----NOTE MAKE IT PARAMETRIC
						--packet_size 	<= 10;----packet_size reset to 10
						data_frame_out	<=data_frame_in_s;	
						
				when word_state_5 =>
						--data_frame_in_s<=(others => (others => '0'));
					if (  count_2 < 4 ) then
						count_2		<=count_2 + 1;
						word_state	<=word_state_4;						
					else	
						count_2		<=0;
						new_frame_flag_s<='0';
						word_state	<=word_state_ideal;
						data_frame_in_s<=(others => (others => '0'));
					end if;
				when others=> 			           			
	                word_state<=word_state_ideal;
			end case;	
		end if;
      
end process;	

--process (clk_50MHz)
--begin 
--IF(RISING_EDGE (clk_50MHz))THEN
--IF(CHECK_SUM_FLAG=87)THEN
--data_frame_flag_1<='1';
--END IF;
--END IF;
--END PROCESS;
		
end Behavioral;