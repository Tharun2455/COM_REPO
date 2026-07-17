--library IEEE;

--use IEEE.std_logic_1164.all;

--PACKAGE frame_type is

--TYPE frame_127word_24bit IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
--TYPE frame_16word_8bit IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
--TYPE frame_4word_24bit IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
--TYPE frame_4word_8bit IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (7 DOWNTO 0);

--TYPE frame_50word_8bit IS ARRAY (0 TO 49) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
--TYPE frame_10word_8bit IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
--TYPE frame_20word_8bit IS ARRAY (0 TO 19) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
--TYPE frame_1word_8bit   IS ARRAY (0 TO 0) OF STD_LOGIC_VECTOR (7 DOWNTO 0) ;

--type frame_8words_16bits is array (0 to 7) of std_logic_vector(15 downto 0);
--type frame_8words_12bits is array (0 to 7) of std_logic_vector(11 downto 0);

--TYPE PHASE_ARRAY IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (5 DOWNTO 0);
--TYPE RX_ARRAY IS ARRAY (0 TO 49) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
--TYPE frame_20words_8bit IS ARRAY (0 TO 19) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
--TYPE M_VALUE_ARRAY IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (5 DOWNTO 0);
--TYPE N_VALUE_ARRAY IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (5 DOWNTO 0);
----TYPE CAL_ARRAY IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
--TYPE DWELL_ARRAY IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
--TYPE DataReceived_array_type is array (0 to 15) of std_logic_vector(15 downto 0);

--TYPE spi IS ARRAY (0 to 0) of STD_LOGIC_VECTOR (7 downto 0);

--type freq_wise_data is array (0 to 8) of std_logic_vector(2047 downto 0);
--type frame_6words_8bits is array (0 to 5) of std_logic_vector(7 downto 0);
----type frame_12words_16bit is array (0 to 11) of std_logic_vector(15 downto 0);
--type frame_12words_16bit is array (0 to 31) of std_logic_vector(15 downto 0);
----type frame_Mwords_16bit is array (0 to 15) of std_logic_vector(15 downto 0);
--type frame_Mwords_16bit is array (0 to 31) of std_logic_vector(15 downto 0);
----type frame_Mwords_8bit is array (0 to 31) of std_logic_vector(7 downto 0);
--type frame_Mwords_8bit is array (0 to 63) of std_logic_vector(7 downto 0);

--END frame_type;

library IEEE;

use IEEE.std_logic_1164.all;

PACKAGE frame_type is

TYPE frame_127word_24bit IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
TYPE frame_16word_8bit IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE frame_4word_24bit IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
TYPE frame_4word_8bit IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE frame_70word_24bit IS ARRAY (0 TO 69) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
TYPE frame_70word_8bit IS ARRAY (0 TO 69) OF STD_LOGIC_VECTOR (23 DOWNTO 0);

TYPE frame_50word_8bit IS ARRAY (0 TO 49) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE frame_10word_8bit IS ARRAY (0 TO 9) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE frame_20word_8bit IS ARRAY (0 TO 19) OF STD_LOGIC_VECTOR (7 DOWNTO 0);

type frame_8words_16bits is array (0 to 7) of std_logic_vector(15 downto 0);
type frame_8words_12bits is array (0 to 7) of std_logic_vector(11 downto 0);

TYPE PHASE_ARRAY IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (5 DOWNTO 0);
TYPE RX_ARRAY IS ARRAY (0 TO 49) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE frame_20words_8bit IS ARRAY (0 TO 19) OF STD_LOGIC_VECTOR (7 DOWNTO 0);
TYPE M_VALUE_ARRAY IS ARRAY (0 TO 15) OF STD_LOGIC_VECTOR (5 DOWNTO 0);
TYPE N_VALUE_ARRAY IS ARRAY (0 TO 7) OF STD_LOGIC_VECTOR (5 DOWNTO 0);
--TYPE CAL_ARRAY IS ARRAY (0 TO 63) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
TYPE DWELL_ARRAY IS ARRAY (0 TO 127) OF STD_LOGIC_VECTOR (23 DOWNTO 0);
TYPE DataReceived_array_type is array (0 to 15) of std_logic_vector(15 downto 0);
TYPE spi IS ARRAY (0 to 0) of STD_LOGIC_VECTOR (7 downto 0);
type freq_wise_data is array (0 to 8) of std_logic_vector(2047 downto 0);
type frame_6words_8bits is array (0 to 5) of std_logic_vector(7 downto 0);
--type frame_12words_16bit is array (0 to 11) of std_logic_vector(15 downto 0);
type frame_12words_16bit is array (0 to 31) of std_logic_vector(15 downto 0);
--type frame_Mwords_16bit is array (0 to 15) of std_logic_vector(15 downto 0);
type frame_Mwords_16bit is array (0 to 31) of std_logic_vector(15 downto 0);
--type frame_Mwords_8bit is array (0 to 31) of std_logic_vector(7 downto 0);
type frame_Mwords_8bit is array (0 to 63) of std_logic_vector(7 downto 0);


TYPE aws_frame_5word_24bit IS ARRAY (0 TO 4) OF STD_LOGIC_VECTOR (23 DOWNTO 0);

TYPE aws_frame_5word_8bit IS ARRAY (0 TO 4) OF STD_LOGIC_VECTOR (7 DOWNTO 0);



END frame_type;

