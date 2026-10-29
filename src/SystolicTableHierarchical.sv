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

    genvar r, c;
    generate
        for(r = 0; r < ROWS; r++) begin : assign_a_in_wires
            assign a_wire[r][0] = a_in_flat[r*DATA_WIDTH + DATA_WIDTH - 1 : r*DATA_WIDTH];
        end

        for(c = 0; c < COLS; c++) begin: assign_psum_wires
            assign psum_wire[0][c] = partial_sum_in_flat[c*ACC_WIDTH + ACC_WIDTH -1 : c*ACC_WIDTH];
            assign partial_sum_out_flat[c*ACC_WIDTH + ACC_WIDTH - 1 : c*ACC_WIDTH] = psum_wire[ROWS][c];
        end

        for (r = 0; r < ROWS; r++) begin : row_gen
            for(c = 0; c < COLS; c++) begin : cols_gen
                PE pe (
                    `ifdef USE_POWER_PINS
                    .VPWR(VPWR),
                    .VGND(VGND),
                    `endif
                    .clk(clk),
                    .rst_n(rst_n),
                    .load_w(load_w),
                    .a_in(a_wire[r][c]),
                    .partial_sum_in(psum_wire[r][c]),
                    .a_out(a_wire[r][c+1]),
                    .partial_sum_out(psum_wire[r+1][c])
                );
            end
        end
    endgenerate

endmodule
