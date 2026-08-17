`timescale 1ps/1ps
module hdmi_clk_wiz_720p(
	output clk_pixel,
	output clk_tmds,
	//CSR 
	input reset, 
	output locked,
	input clk_ref
);
	wire clk_ref_clk_wiz_0;
	wire clk_in2_clk_wiz_0;

	IBUF clkin1_ibufg(
		.O(clk_ref_clk_wiz_0),
		.I(clk_ref)
	);

	// MMCM 
	wire clk_pixel_clk_wiz_0;
	wire clk_tmds_clk_wiz_0;
	wire clk_out3_clk_wiz_0;
	wire clk_out4_clk_wiz_0;
	wire clk_out5_clk_wiz_0;
	wire clk_out6_clk_wiz_0;
	wire clk_out7_clk_wiz_0;

	wire [15:0] do_unused;
	wire drdy_unused;
	wire psdone_unused;
	wire locked_int;
	wire clkfbout_clk_wiz_0;
	wire clkfbout_buf_clk_wiz_0;
	wire clkfboutb_unused;
	wire clkout0b_unused;
	wire clkout1b_unused;
	wire clkout2_unused;
	wire clkout2b_unused;
	wire clkout3_unused;
	wire clkout3b_unused;
	wire clkout4_unused;
	wire clkout5_unused;
	wire clkout6_unused;
	wire clkfbstopped_unused;
	wire clkinstopped_unused;
	wire reset_high; 

	MMCME2_ADV
	#(
		.BANDWIDTH("OPTIMIZED"),
		.CLKOUT4_CASCADE("FALSE"),
		.COMPENSATION("ZHOLD"),
		.STARTUP_WAIT("FALSE"),
		.DIVCLK_DIVIDE(5),
		.CLKFBOUT_MULT_F(37.125),
		.CLKFBOUT_PHASE(0.000),
		.CLKFBOUT_USE_FINE_PS("FALSE"),
		.CLKOUT0_DIVIDE_F(10.000),
		.CLKOUT0_PHASE(0.000),
		.CLKOUT0_DUTY_CYCLE(0.500),
		.CLKOUT0_USE_FINE_PS("FALSE"), 
		.CLKOUT1_DIVIDE(2),
		.CLKOUT1_PHASE(0.000),
		.CLKOUT1_DUTY_CYCLE(0.500), 
		.CLKOUT1_USE_FINE_PS("FALSE"),
		.CLKIN1_PERIOD(10.000)
	) mmcm_adv_inst (
		//Output Clocks
		.CLKFBOUT(clkfbout_clk_wiz_0),
		.CLKFBOUTB(clkfboutb_unused),
		.CLKOUT0(clk_pixel_clk_wiz_0),
		.CLKOUT0B(clkout0b_unused),
		.CLKOUT1(clk_tmds_clk_wiz_0),
		.CLKOUT1B(clkout1b_unused),
		.CLKOUT2(clkout2_unused),
		.CLKOUT2B(clkout2b_unused),
		.CLKOUT3(clkout3_unused),
		.CLKOUT3B(clkout3b_unused),
		.CLKOUT4(clkout4_unused),
		.CLKOUT5(clkout5_unused),
		.CLKOUT6(clkout6_unused),
		//Input clock control
		.CLKFBIN(clkfbout_buf_clk_wiz_0),
		.CLKIN1(clk_ref_clk_wiz_0),
		.CLKIN2(1'b0),
		// Tied to select the primary clock 
		.CLKINSEL(1'b1),
		//Reconfiguration ports 
		.DADDR(7'h0),
		.DCLK(1'b0),
		.DEN(1'b0),
		.DI(16'h0),
		.DO(do_unused),
		.DRDY(drdy_unused),
		.DWE(1'b0),
		// Phase shift ports 
		.PSCLK(1'b0),
		.PSEN(1'b0),
		.PSINCDEC(1'b0),
		.PSDONE(psdone_unused),
		//CSR Signals
		.LOCKED(locked_int),
		.CLKINSTOPPED(clkinstopped_unused),
		.CLKFBSTOPPED(clkfbstopped_unused),
		.PWRDWN(1'b0),
		.RST(reset_high)
	);

	assign reset_high = reset;
	assign locked = locked_int;

	//OUTPUT Buffering 
	BUFG clkf_buf(
		.O(clkfbout_buf_clk_wiz_0),
		.I(clkfbout_clk_wiz_0)
	);

	BUFG clkout1_buf(
		.O(clk_pixel),
		.I(clk_pixel_clk_wiz_0)
	);

	BUFG clkout2_buf(
		.O(clk_tmds),
		.I(clk_tmds_clk_wiz_0)
	);

endmodule
