library ieee;
use ieee.std_logic_1164.all;

entity controlUnit is
  port(
    clk, echo, enable: in std_logic;
    trigger, enviar: out std_logic;
    max_value: out integer;
    angulo_out: out integer
  );
end controlUnit;

architecture arch of controlUnit is

  type state is (muda_angulo, delay, dispara_trigger, espera_1, espera_0, envia);
  signal current_state, next_state: state;
  signal main_counter: integer range 0 to 50000000;
  signal trigger_counter: integer range 0 to 500;
  signal angulo: integer range 0 to 180;

begin

  -- 1 secound counter
  process(clk)
  begin
    if clk'event and clk='1' then
      if main_counter = 9999999+1 then
		main_counter <= 0;
	  else
        main_counter <= main_counter + 1;
      end if;
    end if;
  end process;

  -- trigger counter
  process(clk, current_state)
  begin
    if current_state=dispara_trigger then
      if clk'event and clk='1' then
        trigger_counter <= trigger_counter + 1;
      end if;
    else
      trigger_counter <= 0;
    end if;
  end process;

  -- next angulo
  process(clk, current_state)
  begin
	if clk'event and clk='1' then
		if current_state=muda_angulo then
		  case angulo is
			when 0 =>
			  angulo <= 30;
			when 30 =>
			  angulo <= 60;
			when 60 =>
			  angulo <= 90;
			when 90 =>
			  angulo <= 120;
			when 120 =>
			  angulo <= 150;
			when others =>
			  angulo <= 0;
		  end case;
		end if;
	end if;
  end process;

  -- next state logic
  process(clk, current_state)
  begin
    if clk'event and clk='1' then
      case current_state is
        when muda_angulo =>
          current_state <= delay;
        when delay =>
          if main_counter>9999999 then
            current_state <= dispara_trigger;
          else
            current_state <= delay;
          end if;
        when dispara_trigger =>
          if trigger_counter = 499 then
            current_state <= espera_1;
          else
            current_state <= dispara_trigger;
          end if;
        when espera_1 =>
          if echo='1' then
            current_state <= espera_0;
          else
            current_state <= espera_1;
          end if;
        when espera_0 =>
          if echo='0' then
            current_state <= envia;
          else
            current_state <= espera_0;
          end if;
        when envia =>
          current_state <= muda_angulo;
      end case;
    end if;
  end process;

  -- output logic
  process(clk, current_state)
  begin
    if current_state=dispara_trigger then
      trigger<='1';
    else
      trigger<='0';
    end if;

    if current_state=envia then
      enviar<='1';
    else
      enviar<='0';
    end if;

    case angulo is
      when 0 =>
        max_value <= 1000;
      when 30 =>
        max_value <= 1030;
      when 60 =>
        max_value <= 1060;
      when 90 =>
        max_value <= 1090;
      when 120 =>
        max_value <= 1120;
      when others =>
        max_value <= 1150;
    end case;

  end process;

  angulo_out <= angulo;

end arch;
