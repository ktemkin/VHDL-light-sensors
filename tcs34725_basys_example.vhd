-- The MIT License (MIT)
-- 
-- Copyright (c) 2014 Kyle J. Temkin <ktemkin@binghamton.edu>
-- Copyright (c) 2014 Binghamton University
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this firmware and associated documentation files (the "firmware"), to deal
-- in the firmware without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the firmware, and to permit persons to whom the firmware is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the firmware.
-- 
-- THE FIRMWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE FIRMWARE OR THE USE OR OTHER DEALINGS IN
-- THE FIRMWARE.

--
-- Basys board example of a simple TCS34725 driver.
--
-- Steps to use:
--  --Connect SDA to the left-most pin, which has site location B2.
--  --Connect SCL to the pin directly to the right, which has site location A3.
--  --Connect I2C light sensor to 3.3V power supply. Observe readings on seven-segment
--    display!
--
--  You can adjust which of the sensors you're reading from using SW(1 downto 0),
--  as follows:
--      00 | Clear
--      01 | Red
--      10 | Green
--      11 | Blue
--  
--  Pull-up reistors are optional, as the Basys' board's internal pull-ups are engaged,
--  but their use is recommended. If you do choose to use them, you may want to remove
--  the PULLUP directive from these pins in the UCF, to save power.
--


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tcs34725_basys_example is
  port(

    --System clock.
    clk   : in std_logic;
    reset : in std_logic := '0';
    
    --TWI/I2C signals.
    sda : inout std_logic;
    scl : inout std_logic;

    --Color selection inputs
    sw  : in std_logic_vector(1 downto 0);

    --Seven segment display outputs.
    seg : out std_logic_vector(6 downto 0);
    an  : out std_logic_vector(3 downto 0)
  );
end tcs34725_basys_example;

architecture Behavioral of tcs34725_basys_example is
  signal active_intensity, clear_intensity, red_intensity,
         green_intensity, blue_intensity : std_logic_vector(15 downto 0);
begin

  --
  -- Instantiate our TCS34725 controller.
  -- 
  SENSOR_INTERFACE:
  entity tcs34725_interface generic map(

    --The clock frequency of the board you're using.
    --For the Basys board, this is usually 50MHz, or 50_000_000.
    clk_frequency => 50_000_000,

    --The I2C clock frequency. This can be any number below 400kHz for the TCS34725.
    i2c_frequency => 100_000
  )
  port map(
    clk             => clk,
    reset           => reset,
    sda             => sda,
    scl             => scl,
    clear_intensity => clear_intensity,
    red_intensity   => red_intensity,
    green_intensity => green_intensity,
    blue_intensity  => blue_intensity
  );


  --
  -- Simple multiplexer which selects the channel that we're looking at.
  --
  with sw 
  select active_intensity <=
    clear_intensity when "00",
    red_intensity   when "01",
    green_intensity when "10",
    blue_intensity  when others;


  --
  -- Instatiate a seven-segment display driver.
  --
  SSEG_DISPLAY_DRIVER:
  entity sseg_driver port map(
    clk          => clk,
    leftmost     => active_intensity(15 downto 12),
    left_center  => active_intensity(11 downto 8),
    right_center => active_intensity(7 downto 4),
    rightmost    => active_intensity(3 downto 0),
    cathodes     => seg,
    anodes       => an
  );



end Behavioral;

