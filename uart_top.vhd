library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_xadc_top is
    Port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        rx      : in  std_logic;
        tx      : out std_logic;
        vauxp6  : in  std_logic;
        vauxn6  : in  std_logic;
        -- Display de 7 segmentos
        seg     : out std_logic_vector(6 downto 0);
        an      : out std_logic_vector(3 downto 0);
        -- DEBUG: LEDs
        led     : out std_logic_vector(15 downto 0)
    );
end uart_xadc_top;

architecture Behavioral of uart_xadc_top is
    
    -- =====================================================
    -- SEÑALES DE RELOJ
    -- =====================================================
    signal clk_250hz : std_logic;
    signal baud_tick : std_logic;
    
    -- =====================================================
    -- SEÑALES UART RX/TX
    -- =====================================================
    signal rx_data       : std_logic_vector(15 downto 0);
    signal rx_ready      : std_logic;
    signal tx_data       : std_logic_vector(7 downto 0);
    signal tx_start      : std_logic;
    signal tx_done       : std_logic;
    
    -- Señales de comando
    signal tx_enable     : std_logic;
    signal ping_received : std_logic;
    
    -- =====================================================
    -- SEÑALES XADC
    -- =====================================================
    signal adc_data       : std_logic_vector(15 downto 0);
    signal adc_data_ready : std_logic;
    
    -- =====================================================
    -- SEÑALES CADENA DE PROCESAMIENTO
    -- =====================================================
    signal cnt_cycles : integer range 0 to 300;
    signal cnt_ready  : std_logic;
    
    signal fifo_sum   : integer range 0 to 3000;
    signal fifo_ready : std_logic;
    
    signal fc_bpm     : integer range 40 to 200;
    
    -- =====================================================
    -- FSM UART TX
    -- =====================================================
    type tx_state_type is (IDLE, SEND_PING, WAIT_PING, 
                          SEND_MSB, WAIT_MSB, SEND_LSB, WAIT_LSB);
    signal tx_state         : tx_state_type := IDLE;
    signal adc_data_latched : std_logic_vector(15 downto 0);
    signal ping_pending     : std_logic := '0';
    
