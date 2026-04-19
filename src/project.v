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
    input  wire       ena,      // always 1 when the design is powered
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

    // -------------------------------------------------------------------------
    // SIGNAL ADAPTATION
    // -------------------------------------------------------------------------
    // Tiny Tapeout reset is active-low. Your modules use active-high.
    wire rst = ~rst_n;

    // Internal wires connecting Stage 1 (Fetch) to Stage 2 (Execute)
    wire [11:0] pipeline_highway;
    wire [7:0]  final_acc_value;

    // -------------------------------------------------------------------------
    // PIN MAPPING (ui_in routing)
    // -------------------------------------------------------------------------
    // This defines how your Arduino connects to the physical chip pins!
    wire mod        = ui_in[0]; // Switch 0: 0=Programming Mode, 1=Execution Mode
    wire re         = ui_in[1]; // Switch 1: Read Enable (Pauses/Runs the PC)
    wire in0        = ui_in[2]; // Switch 2: SIPO Data Low
    wire in1        = ui_in[3]; // Switch 3: SIPO Data Mid
    wire in2        = ui_in[4]; // Switch 4: SIPO Data High (Opcode wire)
    wire data_valid = ui_in[5]; // Switch 5: Arduino Handshake Clock

    // -------------------------------------------------------------------------
    // STAGE 1: Fetch and Pipeline 
    // -------------------------------------------------------------------------
    top_cpu Stage1_Fetch (
        .clk(clk),
        .rst(rst),
        .mod(mod),
        .in0(in0),
        .in1(in1),
        .in2(in2),
        .data_valid(data_valid),
        .re(re),
        .instr_out(pipeline_highway) // 12-bit output to the pipeline
    );

    // -------------------------------------------------------------------------
    // STAGE 2: Execute and Memory 
    // -------------------------------------------------------------------------
    ex_stage_top Stage2_Execute (
        .clk(clk),
        .rst(rst),
        .instr_in(pipeline_highway), // 12-bit input from the pipeline
        .out_pins(final_acc_value),  // 8-bit output from the Accumulator
        
        // We leave the flags disconnected since we just want the Accumulator
        .status_Z(),
        .status_N(),
        .status_C()
    );

    // -------------------------------------------------------------------------
    // DEDICATED OUTPUT
    // -------------------------------------------------------------------------
    // Directly output the final accumulator value to the 8 LEDs
    assign uo_out = final_acc_value;

    // -------------------------------------------------------------------------
    // DISABLE UIO PINS
    // -------------------------------------------------------------------------
    // Tiny Tapeout strictly requires all outputs to be assigned.
    // Assigning uio_oe to 0 ensures bidirectional pins remain as inputs (High-Z).
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

    // -------------------------------------------------------------------------
    // PREVENT WARNINGS FOR UNUSED INPUTS
    // -------------------------------------------------------------------------
    // Safely sink ui_in[7] and ui_in[6], plus the unused TT system pins,
    // so OpenLane doesn't throw synthesis warnings about floating wires.
    wire _unused = &{ena, uio_in, ui_in[7:6], 1'b0};

endmodule
