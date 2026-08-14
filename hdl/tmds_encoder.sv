`default_nettype none
module tmds_encoder(
	input wire clk, 
	input wire rst, 
	input wire [7:0] video_data,
	input wire [1:0] control, 
	input wire video_enable, 
	output logic [9:0] tmds
	); 

	logic [8:0] q_m; 
	logic [4:0] tally;
	logic [9:0] q_m_out;

	tm_choice mtm(
		.din(video_data),
		.q_m(q_m)
	);

	wire [3:0] ones;
	wire [3:0] zeros;

	assign ones = $countones(q_m[7:0]);
	assign zeros = 4'd8 - ones;

	/*
	* States follow the flochart left to right so 
	* 1 - left 
	* 2 - 2nd left 
	* 3 - 3rd left 
	* 4 - Right
	*/
	enum {TMDSR, TMDS1, TMDS2, TMDS3, TMDS4} state;

	always_comb begin
		if(rst) begin
			q_m_out[9] = 1'b0; 
			q_m_out[8] = 1'b0;
			q_m_out[7] = 1'b0;
			q_m_out[6] = 1'b0;
			q_m_out[5] = 1'b0;
			q_m_out[4] = 1'b0;
			q_m_out[3] = 1'b0;
			q_m_out[2] = 1'b0;
			q_m_out[1] = 1'b0;
			q_m_out[0] = 1'b0;
			state = TMDSR;
		end else if((ones == zeros) || (tally == 5'b0)) begin
			q_m_out[9] = ~q_m[8]; 
			q_m_out[8] = q_m[8];
			if(q_m[8]) begin
				q_m_out[7] = q_m[7];
				q_m_out[6] = q_m[6];
				q_m_out[5] = q_m[5];
				q_m_out[4] = q_m[4];
				q_m_out[3] = q_m[3];
				q_m_out[2] = q_m[2];
				q_m_out[1] = q_m[1];
				q_m_out[0] = q_m[0];
				state = TMDS4;
			end else begin
				q_m_out[7] = ~q_m[7];
				q_m_out[6] = ~q_m[6];
				q_m_out[5] = ~q_m[5];
				q_m_out[4] = ~q_m[4];
				q_m_out[3] = ~q_m[3];
				q_m_out[2] = ~q_m[2];
				q_m_out[1] = ~q_m[1];
				q_m_out[0] = ~q_m[0];
				state = TMDS3;
			end
		end else begin 
			if(((tally > 15) && (zeros > ones)) || ((tally < 16)  && ones > zeros)) begin 
				q_m_out[9] = 1'b1; 
				q_m_out[8] = q_m[8];
				q_m_out[7] = ~q_m[7];
				q_m_out[6] = ~q_m[6];
				q_m_out[5] = ~q_m[5];
				q_m_out[4] = ~q_m[4];
				q_m_out[3] = ~q_m[3];
				q_m_out[2] = ~q_m[2];
				q_m_out[1] = ~q_m[1];
				q_m_out[0] = ~q_m[0];
				state = TMDS2;
			end else begin
				q_m_out[9] = 1'b0; 
				q_m_out[8] = q_m[8];
				q_m_out[7] = q_m[7];
				q_m_out[6] = q_m[6];
				q_m_out[5] = q_m[5];
				q_m_out[4] = q_m[4];
				q_m_out[3] = q_m[3];
				q_m_out[2] = q_m[2];
				q_m_out[1] = q_m[1];
				q_m_out[0] = q_m[0];
				state = TMDS1;
			end
		end 
	end 

	always_ff @(posedge clk) begin 
		if(rst) begin 
			tally <= 5'b0; 
			tmds <= 10'b0; 
		end else if(!video_enable) begin 
			tally <= 5'b0; 
			case(control)
				2'b00: tmds <= 10'b1101010100;
				2'b01: tmds <= 10'b0010101011;
				2'b10: tmds <= 10'b0101010100;
				2'b11: tmds <= 10'b1010101011;
				default:  tmds <= 10'b0000000000;
			endcase
		end else begin
			tmds <= q_m_out; 
			case(state)
				TMDS1: tally <= tally + (2 * {4'b0, ~q_m[8]}) + (ones -zeros);
				TMDS2: tally <= tally + (2 * {4'b0, q_m[8]}) + (zeros - ones);
				TMDS3: tally <= tally + (zeros - ones);
				TMDS4: tally <= tally + (ones - zeros);
				default: tally <= 5'b0;
			endcase
		end
	end
endmodule 
`default_nettype wire 

