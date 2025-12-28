library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_receiver is
    Port (
        clk       : in  std_logic;              -- Clock principal (100 MHz)
        rst       : in  std_logic;
        baud_tick : in  std_logic;              -- Enable signal a 9600 Hz
        rx        : in  std_logic;              -- Entrada UART
        data_out  : out std_logic_vector(15 downto 0); -- 2 bytes recibidos
        ready     : out std_logic               -- Pulso cuando datos están listos
    );
end uart_receiver;

architecture Behavioral of uart_receiver is
    -- Sincronización de rx (anti-metaestabilidad)
    signal rx_sync      : std_logic_vector(1 downto 0) := (others => '1');
    signal rx_stable    : std_logic := '1';
    
    -- Registro para almacenar los 2 bytes
    signal byte_buffer  : std_logic_vector(15 downto 0) := (others => '0');
    
    -- Contadores y estados
    signal bit_counter  : integer range 0 to 9 := 0;
    signal byte_counter : integer range 0 to 2 := 0;
    
    -- Máquina de estados
    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;
    
    -- Registro temporal para el byte actual
    signal current_byte : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Señales de salida registradas
    signal ready_reg    : std_logic := '0';
    signal data_out_reg : std_logic_vector(15 downto 0) := (others => '0');
    
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset completo
                rx_sync <= (others => '1');
                rx_stable <= '1';
                byte_buffer <= (others => '0');
                bit_counter <= 0;
                byte_counter <= 0;
                state <= IDLE;
                current_byte <= (others => '0');
                ready_reg <= '0';
                data_out_reg <= (others => '0');
                
            else
                -- Sincronización de rx con 2 flip-flops
                rx_sync <= rx_sync(0) & rx;
                rx_stable <= rx_sync(1);
                
                -- Por defecto, ready es un pulso de 1 ciclo
                ready_reg <= '0';
                
                -- Solo procesar en los pulsos de baud_tick
                if baud_tick = '1' then
                    case state is
                        when IDLE =>
                            bit_counter <= 0;
                            -- Detectar bit de inicio (flanco de bajada)
                            if rx_stable = '0' then
                                state <= START_BIT;
                            end if;
                        
                        when START_BIT =>
                            -- Verificar que sigue siendo '0' (bit de inicio válido)
                            if rx_stable = '0' then
                                bit_counter <= 0;
                                current_byte <= (others => '0');
                                state <= DATA_BITS;
                            else
                                -- Falsa alarma, volver a IDLE
                                state <= IDLE;
                            end if;
                        
                        when DATA_BITS =>
                            -- Recibir 8 bits de datos (LSB primero)
                            if bit_counter < 8 then
                                current_byte(bit_counter) <= rx_stable;
                                bit_counter <= bit_counter + 1;
                            else
                                state <= STOP_BIT;
                            end if;
                        
                        when STOP_BIT =>
                            -- Verificar bit de parada
                            if rx_stable = '1' then
                                -- Bit de parada válido, almacenar byte
                                if byte_counter = 0 then
                                    -- Primer byte (MSB) va a bits 15:8
                                    byte_buffer(15 downto 8) <= current_byte;
                                    byte_counter <= 1;
                                    state <= IDLE;
                                    
                                elsif byte_counter = 1 then
                                    -- Segundo byte (LSB) va a bits 7:0
                                    byte_buffer(7 downto 0) <= current_byte;
                                    byte_counter <= 0;
                                    
                                    -- Transferir a salida y generar pulso ready
                                    data_out_reg <= byte_buffer(15 downto 8) & current_byte;
                                    ready_reg <= '1';
                                    state <= IDLE;
                                end if;
                            else
                                -- Error en bit de parada, descartar y volver a IDLE
                                state <= IDLE;
                                byte_counter <= 0;
                            end if;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    -- Asignar salidas
    data_out <= data_out_reg;
    ready <= ready_reg;
    
end Behavioral;