/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ex_stage_top (
    input  wire        clk,
    input  wire        rst,
    input  wire [11:0] instr_in, 
    
    output wire [7:0]  out_pins,
    
    // We also expose the flags to the top level just in case 
    // you want to map them to external LEDs later!
    output wire        status_Z,
    output wire        status_N,
    output wire        status_C
);

    // --- Internal Routing Wires ---
    wire [3:0] current_opcode;
    wire [7:0] current_operand;
    
    wire [7:0] alu_result_wire;
    wire       alu_update_wire;
    
    wire [7:0] accumulator_wire;
    wire [7:0] scratchpad_wire; // Internal only, not exposed out of this stage

    // --- 1. Instantiate Decoder ---
    ex_decoder u_decoder (
        .instr_in(instr_in),
        .opcode(current_opcode),
        .operand(current_operand)
    );

    // --- 2. Instantiate ALU ---
    Integrated_ALU_8 u_alu (
        .clk(clk),
        .reset(rst),
        .A(accumulator_wire),      // Receives current Acc value
        .B(current_operand),       // Receives the operand from decoder
        .alu_op(current_opcode),   // Receives opcode from decoder
        .result(alu_result_wire),
        .update_acc(alu_update_wire),
        .flag_Z(status_Z),
        .flag_N(status_N),
        .flag_C(status_C)
    );

    // --- 3. Instantiate Registers (Memory) ---
    ex_memory u_mem (
        .clk(clk),
        .rst(rst),
        .opcode(current_opcode),
        .alu_result(alu_result_wire),
        .alu_update_acc(alu_update_wire),
        .accumulator(accumulator_wire),
        .scratchpad(scratchpad_wire)
    );

    // --- Output Assignment ---
    assign out_pins = accumulator_wire;

endmodule
