--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: status_wrap.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S005> <Package::400 VF>
-- Author: <Name>
--
--------------------------------------------------------------------------------

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.frame_type.all;


entity status_wrap is
port (
    --<port_name> : <direction> <type>;
        
           CLK_50MHZ_I      : in  STD_LOGIC;
           CLK_10MHZ_I      : in  STD_LOGIC;
           CLK_5MHZ_I       : in  STD_LOGIC;
           Reset            : in  STD_LOGIC;
           status_type      : in std_logic_vector (3 downto 0) ;
           status_data      : OUT frame_50word_8bit;
           FLAG_TX          : OUT STD_LOGIC;
           cmd_type_nop     : in std_logic_vector (7 downto 0) 
);
end status_wrap;
architecture architecture_status_wrap of status_wrap is

        signal  status_type_s       : std_logic_vector (3 downto 0):= X"0" ;
        signal  cmd_type_nop_s      : std_logic_vector (7 downto 0):= X"00" ;
        signal  flag_tx_s           : std_logic := '0' ;
        signal  status_data_s       : frame_50word_8bit ;

begin


cmd_type_nop_s  <=  cmd_type_nop;
status_type_s   <=  status_type ;
flag_tx         <=  flag_tx_s ;
status_data     <= status_data_s ;

process (CLK_50MHZ_I , reset , cmd_type_nop_s , flag_tx_s  ) begin 
    if (reset = '1') then
        status_data_S         <= (others => x"00") ;
        flag_tx_S             <= '0' ;
    elsif (clk_50mhz_i 'event and clk_50mhz_i = '1') then
        if (cmd_type_nop_s <= x"08") then
            case status_type_s is 
                when x"0" =>
                        status_data_s (0) <= x"AA" ;
                        status_data_s (1) <= x"00" ;
                        status_data_s (2) <= x"08" ;
                        status_data_s (3) <= x"0" & status_type_s  ;   ----software version (4) / status_type
                        status_data_s (4) <= x"AA" ;  ---manufacture serial number(4) / mfg vendor id (4)    
                        status_data_s (5) <= x"AA" ;  ---mfg serial number (8) 
                        status_data_s (6) <= x"AA" ;  ---TRM ON time
                        status_data_s (7) <= x"AA" ;  ---TRM ON time
                        status_data_s (8) <= x"AA" ;  ---TRM ON time
                        status_data_s (9) <= x"AA" ;

                        flag_tx_S               <= '1' ;

                when others => 
                        
                        status_data_S         <= (others => x"00") ;
                        flag_tx_S             <= '0' ;
        end case ;
       
        end if ;
end if ;

end process ;
                        

end architecture_status_wrap;
