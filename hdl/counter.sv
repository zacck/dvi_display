module counter(     input wire clk,
                    input wire rst,
               input wire [31:0] period,
               output logic [31:0] count
              );
  always_ff @(posedge clk) begin
    if(rst) begin 
      count <= 0;
    end else 
      if(count == period - 1) begin 
        count <= 0;
      end else 
        count <= count + 1;
  end

endmodule
