library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_controller is
    Port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        value : in  integer range 0 to 200;
        seg   : out STD_LOGIC_VECTOR(6 downto 0);
        an    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end display_controller;

architecture Behavioral of display_controller is
    
    signal mux_counter : integer range 0 to 2000000 := 0;
    signal mux_select  : integer range 0 to 2 := 0;
    
    signal digit0 : integer range 0 to 9;  -- Centenas
    signal digit1 : integer range 0 to 9;  -- Decenas
    signal digit2 : integer range 0 to 9;  -- Unidades
    
    signal current_digit : integer range 0 to 9;
    
begin
    
    -- Convertir valor a 3 dígitos BCD
    process(clk, rst)
        variable temp : integer;
    begin
        if rst = '1' then
            digit0 <= 0;
            digit1 <= 0;
            digit2 <= 0;
        elsif rising_edge(clk) then
            temp := value;
            digit0 <= temp / 100;           -- Centenas
            temp := temp mod 100;
            digit1 <= temp / 10;             -- Decenas
            digit2 <= temp mod 10;           -- Unidades
        end if;
    end process;
    
    -- Divisor para multiplexación a 30 Hz (33ms por dígito)
    process(clk, rst)
    begin
        if rst = '1' then
            mux_counter <= 0;
            mux_select <= 0;
        elsif rising_edge(clk) then
            if mux_counter = 416666 then
                mux_counter <= 0;
                if mux_select = 2 then
                    mux_select <= 0;
                else
                    mux_select <= mux_select + 1;
                end if;
            else
                mux_counter <= mux_counter + 1;
            end if;
        end if;
    end process;
    
    -- Seleccionar dígito y ánodo activo
    -- Orden verificado: Derecha (0) → Centro (1) → Izquierda (2)
    process(mux_select, digit0, digit1, digit2)
    begin
        case mux_select is
            when 0 =>
                current_digit <= digit2;     -- Unidades (DERECHA)
                an <= "1110";                -- an[0] = 0 (activo)
            when 1 =>
                current_digit <= digit1;     -- Decenas (CENTRO)
                an <= "1101";                -- an[1] = 0 (activo)
            when 2 =>
                current_digit <= digit0;     -- Centenas (IZQUIERDA)
                an <= "1011";                -- an[2] = 0 (activo)
            when others =>
                current_digit <= 0;
                an <= "1111";
        end case;
    end process;
    
    -- Decodificador BCD a 7-segmentos
    -- XDC Mapeo: seg[6:0] = GFEDCBA
    -- Para mostrar un dígito: '0' = segmento encendido, '1' = apagado
    -- Patrón de segmentos:
    --      A (seg[0])
    --     ----
    --    |     |
    --  F|     | B
    --   |(seg[1])
    --    | G |
    --    |---(seg[6])
    --    |     |
    --  E|     | C
    --   |(seg[2])
    --    |-----|
    --      D (seg[3])
    --    (seg[4])
    --    (seg[5])
    process(current_digit)
    begin
        case current_digit is
            -- gfedcba (seg[6:0]) - '0'=encendido, '1'=apagado
            when 0 => seg <= "1000000";  -- A,B,C,D,E,F (NO G)
            when 1 => seg <= "1001111";  -- B,C (NO A,D,E,F,G)
            when 2 => seg <= "0100100";  -- A,B,D,E,G (NO C,F)
            when 3 => seg <= "0110000";  -- A,B,C,D,G (NO E,F)
            when 4 => seg <= "0011001";  -- B,C,F,G (NO A,D,E)
            when 5 => seg <= "0010010";  -- A,C,D,F,G (NO B,E)
            when 6 => seg <= "0000010";  -- A,C,D,E,F,G (NO B)
            when 7 => seg <= "1111000";  -- A,B,C (NO D,E,F,G)
            when 8 => seg <= "0000000";  -- A,B,C,D,E,F,G (todos)
            when 9 => seg <= "0010000";  -- A,B,C,D,F,G (NO E)
            when others => seg <= "1111111";
        end case;
    end process;
    
end Behavioral;