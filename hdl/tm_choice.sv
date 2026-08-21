`default_nettype none
module tm_choice (
	input wire [7:0] din,
	output logic [8:0] q_m
);
	wire [3:0] count; 

	//assign count = din[0] + din[1] + din[2] + din[3] + din[4] + din[5] + din[6] + din[7]; 
	assign count = $countones(din);
	always_comb begin
		if((count > 4) || ((count == 4)  && (din[0] == 0))) begin
			q_m[0] = din[0];
			q_m[1] = ~(din[1] ^ q_m[0]);
			q_m[2] = ~(din[2] ^ q_m[1]);
			q_m[3] = ~(din[3] ^ q_m[2]);
			q_m[4] = ~(din[4] ^ q_m[3]);
			q_m[5] = ~(din[5] ^ q_m[4]);
			q_m[6] = ~(din[6] ^ q_m[5]);
			q_m[7] = ~(din[7] ^ q_m[6]);
			q_m[8] = 0;

		end else begin
			q_m[0] = din[0];
			q_m[1] = (din[1] ^ q_m[0]);
			q_m[2] = (din[2] ^ q_m[1]);
			q_m[3] = (din[3] ^ q_m[2]);
			q_m[4] = (din[4] ^ q_m[3]);
			q_m[5] = (din[5] ^ q_m[4]);
			q_m[6] = (din[6] ^ q_m[5]);
			q_m[7] = (din[7] ^ q_m[6]);
			q_m[8] = 1;
		end
	end 	
endmodule
`default_nettype wire
