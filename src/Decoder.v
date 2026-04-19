/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ex_decoder (
    input  wire [11:0] instr_in,
    output wire [3:0]  opcode,
    output wire [7:0]  operand
);

    // Physically split the incoming bus
    assign opcode  = instr_in[11:8];
    assign operand = instr_in[7:0];

endmodule
