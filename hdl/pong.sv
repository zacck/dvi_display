`default_nettype none
module pong(
	input wire pixel_clk, 
	input wire rst, 
	input wire [1:0] control, 
	input wire [3:0] puck_speed, 
	input wire [3:0] paddle_speed, 
	input wire new_frame, 
	input wire [10:0] h_count, 
	input wire [9:0] v_count,

	output logic [7:0] pixel_red, 
	output logic [7:0] pixel_green,
	output logic [7:0] pixel_blue
	);

	logic [7:0] paddle_red, paddle_green, paddle_blue;
	logic [7:0] puck_red, puck_green, puck_blue;

	logic [10:0] puck_x;
	logic [9:0] puck_y; 
	logic [10:0] paddle_x; 
	logic [9:0] paddle_y;

	//6.4
	logic puck_y_vector;
	logic puck_x_vector;

	// 6. Nature 
	// 6.1 Control Paddle
	always_ff @(posedge pixel_clk) begin
		if(rst) begin
			puck_x <= 576; 
			puck_y <= 300;
			paddle_x <= 0;
			paddle_y <= 300;
			puck_x_vector <= 1;
			puck_y_vector <= 1;
		end else begin 
			if(new_frame) begin
				//6.2  Move  Control
				if(control[1] && paddle_y <= 592) begin
					paddle_y <= paddle_y + 8;
				end else if(control[0] && paddle_y > 8) begin
					paddle_y <= paddle_y - 8;
				end 

				//6.4 Detect end game
				if(puck_x < 10) begin 
					// do nothing
				end else if(puck_y >= (paddle_y - 128) && puck_y <= (paddle_y + 128) && puck_x <= 20) begin 
					// 6.5 bounce puck off paddle 
					if(puck_x_vector == 1) begin 
						puck_x_vector <= 0;
						puck_x <= puck_x - 4;
					end else begin 
						puck_x_vector <= 1;
						puck_x <= puck_x + 4;
					end 
				end else if(puck_y == 592 || puck_y == 0) begin
					// 6.3 detect perimeter collision
					if(puck_y_vector  == 1)  begin
						puck_y_vector <= 0;
						puck_y <= puck_y - 4;
					end else begin
						puck_y_vector <= 1;
						puck_y <= puck_y + 4;
					end
				end else if (puck_x == 1152) begin 
					if(puck_x_vector == 1) begin 
						puck_x_vector <= 0;
						puck_x <= puck_x - 4;
					end else begin 
						puck_x_vector <= 1;
						puck_x <= puck_x + 4;
					end 
				end else begin 
					if(puck_y_vector  == 1)  begin
						puck_y  <= puck_y + 4; 
					end else 
						puck_y  <= puck_y - 4;

					if(puck_x_vector == 1) begin 
						puck_x <= puck_x + 4;
					end else 
						puck_x <= puck_x - 4; 
				end
			end
		end
	end


	// 3. conditionally render
	always_comb begin 
		if((h_count >= paddle_x) && (h_count <= paddle_x + 20)) begin 
			pixel_red = paddle_red; 
			pixel_blue = paddle_blue;
			pixel_green = paddle_green;
		end else if ((h_count >= puck_x) && (h_count <= puck_x + 128)) begin 
			pixel_red = puck_red;
			pixel_blue = puck_blue; 
			pixel_green = puck_green; 
		end else begin  
			pixel_red = 0;
			pixel_blue = 0; 
			pixel_green = 0; 
		end
	end
			


	// 1. Define Sprites
	//
	// 4. Adjust paddle and puck x and y
	block_sprite  
	#(
		.WIDTH(20)
	) paddle_block
	(
		.h_count(h_count),
		.v_count(v_count),
		.x(paddle_x), 
		.y(paddle_y),
		.pixel_red(paddle_red), 
		.pixel_green(paddle_green), 
		.pixel_blue(paddle_blue)
	);

	block_sprite puck_block(
		.h_count(h_count), 
		.v_count(v_count),
		.x(puck_x),
		.y(puck_y),
		.pixel_red(puck_red),
		.pixel_green(puck_green),
		.pixel_blue(puck_blue)
	);

endmodule
`default_nettype wire
