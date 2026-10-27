module PE(
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif
    input  logic clk,
    input  logic rst_n,

    input  logic signed [7:0] a_in,
    input  logic signed [31:0]  partial_sum_in,

    output logic signed [7:0] a_out,
    output logic signed [31:0]  partial_sum_out
);

    logic signed [7:0] weight;


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            weight          <= '0;  
            a_out           <= '0;
            partial_sum_out <= '0;
        end
        else if (load_w) begin
            weight          <= a_in;
            a_out           <= a_in;
            partial_sum_out <= '0;
        end
        else begin
            a_out           <= a_in;
            partial_sum_out <= partial_sum_in + (a_in * weight);
        end
    end

endmodule