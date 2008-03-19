----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Wang, Liang(liang.wang@intel.com)
-- 
-- Create Date:    16:30:51 12/25/2007 
-- Design Name: 
-- Module Name:    CSR_CONTROLLER - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: CSR Controller
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CSR_CONTROLLER is
port(     
	clk   : in std_logic;
	rst_n : in std_logic;
	
	-- csr ports for PCIe TX/RX Engine
	pcie_csr_out_rd_ready		: out std_logic; 
	pcie_csr_out_rd_done			: out std_logic;
	pcie_csr_in_rd_en				  : in std_logic;
	pcie_csr_in_rd_ack				 : in std_logic;
	pcie_csr_out_rd_data			: out std_logic_vector((32 - 1) downto 0);
	pcie_csr_in_rd_index			: in std_logic_vector((8 - 1) downto 0);
	pcie_csr_out_wr_ready		: out std_logic;
	pcie_csr_in_wr_en				  : in std_logic;
	pcie_csr_in_wr_data			 : in std_logic_vector((32 - 1) downto 0);
	pcie_csr_in_wr_index			: in std_logic_vector((8 - 1) downto 0);
	
	pcie_csr_in_h2f_reg0_wr_en: in std_logic;
	pcie_csr_in_h2f_reg0      : in std_logic_vector((32 - 1) downto 0);
	pcie_csr_out_f2h_reg0			: out std_logic_vector((32 - 1) downto 0);
	
	-- csr ports for hardware channel application use	
	csr_out_rd_ready		: out std_logic; 
	csr_out_rd_done			: out std_logic;
	csr_in_rd_en				  : in std_logic;
	csr_in_rd_ack				 : in std_logic;
	csr_out_rd_data			: out std_logic_vector((32 - 1) downto 0);
	csr_in_rd_index			: in std_logic_vector((8 - 1) downto 0);
	csr_out_wr_ready		: out std_logic;
	csr_in_wr_en				  : in std_logic;
	csr_in_wr_data			 : in std_logic_vector((32 - 1) downto 0);
	csr_in_wr_index			: in std_logic_vector((8 - 1) downto 0);


	--------------system CSR SIGNAL-------------------
	csr_in_f2h_reg0_wr_en : in std_logic;
	csr_out_h2f_reg0			: out std_logic_vector((32 - 1) downto 0);
	csr_in_f2h_reg0				: in std_logic_vector((32 - 1) downto 0)
);
end CSR_CONTROLLER;

architecture rtl of CSR_CONTROLLER is
component  CSR_BRAM IS
port (
	clka: IN std_logic;
	dina: IN std_logic_VECTOR(31 downto 0);
	addra: IN std_logic_VECTOR(7 downto 0);
	ena: IN std_logic;
	wea: IN std_logic_VECTOR(0 downto 0);
	clkb: IN std_logic;
	addrb: IN std_logic_VECTOR(7 downto 0);
	enb: IN std_logic;
	doutb: OUT std_logic_VECTOR(31 downto 0));
END component;
	 
type csr_controller_state is (
	CSR_IDLE,
	CSR_LOOKAHEAD, -- to check whether another en signal is toggled.
	CSR_PCIE_WRITE,
	CSR_PCIE_WRITE_ACK,
	CSR_PCIE_READ,
	CSR_PCIE_READ_WAIT,
	CSR_PCIE_READ_ACK,
	CSR_WRITE,
	CSR_WRITE_ACK,
	CSR_READ,
	CSR_READ_WAIT,
	CSR_READ_ACK
);
SIGNAL CSR_STATE:csr_controller_state;

