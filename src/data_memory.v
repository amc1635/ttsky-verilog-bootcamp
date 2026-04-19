/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ex_memory (
    input  wire clk,
    input  wire rst,
    input  wire [3:0] opcode,
    input  wire [7:0] alu_result,
    input  wire       alu_update_acc,
    
    output reg  [7:0] accumulator,
    output reg  [7:0] scratchpad
);

    localparam STORE    = 4'b1110; // Opcode 14
    localparam LOAD_MEM = 4'b1111; // Opcode 15

    always @(posedge clk) begin
        if (rst) begin
            accumulator <= 8'b00000000;
            scratchpad  <= 8'b00000000;
        end else begin
            if (opcode == STORE) begin
                scratchpad <= accumulator; // Save to Scratchpad
            end 
            else if (opcode == LOAD_MEM) begin
                accumulator <= scratchpad; // Restore from Scratchpad
            end 
            else if (alu_update_acc == 1'b1) begin
                accumulator <= alu_result; // Save standard ALU/Crypto math
            end
        end
    end

endmodule
