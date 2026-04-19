/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none
module fetch_stage(
input reset,clk,
output reg [7:0] PC_out);
always@ (posedge clk)
begin
if(reset)
PC_out <=8'b0;
else
PC_out<=PC_out + 1;
end
endmodule

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



module pc(
input reset,clk,
output reg [2:0] rd_addr);
always@ (posedge clk)
begin
if(reset)
rd_addr <=3'b0;
else
rd_addr<=rd_addr + 1;
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


module instruction_memory (
    input clk,
    input rst,

    // from SIPO
    input [11:0] instr_in,
    input done,              

    // read side
    input [2:0] rd_addr,
    input re,

    output reg [11:0] instr_out,
    output reg [2:0] wr_addr
);

reg [11:0] mem [0:7];
reg done_d;   // for edge detection

always @(posedge clk) begin
    if (rst) begin
        wr_addr <= 0;
        instr_out <= 0;
        done_d <= 0;
    end else begin
        done_d <= done;

        
        if (done && !done_d) begin
            if (wr_addr < 3'd7) begin
                mem[wr_addr] <= instr_in;
                wr_addr <= wr_addr + 1;
            end else begin
                mem[wr_addr] <= instr_in; // last location
                wr_addr <= wr_addr;       // stop increment
            end
        end

        
        if (re) begin
            instr_out <= mem[rd_addr];
        end
    end
end


endmodule


module top_processor(
    input  wire clk,
    input  wire reset,
    input  wire [7:0] instr_in,
    output wire [7:0] PC_out,
    output wire [7:0] instr_out
);
    wire [7:0] ir_instr_out;

    fetch_stage u_fetch (
        .clk    (clk),
        .reset  (reset),
        .PC_out (PC_out)
    );

    // DELETED the instruction_memory (ROM) instance entirely.
    // The processor now takes instructions directly from the outside world.

    instruction_register u_ir (
        .clk         (clk),
        .reset       (reset),
        .Instruction (instr_in),       // <-- Route the external input directly here
        .instr_out   (ir_instr_out)
    );

    pipeline_register u_pipeline (
        .clk       (clk),
        .reset     (reset),
        .instr_in  (ir_instr_out),
        .instr_out (instr_out)
    );
endmodule
