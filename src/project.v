/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_processor_top (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // -------------------------------------------------------------------------
    // SIGNAL ADAPTATION
    // -------------------------------------------------------------------------
    wire reset = ~rst_n;

    // Internal wires connecting Stage 1 to Stage 2
    wire [7:0] pipeline_instr_wire;
    // wire [7:0] pc_monitor_wire;
    wire [7:0] final_acc_value;

    // -------------------------------------------------------------------------
    // DEDICATED OUTPUT
    // -------------------------------------------------------------------------
    // Directly output the final accumulator value
    assign uo_out = final_acc_value;

    // -------------------------------------------------------------------------
    // DISABLE UIO PINS
    // -------------------------------------------------------------------------
    // Tiny Tapeout strictly requires all outputs to be assigned.
    // Assigning uio_oe to 0 ensures they remain as inputs (High-Z).
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // -------------------------------------------------------------------------
    // STAGE 1: Fetch and Pipeline (Member 1's Wrapper)
    // -------------------------------------------------------------------------
top_processor Stage1_Fetch (
        .clk(clk),
        .reset(reset),
        .instr_in(ui_in),               // <-- INJECT ui_in HERE
        .PC_out(),
        .instr_out(pipeline_instr_wire)
    );

    // -------------------------------------------------------------------------
    // STAGE 2: Execute and Memory (Member 2 & 3's Wrapper)
    // -------------------------------------------------------------------------
    WrapperEx Stage2_Execute (
        .clk(clk),
        .reset(reset),
        .instr(pipeline_instr_wire),    // Receives the instruction from Stage 1
        .acc_out_final(final_acc_value)
    );

    // -------------------------------------------------------------------------
    // PREVENT WARNINGS FOR UNUSED INPUTS
    // -------------------------------------------------------------------------
    // Since we aren't multiplexing anymore, all ui_in pins are unused.
    wire _unused = &{ena, uio_in, 1'b0};

endmodule