--type pcie_spl_arbitrator_state is {
--	PCIE_SPL_ARBIT_RST,
--	PCIE_SPL_ARBIT_
	 
	-------------------------------------------------------
--	signal csr_out_h2f_reg0_r: std_logic_vector((32 - 1) downto 0);
--	signal csr_in_f2h_reg0_r	: std_logic_vector((32 - 1) downto 0);
	signal csr_h2f_reg0_c : std_logic_vector((32 - 1) downto 0);
	signal csr_f2h_reg0_c : std_logic_vector((32 - 1) downto 0);
	
	signal wr_en_r           : std_logic; 
	signal pcie_csr_rd_index_c    : std_logic_vector((8 - 1) downto 0);
	signal pcie_csr_wr_index_c    : std_logic_vector((8 - 1) downto 0);
	signal pcie_csr_wr_data_c     : std_logic_vector((32 - 1) downto 0);
	
	signal csr_rd_index_c 				: std_logic_vector((8 - 1) downto 0);
	signal csr_wr_index_c					: std_logic_vector((8 - 1) downto 0);
	signal csr_wr_data_c					: std_logic_vector((32 - 1) downto 0);
	
	signal dina                   : std_logic_vector((32 - 1) downto 0);
	signal addra									: std_logic_vector((8 - 1) downto 0);
	signal addrb									: std_logic_vector((8 - 1) downto 0);
	signal doutb									: std_logic_vector((32 - 1) downto 0);
	
	-- do pcie side transaction when pcie_spl_selector = 1
	-- do spl side transactin when pcie_spl_selector = 0
	signal pcie_spl_selector      : std_logic;
	
	signal pcie_csr_rd_en_c				: std_logic;
	signal pcie_csr_wr_en_c				: std_logic;
	signal csr_rd_en_c						: std_logic;
	signal csr_wr_en_c						: std_logic;
	
	signal csr_ready							: std_logic;

    -- Angshuman TEMP DEBUG
    signal csr_out_rd_ready_latch : std_logic;
    signal csr_out_wr_ready_latch : std_logic;

begin 

pcie_csr_out_rd_data <= doutb when pcie_spl_selector = '1' else
												(others => '0');
												
csr_out_rd_data	<= doutb when pcie_spl_selector = '0' else
												(others => '0');
												
addrb <= pcie_csr_rd_index_c when pcie_spl_selector = '1' else
				 csr_rd_index_c;
				 
addra <= pcie_csr_wr_index_c when pcie_spl_selector = '1' else
				 csr_wr_index_c;
				 
dina <= pcie_csr_wr_data_c when pcie_spl_selector = '1' else
				csr_wr_data_c;
				
				
				
CSR_ram_test : CSR_BRAM port map (
	clka => clk,--
	dina => dina,--csr_wr_data_c
	addra => addra,--csr_wr_index_c
	ena => wr_en_r, 
	wea => "1",  --
	clkb => clk,--
	addrb => addrb,--csr_rd_index_c
	enb   => '1',
	doutb => doutb--csr_out_rd_data
);

pcie_csr_out_rd_ready <= (not(pcie_csr_in_wr_en or pcie_csr_in_rd_en or
													 csr_in_wr_en or csr_in_rd_en)) and csr_ready;
pcie_csr_out_wr_ready <= (not(pcie_csr_in_wr_en or pcie_csr_in_rd_en or
													 csr_in_wr_en or csr_in_rd_en)) and csr_ready;

-- Angshuman
csr_out_rd_ready      <= csr_out_rd_ready_latch;
csr_out_wr_ready      <= csr_out_wr_ready_latch;

process(clk,rst_n)
begin

    -- Angshuman begin
    if (rising_edge(clk)) then
        csr_out_rd_ready_latch <= (not(pcie_csr_in_wr_en or pcie_csr_in_rd_en or
					         						 csr_in_wr_en or csr_in_rd_en)) and csr_ready;
        csr_out_wr_ready_latch <= (not(pcie_csr_in_wr_en or pcie_csr_in_rd_en or
                        							 csr_in_wr_en or csr_in_rd_en)) and csr_ready;
    end if;
    -- Angshuman end

	if(rst_n = '0')then
		CSR_STATE <= CSR_IDLE;
		pcie_csr_out_rd_done  <= '0';
		
		csr_out_rd_done <= '0';
		
		pcie_csr_rd_index_c <= (others => '0');
		pcie_csr_wr_index_c <= (others => '0');
		pcie_csr_wr_data_c <= (others => '0');
		
		csr_rd_index_c <= (others => '0');
		csr_wr_index_c <= (others => '0');
		csr_wr_data_c <= (others => '0');
		
		pcie_csr_rd_en_c <= '0';
		pcie_csr_wr_en_c <= '0';
		csr_rd_en_c <= '0';
		csr_wr_en_c <= '0';
		
		wr_en_r <= '0'; 
		-- ports for PCIe is defaultly selected
		pcie_spl_selector <= '0';
		
		csr_ready <= '1';

	elsif(rising_edge(clk))then
		case CSR_STATE is
		when CSR_IDLE =>                    
			pcie_csr_out_rd_done  <= '0';
			wr_en_r <= '0';
			
			--buffer the input signal

			pcie_csr_rd_en_c <= pcie_csr_in_rd_en;
--			pcie_csr_rd_data_c <= pcie_csr_out_rd_data;
			pcie_csr_rd_index_c <= pcie_csr_in_rd_index;

			pcie_csr_wr_en_c <= pcie_csr_in_wr_en;
			pcie_csr_wr_data_c <=pcie_csr_in_wr_data;
			pcie_csr_wr_index_c <= pcie_csr_in_wr_index;

			csr_rd_en_c <= csr_in_rd_en;
--			csr_rd_data_c <= csr_out_rd_data;
			csr_rd_index_c <= csr_in_rd_index;

			csr_wr_en_c <= csr_in_wr_en;
			csr_wr_data_c <= csr_in_wr_data;
			csr_wr_index_c <= csr_in_wr_index;
			
			pcie_spl_selector <= '0';
	
			if ( (pcie_csr_in_wr_en = '1') or
					 (pcie_csr_in_rd_en = '1') or
					 (csr_in_wr_en = '1') or
					 (csr_in_rd_en = '1')) then
					 
				csr_ready <= '0';	
				CSR_STATE <= CSR_READ;
					
			else
				csr_ready <= '1';
				CSR_STATE <= CSR_IDLE;
			end if;		 

		when CSR_READ =>
			if ( csr_rd_en_c = '1') then 
				CSR_STATE <= CSR_READ_WAIT;
			else
				CSR_STATE <= CSR_WRITE;
			end if;

		when CSR_READ_WAIT =>
			csr_out_rd_done <= '1';
			CSR_STATE <= CSR_READ_ACK;

		when CSR_READ_ACK =>
			if(csr_in_rd_ack = '1')then
				csr_out_rd_done <= '0';
				CSR_STATE <= CSR_WRITE;
			else 
				CSR_STATE <=  CSR_READ_ACK;
				csr_out_rd_done  <= '1';
			end if;
			
		when CSR_WRITE =>
			if ( csr_wr_en_c = '1') then
				wr_en_r <= '1';
				CSR_STATE <= CSR_WRITE_ACK;
			else
				wr_en_r <= '0';
				pcie_spl_selector <= '1';
				CSR_STATE <= CSR_PCIE_READ;
			end if;
			
		when CSR_WRITE_ACK =>
			wr_en_r <= '0';
			pcie_spl_selector <= '1';
			CSR_STATE <= CSR_PCIE_READ;

		when CSR_PCIE_READ =>
			if ( pcie_csr_rd_en_c = '1') then
				CSR_STATE <= CSR_PCIE_READ_WAIT;
			else
				CSR_STATE <= CSR_PCIE_WRITE;
			end if;
			
		when CSR_PCIE_READ_WAIT =>
			pcie_csr_out_rd_done <= '1';
			CSR_STATE <= CSR_PCIE_READ_ACK;

		when CSR_PCIE_READ_ACK =>             
			if(pcie_csr_in_rd_ack = '1')then
				pcie_csr_out_rd_done <= '0';
				CSR_STATE <= CSR_PCIE_WRITE;
			else 
				CSR_STATE <=  CSR_PCIE_READ_ACK;
				pcie_csr_out_rd_done  <= '1';
			end if; 		
			
		when CSR_PCIE_WRITE =>
			if (pcie_csr_wr_en_c = '1') then
				wr_en_r <= '1';  
				CSR_STATE <= CSR_PCIE_WRITE_ACK;
			else
				csr_ready <= '1';
				pcie_spl_selector <= '0';
				
				CSR_STATE <= CSR_IDLE;
			end if;
			
		when CSR_PCIE_WRITE_ACK => 
			wr_en_r <= '0';  
			csr_ready <= '1';
			pcie_spl_selector <= '0';
			
			CSR_STATE <= CSR_IDLE;
		
		when others =>
			null;
		end case;   
	end if;     
end process;
    

-- h2f system CSR
csr_out_h2f_reg0 <= csr_h2f_reg0_c;
process (clk, rst_n)
begin
	if (rst_n = '0') then
		csr_h2f_reg0_c <= (others => '0');
	elsif( rising_edge(clk)) then
		if ( pcie_csr_in_h2f_reg0_wr_en = '1') then
			csr_h2f_reg0_c <= pcie_csr_in_h2f_reg0;
		else
			csr_h2f_reg0_c <= csr_h2f_reg0_c;
		end if;
	end if;
end process;

-- f2h system CSR
pcie_csr_out_f2h_reg0 <= csr_f2h_reg0_c;
process (clk, rst_n)
begin
	if (rst_n = '0') then
		csr_f2h_reg0_c <= (others => '0');
	elsif (rising_edge(clk)) then                            
		if (csr_in_f2h_reg0_wr_en = '1' ) then
			csr_f2h_reg0_c <= csr_in_f2h_reg0;
		else
			csr_f2h_reg0_c <= csr_f2h_reg0_c;
		end if;
	end if;
end process;

end rtl;
