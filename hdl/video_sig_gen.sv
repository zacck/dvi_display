module video_sig_gen
#(
	parameter ACTIVE_H_PIXELS = 1280,
	parameter H_FRONT_PORCH = 110,
	parameter H_SYNC_WIDTH = 40,
	parameter H_BACK_PORCH = 220, 
	parameter ACTIVE_LINES = 720, 
	parameter V_FRONT_PORCH = 5, 
	parameter V_SYNC_WIDTH = 5, 
	parameter V_BACK_PORCH = 20, 
	parameter FPS = 60
)
(
	input wire pixel_clk, 
	input wire rst, 
	output logic [$clog2(TOTAL_PIXELS)-1:0] h_count,
	output logic [$clog2(TOTAL_LINES)-1:0] v_count,
	output logic v_sync,
	output logic h_sync, 
	output logic active_draw, 
	output logic new_frame, 
	output logic [5:0] frame_count
);
	localparam TOTAL_LINES = (ACTIVE_LINES + V_FRONT_PORCH + V_SYNC_WIDTH + V_BACK_PORCH);
	localparam TOTAL_PIXELS = (ACTIVE_H_PIXELS + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH) *  TOTAL_LINES;

	always_ff @(posedge pixel_clk) begin 
		if(rst) begin 
			h_count <= 0;
			v_count <= 0;
			frame_count <= 0;
		/* verilator lint_off WIDTHEXPAND */
		end else if((v_count == TOTAL_LINES - 1) && (h_count == (ACTIVE_H_PIXELS - 1 + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH))) 
		begin
			new_frame <= 1;
			h_count <= 0; 
			v_count <= 0;
			frame_count <= (frame_count == FPS - 1) ? 0 : frame_count + 1;
		end else if (h_count == ((ACTIVE_H_PIXELS - 1) + H_FRONT_PORCH + H_SYNC_WIDTH + H_BACK_PORCH)) begin
			/* verilator lint_on WIDTHEXPAND */
			h_count <= 0; 
			v_count <= v_count + 1; 
		end else begin 
			h_count <= h_count + 1;
			new_frame <= 0;
		end 
	end

	/* verilator lint_off WIDTHEXPAND */
	assign h_sync = ((h_count > (ACTIVE_H_PIXELS - 1  + H_FRONT_PORCH))  && (h_count < (ACTIVE_H_PIXELS - 1 + H_FRONT_PORCH + H_BACK_PORCH)));

	assign v_sync = ((v_count > (ACTIVE_LINES - 1 + V_FRONT_PORCH)) && (v_count < (ACTIVE_LINES - 1 + V_FRONT_PORCH + V_BACK_PORCH)));

	/* verilator lint_off UNSIGNED */
	assign active_draw = ((h_count >= 0) && (h_count <= ACTIVE_H_PIXELS - 1) && (v_count >= 0) && (v_count <= ACTIVE_LINES - 1)); 
	/* verilator lint_on UNSIGNED */
	/* verilator lint_on WIDTHEXPAND */
endmodule

