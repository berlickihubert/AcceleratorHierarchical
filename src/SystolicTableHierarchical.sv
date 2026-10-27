module SystolicTableHierarchical #(
    parameter int ROWS = 32,
    parameter int COLS = 32,
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH = 32
)(
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif
    input  logic clk,
    input  logic rst_n,
    input  logic load_w,

    input  logic signed [ROWS*DATA_WIDTH-1:0] a_in_flat,
    input  logic signed [COLS*ACC_WIDTH-1:0]  partial_sum_in_flat,

    output logic signed [COLS*ACC_WIDTH-1:0]  partial_sum_out_flat
);

    logic signed [DATA_WIDTH-1 : 0] a_wire [ROWS][COLS+1];
    logic signed [ACC_WIDTH-1 : 0] psum_wire [ROWS+1][COLS];

    