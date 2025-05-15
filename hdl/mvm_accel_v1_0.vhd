library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mvm_accel_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line
		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH : integer := 32;
		C_S00_AXI_ADDR_WIDTH : integer := 5;

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH : integer := 1024;

		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH : integer := 1024;
		C_M00_AXIS_START_COUNT : integer := 32
	);
	port (
		-- Users to add ports here
		-- User ports ends

		-- Create register passthrough for config
		s00_axi_reg0 : in std_logic_vector(31 downto 0);
		s00_axi_reg1 : in std_logic_vector(31 downto 0);
		s00_axi_reg2 : in std_logic_vector(31 downto 0);
		s00_axi_reg3 : in std_logic_vector(31 downto 0);
		s00_axi_reg4 : in std_logic_vector(31 downto 0);
		s00_axi_reg5 : in std_logic_vector(31 downto 0);
		s00_axi_reg6 : in std_logic_vector(31 downto 0);
		s00_axi_reg7 : in std_logic_vector(31 downto 0);
	
		-- User ports ends
		
		-- Do not modify the ports beyond this line
		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk    : in std_logic;
		s00_axi_aresetn : in std_logic;
		s00_axi_awaddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
		s00_axi_awprot  : in std_logic_vector(2 downto 0);
		s00_axi_awvalid : in std_logic;
		s00_axi_awready : out std_logic;
		s00_axi_wdata   : in std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		s00_axi_wstrb   : in std_logic_vector((C_S00_AXI_DATA_WIDTH/8) - 1 downto 0);
		s00_axi_wvalid  : in std_logic;
		s00_axi_wready  : out std_logic;
		s00_axi_bresp   : out std_logic_vector(1 downto 0);
		s00_axi_bvalid  : out std_logic;
		s00_axi_bready  : in std_logic;
		s00_axi_araddr  : in std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
		s00_axi_arprot  : in std_logic_vector(2 downto 0);
		s00_axi_arvalid : in std_logic;
		s00_axi_arready : out std_logic;
		s00_axi_rdata   : out std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
		s00_axi_rresp   : out std_logic_vector(1 downto 0);
		s00_axi_rvalid  : out std_logic;
		s00_axi_rready  : in std_logic;

		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk    : in std_logic;
		s00_axis_aresetn : in std_logic;
		s00_axis_tready  : out std_logic;
		s00_axis_tdata   : in std_logic_vector(C_S00_AXIS_TDATA_WIDTH - 1 downto 0);
		s00_axis_tstrb   : in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8) - 1 downto 0);
		s00_axis_tlast   : in std_logic;
		s00_axis_tvalid  : in std_logic;

		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk    : in std_logic;
		m00_axis_aresetn : in std_logic;
		m00_axis_tvalid  : out std_logic;
		m00_axis_tdata   : out std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
		m00_axis_tstrb   : out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8) - 1 downto 0);
		m00_axis_tlast   : out std_logic;
		m00_axis_tready  : in std_logic
	);
end mvm_accel_v1_0;

architecture arch_imp of mvm_accel_v1_0 is

	-- component declaration
	component mvm_accel_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 5
		);
		port (
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component mvm_accel_v1_0_S00_AXI;

	component mvm_accel_v1_0_S00_AXIS is
		generic (
		C_S_AXIS_TDATA_WIDTH	: integer	:= 32
		);
		port (
		S_AXIS_ACLK	: in std_logic;
		S_AXIS_ARESETN	: in std_logic;
		S_AXIS_TREADY	: out std_logic;
		S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
		S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
		S_AXIS_TLAST	: in std_logic;
		S_AXIS_TVALID	: in std_logic
		);
	end component mvm_accel_v1_0_S00_AXIS;

	component mvm_accel_v1_0_M00_AXIS is
		generic (
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		C_M_START_COUNT	: integer	:= 32
		);
		port (
		M_AXIS_ACLK	: in std_logic;
		M_AXIS_ARESETN	: in std_logic;
		M_AXIS_TVALID	: out std_logic;
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		M_AXIS_TLAST	: out std_logic;
		M_AXIS_TREADY	: in std_logic
		);
	end component mvm_accel_v1_0_M00_AXIS;
	
	-- User signal definitions BEGIN
	component mvm_accelerator is
		generic (
			D : integer := 1024; -- size of data stream
			N : integer := 32;   -- core dimension (N x N)
			Y : integer := 32;   --number of cores = D / N
			M : integer := 8     -- Size of col outputs
		);
		port (
			sysclk  : in std_logic; -- system clock
			reset   : in std_logic; -- reset registers and coutners
			data_in : in std_logic_vector(D - 1 downto 0);

			transfer_in : in std_logic;
            transfer_out : in std_logic;

			loadw_i  : in std_logic_vector(Y - 1 downto 0);
			read_cmd : in std_logic;

			data_out : out std_logic_vector(D - 1 downto 0)
		);
	end component mvm_accelerator;
	
	signal s00_slave_transaction : std_logic;
    signal s00_master_transaction : std_logic;
    -- User signal definitions END

begin

-- Instantiation of Axi Bus Interface S00_AXI
mvm_accel_v1_0_S00_AXI_inst : mvm_accel_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

-- Instantiation of Axi Bus Interface S00_AXIS
mvm_accel_v1_0_S00_AXIS_inst : mvm_accel_v1_0_S00_AXIS
	generic map (
		C_S_AXIS_TDATA_WIDTH	=> C_S00_AXIS_TDATA_WIDTH
	)
	port map (
		S_AXIS_ACLK	=> s00_axis_aclk,
		S_AXIS_ARESETN	=> s00_axis_aresetn,
		S_AXIS_TREADY	=> s00_axis_tready,
		S_AXIS_TDATA	=> s00_axis_tdata,
		S_AXIS_TSTRB	=> s00_axis_tstrb,
		S_AXIS_TLAST	=> s00_axis_tlast,
		S_AXIS_TVALID	=> s00_axis_tvalid
	);

-- Instantiation of Axi Bus Interface M00_AXIS
mvm_accel_v1_0_M00_AXIS_inst : mvm_accel_v1_0_M00_AXIS
	generic map (
		C_M_AXIS_TDATA_WIDTH	=> C_M00_AXIS_TDATA_WIDTH,
		C_M_START_COUNT	=> C_M00_AXIS_START_COUNT
	)
	port map (
		M_AXIS_ACLK	=> m00_axis_aclk,
		M_AXIS_ARESETN	=> m00_axis_aresetn,
		M_AXIS_TVALID	=> m00_axis_tvalid,
		M_AXIS_TDATA	=> m00_axis_tdata,
		M_AXIS_TSTRB	=> m00_axis_tstrb,
		M_AXIS_TLAST	=> m00_axis_tlast,
		M_AXIS_TREADY	=> m00_axis_tready
	);

	-- Add user logic here
    s00_slave_transaction <= s00_axis_tvalid; --s00_axis_tready and s00_axis_tvalid;
    s00_master_transaction <= m00_axis_tready; -- and m00_axis_tvalid;
	
	mvm_accelerator_inst : mvm_accelerator
	generic map(
		D => C_S00_AXIS_TDATA_WIDTH,
		N => 32,
		Y => 32,
		M => 8
	)
	port map(
		sysclk  => s00_axis_aclk,
		reset   => s00_axis_aresetn,
		data_in => s00_axis_tdata,

		transfer_in => s00_axis_tvalid,
		transfer_out => m00_axis_tready,

		loadw_i  => s00_axi_reg0(31 downto 0),
		read_cmd => s00_axi_reg1(0),

		data_out => m00_axis_tdata
	);
	-- User logic ends

end arch_imp;
