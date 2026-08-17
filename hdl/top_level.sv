`default_nettype none
module top_level(
	input wire clk_100mhz,
	input wire [15:0] sw,
	input wire [3:0] btn, 
	output logic [15:0] led,
	output logic [2:0] hdmi_tx_p, 
	output logic [2:0] hdmi_tx_n, 
	output logic hdmi_clk_p, hdmi_clk_n
	);

	assign led = sw; 

	logic sys_rst;
	assign sys_rst = btn[0];
	logic game_rst;
	assign game_rst = btn[1]; 

	logic clk_pixel, clk_5x;
	logic locked; 


	//72 mhz clock
	hdmi_clk_wiz_720p mhdmicw (
		.reset(0),
		.locked(locked), 
		.clk_ref(clk_100mhz),
		.clk_pixel(clk_pixel),
		.clk_tmds(clk_5x)
	);

	
	logic [10:0] h_count; 
	logic [9:0] v_count; 
	logic h_sync;
	logic v_sync; 
	logic active_draw; 
	logic new_frame; 
	logic [5:0] frame_count; 


	video_sig_gen mvg(
		.pixel_clk(clk_pixel), 
		.rst(sys_rst), 
		.h_count(h_count), 
		.v_count(v_count),
		.v_sync(v_sync), 
		.h_sync(h_sync),
		.active_draw(active_draw), 
		.new_frame(new_frame), 
		.frame_count(frame_count)
	); 


	logic [7:0] red, green, blue;
	//logic [7:0] tp_r, tp_g, tp_b; 
	
	assign red = 8'hDA; 
	assign green = 8'h6A;
	assign blue = 8'h4C;


	/*
	always_comb begin 
		if(~sw[2])begin 
			red = tp_r; 
			green = tp_g; 
			blue = tp_b; 
		end
	end 
	*/

	logic [9:0] tmds_10b [0:2]; 
	logic tmds_signal[2:0];

	// encoders 8 bit to 10 bit
	tmds_encoder tmds_red(
		.clk(clk_pixel),
		.rst(sys_rst),
		.video_data(red),
		.control(2'b0),
		.video_enable(active_draw), 
		.tmds(tmds_10b[2])
	);

	tmds_encoder tmds_green(
		.clk(clk_pixel),
		.rst(sys_rst),
		.video_data(green),
		.control(2'b0),
		.video_enable(active_draw), 
		.tmds(tmds_10b[1])
	);


	tmds_encoder tmds_blue(
		.clk(clk_pixel),
		.rst(sys_rst),
		.video_data(blue),
		.control({v_sync, h_sync}),
		.video_enable(active_draw), 
		.tmds(tmds_10b[0])
	);


	// Serdes serializers 10bit to 1 bit
	tmds_serializer red_ser(
		.clk_pixel(clk_pixel), 
		.clk_5x(clk_5x), 
		.rst(sys_rst), 
		.tmds_in(tmds_10b[2]), 
		.tmds_out(tmds_signal[2])
	);

	tmds_serializer green_ser(
		.clk_pixel(clk_pixel), 
		.clk_5x(clk_5x), 
		.rst(sys_rst), 
		.tmds_in(tmds_10b[1]), 
		.tmds_out(tmds_signal[1])
	);

	tmds_serializer blue_ser(
		.clk_pixel(clk_pixel), 
		.clk_5x(clk_5x), 
		.rst(sys_rst), 
		.tmds_in(tmds_10b[0]), 
		.tmds_out(tmds_signal[0])
	);


	// Differential signal output buffers for clock recovery 
	OBUFDS OBUFDS_blue(.I(tmds_signal[0]), .O(hdmi_tx_p[0]), .OB(hdmi_tx_n[0]));
	OBUFDS OBUFDS_green(.I(tmds_signal[1]), .O(hdmi_tx_p[1]), .OB(hdmi_tx_n[1]));
	OBUFDS OBUFDS_red(.I(tmds_signal[2]), .O(hdmi_tx_p[2]), .OB(hdmi_tx_n[2]));
	OBUFDS OBUFDS_clock(.I(clk_pixel), .O(hdmi_clk_p), .OB(hdmi_clk_n));
endmodule

`default_nettype wire
