/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none


module pipeline_register(
input clk,reset,
input [11:0]instr_in,
output reg[11:0] instr_out );
always@(posedge clk)
begin
if(reset)
instr_out<=12'b0;
else
instr_out<=instr_in;
end
endmodule



module pc (
    input  wire reset,
    input  wire clk,
    input  wire re,          // The "Pause Button" (Read Enable)
    output reg  [2:0] rd_addr
);
    always @(posedge clk) begin
        if (reset)
            rd_addr <= 3'b000;
        else if (re)         // ONLY count up if Read Enable is HIGH
            rd_addr <= rd_addr + 1;
    end
endmodule

    
module instruction_register (
    input   clk,
    input   reset,
    input  [11:0] Instruction,   
    output reg  [11:0] instr_out);

always @(posedge clk ) begin
    if (reset)
        instr_out <= 12'd0;
    else  
        instr_out <= Instruction;end
endmodule



module instr_mem (
    input wire clk,
    input wire rst,
    input wire [11:0] instr_in,
    input wire done,              
    input wire [2:0] rd_addr,
    input wire re,
    output wire [11:0] instr_out, 
    output reg [2:0] wr_addr
);

    reg [11:0] mem [0:7];
    reg done_d;   
    
    // Declare iterator for the initialization loop
    integer i; 

    always @(posedge clk) begin
        if (rst) begin
            wr_addr <= 3'b000;
            done_d  <= 1'b0;
            
            // NEW: Instantly clear all memory slots to zero to avoid XXX states!
            for (i = 0; i < 8; i = i + 1) begin
                mem[i] <= 12'b0000_00000000;
            end
            
        end else begin
            done_d <= done;

            if (done && !done_d) begin
                if (wr_addr < 3'd7) begin
                    mem[wr_addr] <= instr_in;
                    wr_addr <= wr_addr + 1;
                end else begin
                    mem[wr_addr] <= instr_in; 
                end
            end
        end
    end

    // The Combinational Read
    assign instr_out = (re) ? mem[rd_addr] : 12'b0000_00000000;

endmodule



module top_cpu(
    input clk,
    input rst, mod,
    input in0, in1, in2,
    input data_valid,    // <-- ADDED: Must expose the handshake pin!
    input re,
    output reg [11:0] instr_out
);

wire [11:0] sipo_out;
wire done;

wire [11:0] mem_out;
wire [2:0] rd_addr;
wire [2:0] wr_addr;
wire [11:0] pipe_out;
wire [11:0] ir_out;

// ---------------- SIPO ----------------
sipo u_sipo (
    .clk(clk),
    .rst(rst),
    .in0(in0),
    .in1(in1),
    .in2(in2),
    .mod(mod),
    .data_valid(data_valid), // <-- ADDED: Connect the wire to the SIPO!
    .out(sipo_out),
    .done(done)
);

// ----------- Instruction Memory --------
instr_mem u_mem (
    .clk(clk),
    .rst(rst),
    .instr_in(sipo_out),
    .done(done),
    .rd_addr(rd_addr),
    .re(re),
    .instr_out(mem_out),
    .wr_addr(wr_addr)
);

// ---------------- PC ----------------
pc u_pc (
    .reset(rst),
    .clk(clk),
    .re(re),
    .rd_addr(rd_addr)
);

// -------- Pipeline Registers ----------
instruction_register u_ir (
    .clk(clk),
    .reset(rst),
    .Instruction(mem_out),      
    .instr_out(ir_out)          
);

pipeline_register u_pipe (
    .clk(clk),
    .reset(rst),
    .instr_in(ir_out),          
    .instr_out(pipe_out)        
);

always @(*) begin
    instr_out = pipe_out;
end
    // Safely sink the unused write address wire to prevent Verilator warnings
    wire _unused_if = &{wr_addr};
endmodule

