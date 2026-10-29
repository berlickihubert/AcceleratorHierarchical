(* blackbox *)
module PE(
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif
    input  logic clk,
    input  logic rst_n,
    input  logic load_w,

    input  logic signed [7:0] a_in,
    input  logic signed [31:0]  partial_sum_in,

    output logic signed [7:0] a_out,
    output logic signed [31:0]  partial_sum_out
);
endmodule
