library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Divisor_Frecuencia is
    Port ( 
        clk  : in  STD_LOGIC; -- Reloj de 100 MHz
        rst   : in  STD_LOGIC; -- Reset (activo en alto)
        clk_out : out STD_LOGIC  -- Reloj de 250 Hz
    );
end Divisor_Frecuencia;

architecture Behavioral of Divisor_Frecuencia is
    -- Constante para el conteo: (100 MHz / 250 Hz) / 2 - 1
    -- 400,000 / 2 = 200,000. Menos 1 porque contamos desde 0 = 199,999
    constant MAX_COUNT : integer := 199999;
    
    -- Señales internas
    signal count : integer range 0 to MAX_COUNT := 0;
    signal temporal : STD_LOGIC := '0';
    
begin

    process (clk, rst)
    begin
        -- Reset asíncrono
        if rst = '1' then
            count <= 0;
            temporal <= '0';
        
        -- Lógica síncrona en el flanco de subida
        elsif rising_edge(clk) then
            if count = MAX_COUNT then
                temporal <= not temporal; -- Invierte la salida (Toggle)
                count <= 0;               -- Reinicia el contador
            else
                count <= count + 1;       -- Incrementa el contador
            end if;
        end if;
    end process;

    -- Asignación de la señal interna a la salida
    clk_out <= temporal;

end Behavioral;
