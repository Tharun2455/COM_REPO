
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity adar_spi_shift is

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
end adar_spi_shift;

architecture Behavioral of adar_spi_shift is


type t_State is (idle, clk_shift_0, clk_shift_1,gen_valid,delay_1,cs_shift_0_d,clk_shift_0_d,clk_shift_1_d,cs_shift_0);
signal State : t_State;    
    
signal data_in_lat : std_logic_vector(23 downto 0) := x"000000";
signal data_out_t : std_logic_vector(23 downto 0) := x"000000";
signal bit_cnt  : integer range 0 to 23 :=0;

begin
    
process(clk) is
begin
    if(reset = '1') then
        State         <= idle;
        bit_cnt       <= 23;
        data_in_lat   <= (others => '0');
        data_out      <= (others => '0');
        data_out_v    <= '0';
        spi_busy      <= '0';
 
        sdo           <= '1';
        sck           <= '1';
        cs            <= '1';
       
    elsif(rising_edge(clk)) then
    
    case State is
        when idle =>
            if(en = '1')then
                State           <= cs_shift_0;
                spi_busy        <= '1';
                data_in_lat     <= data_in;
            else
                State           <= idle;
                spi_busy        <= '0';  
            end if;
            
        bit_cnt       <= 23;
        data_out_v    <= '0';
        
        sdo           <= '1';
        sck           <= '1';
        cs            <= '1';
        
            
        when cs_shift_0  =>
             State <= cs_shift_0_d;       
             cs    <= '0';

        when cs_shift_0_d  =>
             State <= clk_shift_0;       
                                      
        when clk_shift_0  =>
             state <=clk_shift_0_d;
             sdo    <= data_in_lat(bit_cnt);     
             sck    <= '0';

        when clk_shift_0_d  =>
             State <= clk_shift_1;  
                        
        when clk_shift_1  =>            
             data_out_t(bit_cnt) <= sdi;    
             sck        <= '1'; 
             
             state      <=clk_shift_1_d; 
                        
        when clk_shift_1_d  =>            
            if bit_cnt = 0 then
               State <= gen_valid;
            else
                state   <= clk_shift_0;
                bit_cnt <= bit_cnt - 1; 
            end if;
               
       
        when gen_valid  =>           
                data_out_v <= data_in_lat(23);         
                data_out <= data_out_t(7 downto 0);         
                State <= idle;    

              sck    <= '1';         
              cs     <= '1';         
              sdo    <= '1';         
              
        when others =>
            state <= idle;

    end case;
    end if;
end process;


end Behavioral;

