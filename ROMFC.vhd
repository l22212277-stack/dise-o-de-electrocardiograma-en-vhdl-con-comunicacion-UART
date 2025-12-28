library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROMFC is
    Port (
        clk_250hz : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        datain    : in  integer range 0 to 4000;
        dataout   : out integer range 40 to 200;
        valid     : in  STD_LOGIC
    );
end ROMFC;

architecture Behavioral of ROMFC is
    signal data_out : integer range 40 to 200 := 100;
begin
    
    process(clk_250hz, rst)
    begin
        if rst = '1' then
            data_out <= 100;
            
        elsif rising_edge(clk_250hz) then
            if valid = '1' then
                -- Tabla de conversión: ciclos acumulados a BPM
                -- Fórmula base: BPM = 15000 / (suma_ciclos / 10)
                
                if    datain >= 3659 then data_out <= 40;
                elsif datain >= 3571 then data_out <= 41;
                elsif datain >= 3488 then data_out <= 42;
                elsif datain >= 3409 then data_out <= 43;
                elsif datain >= 3333 then data_out <= 44;
                elsif datain >= 3261 then data_out <= 45;
                elsif datain >= 3191 then data_out <= 46;
                elsif datain >= 3125 then data_out <= 47;
                elsif datain >= 3061 then data_out <= 48;
                elsif datain >= 3000 then data_out <= 49;
                elsif datain >= 2941 then data_out <= 50;
                elsif datain >= 2885 then data_out <= 51;
                elsif datain >= 2830 then data_out <= 52;
                elsif datain >= 2778 then data_out <= 53;
                elsif datain >= 2727 then data_out <= 54;
                elsif datain >= 2679 then data_out <= 55;
                elsif datain >= 2632 then data_out <= 56;
                elsif datain >= 2586 then data_out <= 57;
                elsif datain >= 2542 then data_out <= 58;
                elsif datain >= 2500 then data_out <= 59;
                elsif datain >= 2459 then data_out <= 60;
                elsif datain >= 2419 then data_out <= 61;
                elsif datain >= 2381 then data_out <= 62;
                elsif datain >= 2344 then data_out <= 63;
                elsif datain >= 2308 then data_out <= 64;
                elsif datain >= 2273 then data_out <= 65;
                elsif datain >= 2239 then data_out <= 66;
                elsif datain >= 2206 then data_out <= 67;
                elsif datain >= 2174 then data_out <= 68;
                elsif datain >= 2143 then data_out <= 69;
                elsif datain >= 2113 then data_out <= 70;
                elsif datain >= 2083 then data_out <= 71;
                elsif datain >= 2055 then data_out <= 72;
                elsif datain >= 2027 then data_out <= 73;
                elsif datain >= 2000 then data_out <= 74;
                elsif datain >= 1974 then data_out <= 75;
                elsif datain >= 1948 then data_out <= 76;
                elsif datain >= 1923 then data_out <= 77;
                elsif datain >= 1899 then data_out <= 78;
                elsif datain >= 1875 then data_out <= 79;
                elsif datain >= 1852 then data_out <= 80;
                elsif datain >= 1829 then data_out <= 81;
                elsif datain >= 1807 then data_out <= 82;
                elsif datain >= 1786 then data_out <= 83;
                elsif datain >= 1765 then data_out <= 84;
                elsif datain >= 1744 then data_out <= 85;
                elsif datain >= 1724 then data_out <= 86;
                elsif datain >= 1705 then data_out <= 87;
                elsif datain >= 1685 then data_out <= 88;
                elsif datain >= 1667 then data_out <= 89;
                elsif datain >= 1648 then data_out <= 90;
                elsif datain >= 1630 then data_out <= 91;
                elsif datain >= 1613 then data_out <= 92;
                elsif datain >= 1596 then data_out <= 93;
                elsif datain >= 1579 then data_out <= 94;
                elsif datain >= 1562 then data_out <= 95;
                elsif datain >= 1546 then data_out <= 96;
                elsif datain >= 1531 then data_out <= 97;
                elsif datain >= 1515 then data_out <= 98;
                elsif datain >= 1500 then data_out <= 99;
                elsif datain >= 1485 then data_out <= 100;
                elsif datain >= 1471 then data_out <= 101;
                elsif datain >= 1456 then data_out <= 102;
                elsif datain >= 1442 then data_out <= 103;
                elsif datain >= 1429 then data_out <= 104;
                elsif datain >= 1415 then data_out <= 105;
                elsif datain >= 1402 then data_out <= 106;
                elsif datain >= 1389 then data_out <= 107;
                elsif datain >= 1376 then data_out <= 108;
                elsif datain >= 1364 then data_out <= 109;
                elsif datain >= 1351 then data_out <= 110;
                elsif datain >= 1339 then data_out <= 111;
                elsif datain >= 1327 then data_out <= 112;
                elsif datain >= 1316 then data_out <= 113;
                elsif datain >= 1304 then data_out <= 114;
                elsif datain >= 1293 then data_out <= 115;
                elsif datain >= 1282 then data_out <= 116;
                elsif datain >= 1271 then data_out <= 117;
                elsif datain >= 1261 then data_out <= 118;
                elsif datain >= 1250 then data_out <= 119;
                elsif datain >= 1240 then data_out <= 120;
                elsif datain >= 1230 then data_out <= 121;
                elsif datain >= 1220 then data_out <= 122;
                elsif datain >= 1210 then data_out <= 123;
                elsif datain >= 1200 then data_out <= 124;
                elsif datain >= 1190 then data_out <= 125;
                elsif datain >= 1181 then data_out <= 126;
                elsif datain >= 1172 then data_out <= 127;
                elsif datain >= 1163 then data_out <= 128;
                elsif datain >= 1154 then data_out <= 129;
                elsif datain >= 1145 then data_out <= 130;
                elsif datain >= 1136 then data_out <= 131;
                elsif datain >= 1128 then data_out <= 132;
                elsif datain >= 1119 then data_out <= 133;
                elsif datain >= 1111 then data_out <= 134;
                elsif datain >= 1103 then data_out <= 135;
                elsif datain >= 1095 then data_out <= 136;
                elsif datain >= 1087 then data_out <= 137;
                elsif datain >= 1079 then data_out <= 138;
                elsif datain >= 1071 then data_out <= 139;
                elsif datain >= 1064 then data_out <= 140;
                elsif datain >= 1056 then data_out <= 141;
                elsif datain >= 1049 then data_out <= 142;
                elsif datain >= 1042 then data_out <= 143;
                elsif datain >= 1034 then data_out <= 144;
                elsif datain >= 1027 then data_out <= 145;
                elsif datain >= 1020 then data_out <= 146;
                elsif datain >= 1014 then data_out <= 147;
                elsif datain >= 1007 then data_out <= 148;
                elsif datain >= 1000 then data_out <= 149;
                elsif datain >= 993  then data_out <= 150;
                elsif datain >= 987  then data_out <= 151;
                elsif datain >= 980  then data_out <= 152;
                elsif datain >= 974  then data_out <= 153;
                elsif datain >= 968  then data_out <= 154;
                elsif datain >= 962  then data_out <= 155;
                elsif datain >= 955  then data_out <= 156;
                elsif datain >= 949  then data_out <= 157;
                elsif datain >= 943  then data_out <= 158;
                elsif datain >= 938  then data_out <= 159;
                elsif datain >= 932  then data_out <= 160;
                elsif datain >= 926  then data_out <= 161;
                elsif datain >= 920  then data_out <= 162;
                elsif datain >= 915  then data_out <= 163;
                elsif datain >= 909  then data_out <= 164;
                elsif datain >= 904  then data_out <= 165;
                elsif datain >= 898  then data_out <= 166;
                elsif datain >= 893  then data_out <= 167;
                elsif datain >= 888  then data_out <= 168;
                elsif datain >= 882  then data_out <= 169;
                elsif datain >= 877  then data_out <= 170;
                elsif datain >= 872  then data_out <= 171;
                elsif datain >= 867  then data_out <= 172;
                elsif datain >= 862  then data_out <= 173;
                elsif datain >= 857  then data_out <= 174;
                elsif datain >= 852  then data_out <= 175;
                elsif datain >= 847  then data_out <= 176;
                elsif datain >= 843  then data_out <= 177;
                elsif datain >= 838  then data_out <= 178;
                elsif datain >= 833  then data_out <= 179;
                elsif datain >= 829  then data_out <= 180;
                else
                    data_out <= 200;
                end if;
            end if;
        end if;
    end process;
    
    dataout <= data_out;
    
end Behavioral;