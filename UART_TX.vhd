LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
ENTITY uart_tx is
    generic (
		uart_speed_in_mpbs   : integer:=10	; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer:=8
		);
		PORT (
				clk_10MHz		: in std_logic;  
				clk_50MHz		: in STD_LOGIC;
				reset    		: in std_logic;  -- Global Reset
				Serial_out		: out std_logic;
				tx_done			: out std_logic;
				--data_in		: out std_logic_VECTOR( 7 DOWNTO 0);
				data_in		: in std_logic_VECTOR( uart_data_width_in_bit-1 DOWNTO 0);
				flag_new_data	: in std_logic				
			);
END uart_tx;

ARCHITECTURE behave OF uart_tx IS
		signal 		cnt_clks 		: integer range 0 to uart_data_width_in_bit-1 :=0;
		signal 		cnt_bits 		: integer range 0 to uart_data_width_in_bit*2-1 :=0;
		type 		type_state_tx_uart is (s0,s1,s2,s2_1,s3,s4,s5); 
		signal 		state_tx_uart 	: type_state_tx_uart; 
		--signal 		data 			: std_logic_vector(7 downto 0);
		--signal 		data 			: std_logic_vector(uart_data_width_in_bit-1 downto 0);
		signal 		data_in_s 			: std_logic_vector(uart_data_width_in_bit-1 downto 0);
		signal 		flag_new_data_1,flag_new_data_2,flag_new_data_3,flag_new_data_4,flag_new_data_s 			: std_logic :='0';
		signal 		serial_out_s			: std_logic :='1';
		signal 		tx_done_s					: std_logic :='0';
		signal i,k : integer range 0 to 6000 :=0; 
		---signal j : integer range 0 to 31 :=0; 
		signal j : integer range -1 to 6000 :=0; 
begin
i <= 50/uart_speed_in_mpbs; --for 10MHz

j <= (i)/2-1;

k <= uart_data_width_in_bit-1; ---for 16bit uart

-- data_in <= data_in_s when flag_new_data_s = '1' else (others=>'0');

flag_new_data_s<= flag_new_data_1 and (not flag_new_data_2);-----new word edge detection;
Serial_out<=Serial_out_s;
tx_done<=tx_done_s;

flag_received	:process(reset,clk_50MHz,flag_new_data)----- new word  edge detection
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

process (reset,clk_50MHz,flag_new_data)
begin

if (reset = '1') then
        state_tx_uart <= s0;
		  cnt_clks<=0;
		  cnt_bits<=0;
		  serial_out_s<='1';
		  tx_done_s<='0';
		  data_in_s<=(others=>'0');
	elsif (clk_50MHz'event and clk_50MHz = '1') then
		case state_tx_uart is
			when s0=> 
	          		serial_out_s<='1'; 
	          		tx_done_s   <='0'; 
					--cnt_bits<=0;
					cnt_bits<= k;
					cnt_clks<=0;
					data_in_s<=(others=>'0'); 
				if flag_new_data_s='1' then
					data_in_s<=data_in;
					state_tx_uart <= s1;
					cnt_bits<=k ;
				ELSE
					state_tx_uart <= s0;
				end if;	
               
			when s1=> 	
					serial_out_s<='0';   ------------start bit
					--if cnt_clks>=j then
					--if cnt_clks>=i-1 then
					if cnt_clks>=i then
				   	state_tx_uart <= s2;
					cnt_clks<=0;
					Serial_out_s<=data_in_s(cnt_bits);    --------------msb data out
					cnt_bits<=cnt_bits - 1;
					else
					state_tx_uart <= s1;
					cnt_clks<=cnt_clks+1;
					END IF;             								
			when s2=> 	
                if cnt_bits <= 0 and cnt_clks = i-3 then
					state_tx_uart <= s2_1;
					--cnt_clks<=0;
					--Serial_out_s<=data_in_s(cnt_bits);-------lsb data out
				else
					state_tx_uart <= s2;
				END IF;
						
                if cnt_clks >= i-1 then
				    cnt_clks<=0; 
                    cnt_bits<=cnt_bits - 1; 
				else
				    cnt_clks<=cnt_clks+1;
				END IF; 

                if (cnt_clks >= i-1 and cnt_bits >= 0) then
                    Serial_out_s<=data_in_s(cnt_bits); -----------serial bit transferred
                end if;
			when s2_1=>
			      cnt_clks<=0; 
			      state_tx_uart <= s3;   
			when s3=> 
			    Serial_out_s<=data_in_s(cnt_bits);
			    if cnt_clks >= i-1 then
				    cnt_clks<=0;
				    state_tx_uart <= s4;  
				else
				    state_tx_uart <= s3;
				    cnt_clks<=cnt_clks+1;
				END IF;
			when s4=> 
					serial_out_s<='1';   ------------stop bit
					if cnt_clks>=i then
				   	state_tx_uart <= s5;
					cnt_clks<=0;
					tx_done_s   <='1'; 
					cnt_bits<=k;
					data_in_s<=(others=>'0');
					--serial_out_s<='0'; 
					else
					state_tx_uart <= s4;
					cnt_clks<=cnt_clks+1;
					END IF;
                
			when s5=> 		
					state_tx_uart <= s0;
					cnt_clks<=0;
					tx_done_s<='0'; 
					cnt_bits<=k;
		when others=>		 
				   state_tx_uart<=s0;
	end case;		
end if;
end process;
END behave;