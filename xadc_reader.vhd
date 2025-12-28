library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity xadc_reader is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        -- Conexión al XADC Wizard
        vauxp6        : in  std_logic;  -- Pin analógico positivo
        vauxn6        : in  std_logic;  -- Pin analógico negativo
        -- Salida de datos
        adc_data      : out std_logic_vector(15 downto 0);
        adc_data_ready: out std_logic
    );
end xadc_reader;

architecture Behavioral of xadc_reader is
    -- Componente XADC Wizard (generado por Vivado)
    component xadc_wiz_0
        port (
            daddr_in   : in  std_logic_vector(6 downto 0);
            dclk_in    : in  std_logic;
            den_in     : in  std_logic;
            di_in      : in  std_logic_vector(15 downto 0);
            dwe_in     : in  std_logic;
            reset_in   : in  std_logic;
            vauxp6     : in  std_logic;
            vauxn6     : in  std_logic;
            do_out     : out std_logic_vector(15 downto 0);
            drdy_out   : out std_logic;
            eoc_out    : out std_logic;
            busy_out   : out std_logic;
            channel_out: out std_logic_vector(4 downto 0)
        );
    end component;
    
    -- Señales internas
    signal daddr      : std_logic_vector(6 downto 0) := "0010110"; -- 0x16 para VAUX6
    signal den        : std_logic := '0';
    signal di         : std_logic_vector(15 downto 0) := (others => '0');
    signal dwe        : std_logic := '0';
    signal do_out     : std_logic_vector(15 downto 0);
    signal drdy       : std_logic;
    signal eoc        : std_logic;
    signal busy       : std_logic;
    signal channel    : std_logic_vector(4 downto 0);
    
    signal clk_div    : std_logic := '0';
    signal counter    : integer range 0 to 1 := 0;
    
begin
    -- Generar reloj de 50MHz para el XADC (desde 100MHz)
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                counter <= 0;
                clk_div <= '0';
            else
                if counter = 1 then
                    counter <= 0;
                    clk_div <= not clk_div;
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Instancia del XADC
    xadc_inst : xadc_wiz_0
        port map (
            daddr_in    => daddr,
            dclk_in     => clk_div,  -- 50MHz
            den_in      => eoc,      -- Leer en cada conversión completa
            di_in       => di,
            dwe_in      => dwe,
            reset_in    => rst,
            vauxp6      => vauxp6,
            vauxn6      => vauxn6,
            do_out      => do_out,
            drdy_out    => drdy,
            eoc_out     => eoc,
            busy_out    => busy,
            channel_out => channel
        );
    
    -- Proceso para capturar datos cuando están listos
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                adc_data <= (others => '0');
                adc_data_ready <= '0';
            else
                if drdy = '1' then
                    -- El XADC devuelve 12 bits en los bits [15:4]
                    -- Los desplazamos para obtener el valor completo
                    adc_data <= do_out;
                    adc_data_ready <= '1';
                else
                    adc_data_ready <= '0';
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;