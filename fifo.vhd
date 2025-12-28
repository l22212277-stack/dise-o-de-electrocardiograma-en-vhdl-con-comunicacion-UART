library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo is
    Port (
        clk       : in  STD_LOGIC;                     -- Clock principal (100 MHz)
        rst       : in  STD_LOGIC;
        data_in   : in  integer range 0 to 300;        -- Ciclos entre picos
        valid     : in  std_logic;                     -- Pulso cuando hay nuevo dato
        data_out  : out integer range 0 to 3000;       -- Suma de 10 mediciones
        ready_out : out STD_LOGIC                      -- Pulso cuando hay suma lista
    );
end fifo;

architecture Behavioral of fifo is
    -- Buffer circular de 10 elementos
    type fifo_array is array (0 to 9) of integer range 0 to 300;
    signal fifo_mem     : fifo_array := (others => 0);
    signal index        : integer range 0 to 9 := 0;
    signal count_valid  : integer range 0 to 10 := 0;
    signal suma_total   : integer range 0 to 3000 := 0;
    signal ready_reg    : std_logic := '0';
    
    -- Para detectar flanco de subida de valid
    signal valid_prev   : std_logic := '0';
    signal valid_rising : std_logic := '0';

begin

    -- Detector de flanco de subida de valid
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                valid_prev <= '0';
            else
                valid_prev <= valid;
            end if;
        end if;
    end process;
    
    valid_rising <= valid and (not valid_prev);

    -- Proceso principal del FIFO
    process(clk)
        variable sum_var : integer range 0 to 3000;
        variable i       : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                fifo_mem    <= (others => 0);
                index       <= 0;
                count_valid <= 0;
                suma_total  <= 0;
                ready_reg   <= '0';
                
            else
                ready_reg <= '0';  -- Por defecto en '0'
                
                -- Procesar solo en flanco de subida de valid
                if valid_rising = '1' then
                    -- Almacenar nuevo dato
                    fifo_mem(index) <= data_in;
                    
                    -- Incrementar índice circular
                    if index = 9 then
                        index <= 0;
                    else
                        index <= index + 1;
                    end if;

                    -- Contar datos válidos hasta llenar el buffer
                    if count_valid < 10 then
                        count_valid <= count_valid + 1;
                    end if;

                    -- Calcular suma cuando hay 10 datos válidos
                    if count_valid = 10 then
                        sum_var := 0;
                        for i in 0 to 9 loop
                            sum_var := sum_var + fifo_mem(i);
                        end loop;
                        
                        suma_total <= sum_var;
                        ready_reg  <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    data_out  <= suma_total;
    ready_out <= ready_reg;

end Behavioral;