begin
    
    -- =====================================================
    -- GENERADOR DE RELOJ 250Hz
    -- =====================================================
    clk250_inst : entity work.Divisor_Frecuencia
        port map (
            clk     => clk,
            rst     => rst,
            clk_out => clk_250hz
        );
    
    -- =====================================================
    -- MÓDULOS UART
    -- =====================================================
    baud_gen_inst : entity work.baud_rate_generator
        port map (
            clk       => clk,
            rst       => rst,
            baud_tick => baud_tick
        );
    
    uart_rx_inst : entity work.uart_receiver
        port map (
            clk       => clk,
            rst       => rst,
            baud_tick => baud_tick,
            rx        => rx,
            data_out  => rx_data,
            ready     => rx_ready
        );
    
    cmd_decoder_inst : entity work.command_decoder
        port map (
            clk           => clk,
            rst           => rst,
            rx_data       => rx_data,
            rx_ready      => rx_ready,
            tx_enable     => tx_enable,
            ping_received => ping_received
        );
    
    uart_tx_inst : entity work.uart_transmitter
        port map (
            clk       => clk,
            rst       => rst,
            baud_tick => baud_tick,
            tx_start  => tx_start,
            data_in   => tx_data,
            tx        => tx,
            tx_done   => tx_done
        );
    
    -- =====================================================
    -- MÓDULO XADC
    -- =====================================================
    xadc_reader_inst : entity work.xadc_reader
        port map (
            clk            => clk,
            rst            => rst,
            vauxp6         => vauxp6,
            vauxn6         => vauxn6,
            adc_data       => adc_data,
            adc_data_ready => adc_data_ready
        );
    
    -- =====================================================
    -- CADENA DE PROCESAMIENTO FRECUENCIA CARDÍACA
    -- =====================================================
    
    -- 1. Detecta picos en ECG y cuenta ciclos entre ellos
    u_contador : entity work.contador
        port map (
            clk_250hz  => clk_250hz,
            rst        => rst,
            adc_data   => adc_data,
            adc_ready  => adc_data_ready,
            cycles_out => cnt_cycles,
            ready_out  => cnt_ready
        );
    
    -- 2. FIFO: Promedia 10 mediciones de ciclos
    u_fifo : entity work.fifo
        port map (
            clk       => clk_250hz,
            rst       => rst,
            data_in   => cnt_cycles,
            valid     => cnt_ready,
            data_out  => fifo_sum,
            ready_out => fifo_ready
        );
    
    -- 3. ROM: Convierte suma de ciclos a BPM
    u_romfc : entity work.ROMFC
        port map (
            clk_250hz => clk_250hz,
            rst       => rst,
            datain    => fifo_sum,
            dataout   => fc_bpm,
            valid     => fifo_ready
        );
    
    -- =====================================================
    -- DISPLAY 7-SEGMENTOS
    -- =====================================================
    u_display : entity work.display_controller
        port map (
            clk   => clk,
            rst   => rst,
            value => fc_bpm,
            seg   => seg,
            an    => an
        );
    
    -- =====================================================
    -- FSM UART TX (PING + DATOS ADC)
    -- =====================================================
    
    -- Capturar solicitud de ping
    process(clk, rst)
    begin
        if rst = '1' then
            ping_pending <= '0';
        elsif rising_edge(clk) then
            if ping_received = '1' then
                ping_pending <= '1';
            elsif tx_state = SEND_PING then
                ping_pending <= '0';
            end if;
        end if;
    end process;
    
    -- FSM para transmisión
    process(clk, rst)
    begin
        if rst = '1' then
            tx_state <= IDLE;
            tx_start <= '0';
            tx_data <= (others => '0');
            adc_data_latched <= (others => '0');
        elsif rising_edge(clk) then
            case tx_state is
                when IDLE =>
                    tx_start <= '0';
                    
                    -- Prioridad 1: Responder PING
                    if ping_pending = '1' then
                        tx_data <= x"BB";
                        tx_state <= SEND_PING;
                    
                    -- Prioridad 2: Enviar datos ADC
                    elsif adc_data_ready = '1' and tx_enable = '1' then
                        adc_data_latched <= adc_data;
                        tx_state <= SEND_MSB;
                    end if;
                
                when SEND_PING =>
                    tx_start <= '1';
                    tx_state <= WAIT_PING;
                
                when WAIT_PING =>
                    tx_start <= '0';
                    if tx_done = '1' then
                        tx_state <= IDLE;
                    end if;
                
                when SEND_MSB =>
                    tx_data <= adc_data_latched(15 downto 8);
                    tx_start <= '1';
                    tx_state <= WAIT_MSB;
                
                when WAIT_MSB =>
                    tx_start <= '0';
                    if tx_done = '1' then
                        tx_state <= SEND_LSB;
                    end if;
                
                when SEND_LSB =>
                    tx_data <= adc_data_latched(7 downto 0);
                    tx_start <= '1';
                    tx_state <= WAIT_LSB;
                
                when WAIT_LSB =>
                    tx_start <= '0';
                    if tx_done = '1' then
                        tx_state <= IDLE;
                    end if;
            end case;
        end if;
    end process;
    
    -- =====================================================
    -- LEDs DE DEBUG
    -- =====================================================
    -- Mostrar el valor de FC en los LEDs inferiores
    process(clk, rst)
        variable fc_bits : std_logic_vector(15 downto 0);
    begin
        if rst = '1' then
            led <= (others => '0');
        elsif rising_edge(clk) then
            fc_bits := std_logic_vector(to_unsigned(fc_bpm, 16));
            led(15 downto 0) <= fc_bits;
        end if;
    end process;
    
end Behavioral;