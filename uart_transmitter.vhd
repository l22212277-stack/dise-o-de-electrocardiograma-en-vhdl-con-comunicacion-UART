library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_transmitter is
    Port (
        clk       : in  std_logic;              -- Clock principal
        rst       : in  std_logic;
        baud_tick : in  std_logic;              -- Enable signal
        tx_start  : in  std_logic;
        data_in   : in  std_logic_vector(7 downto 0);
        tx        : out std_logic;
        tx_done   : out std_logic
    );
end uart_transmitter;

architecture Behavioral of uart_transmitter is
    signal tx_shift_reg : std_logic_vector(9 downto 0) := (others => '1');
    signal bit_counter  : integer range 0 to 10 := 0;
    signal sending      : std_logic := '0';
    signal tx_reg       : std_logic := '1';
    signal tx_done_reg  : std_logic := '0';
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tx_shift_reg <= (others => '1');
                bit_counter <= 0;
                sending <= '0';
                tx_done_reg <= '0';
                tx_reg <= '1';
            else
                -- Capturar solicitud de transmisión
                if tx_start = '1' and sending = '0' then
                    tx_shift_reg <= '1' & data_in & '0';  -- Stop bit, data, start bit
                    sending <= '1';
                    bit_counter <= 0;
                    tx_done_reg <= '0';
                end if;
                
                -- Transmitir cuando hay baud_tick
                if baud_tick = '1' and sending = '1' then
                    if bit_counter < 10 then
                        tx_reg <= tx_shift_reg(bit_counter);
                        bit_counter <= bit_counter + 1;
                    else
                        tx_done_reg <= '1';
                        sending <= '0';
                        tx_reg <= '1';
                        bit_counter <= 0;
                    end if;
                elsif sending = '0' then
                    tx_done_reg <= '0';
                end if;
            end if;
        end if;
    end process;
    
    tx <= tx_reg;
    tx_done <= tx_done_reg;
end Behavioral;