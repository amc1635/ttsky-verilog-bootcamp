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
    input clk,
    input rst,mod,
    input in0, in1, in2,
    input re,
    output reg[11:0] instr_out
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
    .out(sipo_out),
    .done(done)
);

// ----------- Instruction Memory --------
instruction_memory u_mem (
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

// -------- Pipeline Register ----------
// 1. Memory feeds the Instruction Register (IR)
instruction_register u_ir (
    .clk(clk),
    .reset(rst),
    .Instruction(mem_out),      // Changed from pipe_out to mem_out
    .instr_out(ir_out)          // ir_out is now the "middle" signal
);

// 2. IR feeds the Pipeline Register
pipeline_register u_pipe (
    .clk(clk),
    .reset(rst),
    .instr_in(ir_out),          // Changed from mem_out to ir_out
    .instr_out(pipe_out)        // pipe_out is now the final output
);

// 3. Connect the final Pipeline Register to the top-level output
always @(*) begin
    instr_out = pipe_out;
end
endmodule

