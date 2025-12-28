library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity baud_rate_generator is
    Port (
        clk       : in  std_logic;  -- 100 MHz
        rst       : in  std_logic;
        baud_tick : out std_logic   -- Pulso de 1 ciclo a 9600 Hz
    );
end baud_rate_generator;

architecture Behavioral of baud_rate_generator is
    -- Para 9600 baudios: 100,000,000 / 9600 = 10,416.67 ≈ 10417
    constant MAX_COUNT : integer := 10417;
    signal counter     : integer range 0 to MAX_COUNT-1 := 0;
    signal tick_reg    : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
                tick_reg <= '0';
            else
                -- Por defecto, el tick está en '0'
                tick_reg <= '0';
                
                if counter = MAX_COUNT-1 then
                    -- Generar pulso de 1 ciclo
                    counter <= 0;
                    tick_reg <= '1';  -- PULSO de 1 ciclo
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    baud_tick <= tick_reg;
end Behavioral;