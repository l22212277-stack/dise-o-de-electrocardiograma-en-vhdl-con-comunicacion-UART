library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity contador is
    Port ( 
        clk_250hz   : in  STD_LOGIC;            -- Clock de 250 Hz (sincronizado)
        rst         : in  STD_LOGIC;
        adc_data    : in  STD_LOGIC_VECTOR(15 downto 0);
        adc_ready   : in  STD_LOGIC;
        cycles_out  : out integer range 0 to 300;
        ready_out   : out STD_LOGIC
    );
end contador;

architecture Behavioral of contador is
    
    constant THRESHOLD      : unsigned(11 downto 0) := x"800";  -- 2048 (mitad de 4096)
    constant MIN_PEAK_DIST  : integer := 50;                     -- Mínimo 200ms entre picos
    
    signal adc_value_sync   : unsigned(11 downto 0);
    signal prev_sample      : unsigned(11 downto 0) := (others => '0');
    signal ready_for_peak   : std_logic := '1';
    
    signal cycle_count      : integer range 0 to 300 := 0;
    signal data_reg         : integer range 0 to 300 := 0;
    signal ready_reg        : std_logic := '0';
    
begin
    
    -- Extraer 12 bits significativos (bits [15:4] del XADC)
    adc_value_sync <= unsigned(adc_data(15 downto 4));
    
    process(clk_250hz, rst)
    begin
        if rst = '1' then
            cycle_count <= 0;
            ready_for_peak <= '1';
            data_reg <= 0;
            ready_reg <= '0';
            prev_sample <= (others => '0');
            
        elsif rising_edge(clk_250hz) then
            ready_reg <= '0';  -- Por defecto, sin nuevo dato válido
            
            -- Detectar flanco ascendente: cruce de umbral hacia arriba
            if ready_for_peak = '1' then
                if (prev_sample < THRESHOLD) and (adc_value_sync >= THRESHOLD) then
                    -- Pico detectado
                    data_reg <= cycle_count;
                    
                    -- Validar: solo si hay suficientes ciclos (>50 = 200ms)
                    if cycle_count > MIN_PEAK_DIST then
                        ready_reg <= '1';
                    end if;
                    
                    cycle_count <= 0;
                    ready_for_peak <= '0';  -- Bloquear detección (período refractario)
                else
                    cycle_count <= cycle_count + 1;
                end if;
            else
                -- En período refractario, seguir contando
                cycle_count <= cycle_count + 1;
                
                -- Reactivar detección cuando baja del umbral y han pasado >10 ciclos (40ms)
                if (adc_value_sync < THRESHOLD) and (cycle_count > 10) then
                    ready_for_peak <= '1';
                end if;
            end if;
            
            -- Actualizar muestra anterior para próximo ciclo
            prev_sample <= adc_value_sync;
        end if;
    end process;
    
    cycles_out <= data_reg;
    ready_out <= ready_reg;
    
end Behavioral;