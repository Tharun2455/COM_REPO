LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
ENTITY uart_rx is
    generic (
		uart_speed_in_mpbs   : integer:=10; -----ex 5 for 5mbps, 10 for 10mbps
		uart_data_width_in_bit   : integer:=8
		);
		PORT (
				clk_10MHz		: in std_logic;  
				clk_50MHz		: in STD_LOGIC;
				reset    		: in std_logic;  -- Global Reset
				Serial_in		: in std_logic;
				--data_out		: out std_logic_VECTOR( 7 DOWNTO 0);
				data_out		: out std_logic_VECTOR( uart_data_width_in_bit-1 DOWNTO 0);
				flag_new_data	: out std_logic				
			);
END uart_rx;

ARCHITECTURE behave OF uart_rx IS
		signal 		cnt_clks 		: integer range 0 to uart_data_width_in_bit-1 :=0;
		signal 		cnt_bits 		: integer range 0 to uart_data_width_in_bit*2-1 :=0;
		--signal 		cnt_bits 		: integer range 0 to uart_data_width_in_bit-1 :=0;
		type 		type_state_rx_uart is (s0,s0_1,s1,s2,s3,s4,s5); 
		signal 		state_rx_uart 	: type_state_rx_uart; 
		--signal 		data 			: std_logic_vector(7 downto 0);
		signal 		data 			: std_logic_vector(uart_data_width_in_bit-1 downto 0);
		signal 		data_out_s 			: std_logic_vector(uart_data_width_in_bit-1 downto 0);
		signal 		flag_new_data_s 			: std_logic :='0';
		signal i,k : integer range 0 to 6000:=0; 
		signal j : integer range -1 to 6000 :=0; 
begin
i <= 50/uart_speed_in_mpbs; --for 50MHz

j <= (i)/2-1;

k <= uart_data_width_in_bit-1; ---for 16bit uart

data_out <= data_out_s when flag_new_data_s = '1' else (others=>'0');
flag_new_data<=flag_new_data_s;
process (reset,clk_50MHz,Serial_in)
begin

if (reset = '1') then
        state_rx_uart <= s0;
		  cnt_clks<=0;
		  cnt_bits<=0;
		  flag_new_data_s<='0';
     data_out_s<=(others=>'0');
	elsif (clk_50MHz'event and clk_50MHz = '1') then
		case state_rx_uart is
			when s0=> 
	          		flag_new_data_s<='0'; 
					--cnt_bits<=0;
					cnt_bits<= 0;
					data_out_s<=(others=>'0'); 
				if Serial_in='0' then          ---start bit
					--if cnt_clks>=1 then
--					if cnt_clks>=j then
--				   	state_rx_uart <= s1;
--					else
--					state_rx_uart <= s0;
--					cnt_clks<=cnt_clks+1;
--					END IF;  
					state_rx_uart <= s0_1;           
				ELSE
					state_rx_uart <= s0;
                    cnt_clks<=0;
				end if;	
               
			when s0_1=> 
			        if cnt_clks>=j then
				   	state_rx_uart <= s2;
					else
					state_rx_uart <= s0_1;
					cnt_clks<=cnt_clks+1;
					END IF;
			 		
			when s1=> 		
					state_rx_uart <= s2;
					cnt_clks<=0;
					cnt_bits<=0 ;
			when s2=> 	
                --if cnt_bits>7 then
                if cnt_bits>k then
               -- if cnt_bits<0 then
					state_rx_uart <= s3;
				else
					state_rx_uart <= s2;
				END IF;		
                --if cnt_clks>=4 then
               -- if cnt_clks>= i-1 then
                if cnt_clks >= i-1 then
				    cnt_clks<=0;
                   -- cnt_bits<=cnt_bits+1; 
                    cnt_bits<=cnt_bits + 1; 
				else
				    cnt_clks<=cnt_clks+1;
				END IF; 
                --if (cnt_clks=4 and cnt_bits < 8) then
                --if (cnt_clks= i-1 and cnt_bits < 8) then
                if (cnt_clks = i-1 and cnt_bits <= k) then
                --if (cnt_clks = i-1 and cnt_bits > 0) then
                    data(cnt_bits)<=Serial_in;
                end if;
			when s3=> 		
					state_rx_uart <= s4;
					cnt_clks<=0;
					data_out_s<=data;
					--cnt_bits<=0;
					cnt_bits<=0;
					flag_new_data_s<='0'; 
			when s4=> 		
                --if cnt_clks>=4 then   
                if cnt_clks>= i-1 then
                 if serial_in = '1' then
                    flag_new_data_s<='1'; 
                 else
                    flag_new_data_s<='0'; 
                 end if;   
					state_rx_uart <= s5;
					--flag_new_data_s<='1'; 
				else
					state_rx_uart <= s4;
					flag_new_data_s<='0';
					cnt_clks<=cnt_clks+1;
				END IF;  
				              
					cnt_bits<=0;
					--cnt_bits<=k ;
					data_out_s<=data;
			when s5=> 		
					state_rx_uart <= s0;
					cnt_clks<=0;
					flag_new_data_s<='1'; 
					cnt_bits<=0;
					--cnt_bits<=k;
		when others=>		 
				   state_rx_uart<=s0;
                --   flag_new_data_s<='0';
	end case;		
end if;
end process;
END behave;