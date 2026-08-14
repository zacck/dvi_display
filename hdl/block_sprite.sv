`default_nettype none
module block_sprit #(
	parameter WIDTH = 128,
	parameter HEIGHT = 128,
	parameter COLOR = 24'hFF_FF_FF
	)
	(
		input wire [10:0] h_count,
		input wire [9:0] v_count,
		input wire [10:0] x,
		input wire [9:0] y,
		output logic [7:0] pixel_red,
		output logic [7:0] pixel_green,
		output logic [7:0] pixel_blue
	);

	logic in_sprite;
	assign in_sprite = ((h_count >= x && h_count < (x + WIDTH)) &&
		(v_count >= y && v_count < (y + HEIGHT)));

	always_comb begin 
		if(in_sprite) begin
			pixel_red = COLOR[23:16];
			pixel_green = COLOR[15:8];
			pixel_blue = COLOR[7:0];
		end else begin 
			pixel_red = 0; 
			pixel_green = 0; 
			pixel_blue = 0;
		end
	end
endmodule 
`default_nettype wire
