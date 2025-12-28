library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity command_decoder is
    Port (
        clk             : in  std_logic;
        rst             : in  std_logic;
        rx_data         : in  std_logic_vector(15 downto 0);
        rx_ready        : in  std_logic;
        -- Señales de control
        tx_enable       : out std_logic;  -- Controla si se permite transmitir
        single_sample   : out std_logic;
        sample_rate     : out std_logic_vector(7 downto 0);
        ping_received   : out std_logic;
        reset_system    : out std_logic
    );
end command_decoder;

architecture Behavioral of command_decoder is
    -- Códigos de comando
    constant CMD_RESUME_TX       : std_logic_vector(7 downto 0) := "00000001";  -- Recibe 10000000
    constant CMD_PAUSE_TX        : std_logic_vector(7 downto 0) := "10000000";  -- Recibe 11010101

    
    -- Señales internas
    signal tx_enable_reg : std_logic := '1';  -- Inicia HABILITADO para que funcione al arrancar
    signal rx_ready_prev : std_logic := '0';
    signal rx_ready_rising : std_logic := '0';
    
    -- Debug: capturar último comando
    signal last_command : std_logic_vector(7 downto 0) := (others => '0');
    
begin
    -- Detector de flanco de subida
    process(clk)
    begin
        if rising_edge(clk) then
            rx_ready_prev <= rx_ready;
            rx_ready_rising <= rx_ready and (not rx_ready_prev);
        end if;
    end process;
    
    -- Decodificador de comandos
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                tx_enable_reg <= '1';  -- Inicia transmitiendo
                single_sample <= '0';
                sample_rate <= x"01";
                ping_received <= '0';
                reset_system <= '0';
                last_command <= (others => '0');
            else
                -- Pulsos de 1 ciclo (por defecto en '0')
                single_sample <= '0';
                ping_received <= '0';
                reset_system <= '0';
                
                -- Detectar cuando llegan nuevos datos (flanco de subida de rx_ready)
                if rx_ready_rising = '1' then
                    -- Extraer comando (MSB = byte 1)
                    last_command <= rx_data(15 downto 8);
                    
                    -- Decodificar comando
                    case rx_data(15 downto 8) is
                        when CMD_RESUME_TX =>
                            tx_enable_reg <= '1';
                        
                        when CMD_PAUSE_TX =>
                            tx_enable_reg <= '0';
                       
                        
                        when others =>
                            -- Comando desconocido, no hacer nada
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;
    
    -- Asignar salida
    tx_enable <= tx_enable_reg;
    
end Behavioral;