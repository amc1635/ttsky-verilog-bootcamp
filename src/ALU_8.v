/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module Integrated_ALU_8 (
    input  wire clk,
    input  wire reset,
    input  wire [7:0] A,         // Accumulator input
    input  wire [7:0] B,         // Operand input
    input  wire [3:0] alu_op,    // Opcode input
    
    output reg  [7:0] result,    
    output reg        update_acc,
    output reg        flag_Z,
    output reg        flag_N,
    output reg        flag_C
);

    // --- LFSR Cryptography Engine ---
    reg [8:1] lfsr;
    wire feedback;
    assign feedback = lfsr[8] ^ lfsr[6] ^ lfsr[5] ^ lfsr[4];

    always @(posedge clk) begin
        if (reset) begin
            lfsr <= 8'b10101010;
        end else begin
            if (alu_op == 4'b1100) begin      // LOAD_SEED
                lfsr <= B;
            end else if (alu_op == 4'b1101) begin // CRYPTO
                lfsr <= {lfsr[7:1], feedback};
            end
        end
    end

    // --- ISA Definition ---
    localparam [3:0] 
        ADD   = 4'b0000, 
        SUB   = 4'b0001, 
        AND   = 4'b0010, 
        OR    = 4'b0011, 
        NOT   = 4'b0100, 
        MOV   = 4'b0101,  
        XOR   = 4'b0110, 
        CMP   = 4'b0111,  
        SHL   = 4'b1000,  
        SHR   = 4'b1001,  
        INC   = 4'b1010,  
        DEC   = 4'b1011,  
        LOAD_SEED = 4'b1100, 
        CRYPTO    = 4'b1101; 

    // --- Combinational Math ---
    reg [8:0] temp_result; 

    always @(*) begin
        update_acc = 1'b1; 
        temp_result = {1'b0, A}; 

        case(alu_op)
            ADD: temp_result = A + B;
            SUB: temp_result = A - B;
            CMP: begin
                 temp_result = A - B;
                 update_acc = 1'b0; 
            end
            AND: temp_result = {1'b0, A & B};
            OR:  temp_result = {1'b0, A | B};
            XOR: temp_result = {1'b0, A ^ B};
            NOT: temp_result = {1'b0, ~A};
            MOV: temp_result = {1'b0, B};
            SHL: temp_result = {A[7], A[6:0], 1'b0}; 
            SHR: temp_result = {A[0], 1'b0, A[7:1]}; 
            INC: temp_result = A + 1'b1;
            DEC: temp_result = A - 1'b1;
            
            LOAD_SEED: begin
                 temp_result = {1'b0, A};
                 update_acc = 1'b0; 
            end
            
            CRYPTO: temp_result = {1'b0, A ^ lfsr[8:1]};
            
            default: update_acc = 1'b0; 
        endcase

        result = temp_result[7:0];

        // --- Flags ---
        flag_Z = (result == 8'b00000000); 
        flag_N = result[7];               
        
        if (alu_op == SHR) begin
            flag_C = A[0]; 
        end else begin
            flag_C = temp_result[8];      
        end
    end
endmodule

