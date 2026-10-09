
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity four_bit_alu is
    port (
        A         : in  std_logic_vector(3 downto 0);
        B         : in  std_logic_vector(3 downto 0);
        opreation : in  std_logic_vector(2 downto 0);
        result    : out std_logic_vector(3 downto 0);
        carry     : out std_logic;
        zero      : out std_logic
    );
end entity four_bit_alu;

architecture behv of four_bit_alu is
begin
    process(A, B, opreation)
        variable temp : unsigned(4 downto 0);
        variable b_inv : unsigned(4 downto 0);
        variable product : unsigned(7 downto 0);
        variable res_temp : unsigned(3 downto 0);

        -- CHANGED: Removed "in" because variables cannot have input modes.
        variable carry_temp : std_logic;
    begin
        temp := (others => '0');
        res_temp := (others => '0');

        -- ADDED: Initialize product to avoid retaining an old value.
        product := (others => '0');

        carry_temp := '0';

        case opreation is
            when "000" =>
                temp := resize(unsigned(A), 5)
                      + resize(unsigned(B), 5);

                -- CHANGED: Store the lower four bits in res_temp.
                res_temp := temp(3 downto 0);

                -- CHANGED: Store carry in carry_temp for consistent output handling.
                carry_temp := temp(4);

            when "001" =>
                -- CHANGED: Resize B to five bits before taking its complement.
                b_inv := not resize(unsigned(B), 5);

                temp := resize(unsigned(A), 5)
                      + b_inv + 1;

                -- CHANGED: Store the lower four bits in res_temp.
                res_temp := temp(3 downto 0);

                carry_temp := temp(4);

            when "010" =>
                product := unsigned(A) * unsigned(B);

                -- CHANGED: Assign the four-bit product to the four-bit result variable.
                res_temp := product(3 downto 0);

                -- CHANGED: Check only the upper four bits for overflow.
                if product(7 downto 4) /= "0000" then
                    carry_temp := '1';
                else
                    carry_temp := '0';
                end if;

            when "011" =>
                -- CHANGED: Compare the vector B against integer zero, not character '0'.
                if unsigned(B) /= 0 then
                    res_temp := unsigned(A) / unsigned(B);
                else
                    res_temp := "0000";
                    carry_temp := '1'; -- Division by zero indicator.
                end if;
				when "100" => 
					res_temp := unsigned(A) and unsigned(B);
				when "101" => 
					res_temp := unsigned(A) or unsigned(B);
				when "110" => 
					res_temp := unsigned(A) xor unsigned(B);
				when "111" => 
					res_temp := not unsigned(A) ;
				

            when others =>
                temp := (others => '0');
                res_temp := (others => '0'); -- ADDED: Ensure the result is zero for unused opcodes.
                carry_temp := '0';           -- ADDED: Clear carry for unused opcodes.
        end case;

        -- CHANGED: Use res_temp so multiplication and division results are preserved.
        result <= std_logic_vector(res_temp);

        -- CHANGED: Use the carry calculated for the selected operation.
        carry <= carry_temp;

        -- CHANGED: Check res_temp because it holds the actual four-bit result.
        if res_temp = "0000" then
            zero <= '1';
        else
            zero <= '0';
        end if;
    end process;
end architecture behv;

