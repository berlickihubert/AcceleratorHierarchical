module AcceleratorTop #(
    parameter int ROWS = 32,
    parameter int COLS = 32,
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH = 32
)(
`ifdef USE_POWER_PINS
    inout VPWR,
    inout VGND,
`endif

    input logic clk,
    input logic rst_n,
    input logic load_w,

    input logic signed [ROWS*DATA_WIDTH-1 : 0] a_in_flat,

    output logic signed [COLS*ACC_WIDTH-1 : 0] result_flat
);

    SystolicTableHierarchical #(
        .ROWS(ROWS),
        .COLS(COLS),
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH)
    ) systolic_array (
`ifdef USE_POWER_PINS
        .VPWR(VPWR),
        .VGND(VGND),
`endif
        .clk(clk),
        .rst_n(rst_n),
        .load_w(load_w),
        .a_in_flat(a_in_flat),
        .partial_sum_in_flat('0),
        .partial_sum_out_flat(result_flat)
    );

endmodule
