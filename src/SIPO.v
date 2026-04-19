`default_nettype none

module sipo(
    input wire clk, 
    input wire rst, 
    input wire in0, 
    input wire in1, 
    input wire in2,
    input wire mod,
    input wire data_valid, // NEW: The Handshake clock from the Arduino
    output reg [11:0] out,
    output reg done
);

    // --- The 2-Stage Synchronizer & Edge Detector ---
    reg dv_sync1, dv_sync2;
    always @(posedge clk) begin
        if (rst) {dv_sync2, dv_sync1} <= 2'b00;
        else     {dv_sync2, dv_sync1} <= {dv_sync1, data_valid};
    end
    
    // This goes HIGH for exactly 1 ASIC clock cycle when the Arduino pin goes HIGH
    wire dv_edge = (dv_sync1 & ~dv_sync2); 

    // --- The SIPO Logic ---
    reg [3:0] s0, s1, s2;
    reg [1:0] cnt; // Counts 0 to 3 (4 shifts)

    always @(posedge clk) begin
        if (rst) begin
            s0 <= 0; s1 <= 0; s2 <= 0;
            cnt <= 0; out <= 0; done <= 0;
        end else if (mod == 1'b0) begin
            
            done <= 1'b0; // Default state
            
            if (dv_edge) begin // ONLY shift when the Arduino says so!
                s0 <= {s0[2:0], in0};
                s1 <= {s1[2:0], in1};
                s2 <= {s2[2:0], in2};
                cnt <= cnt + 1;
                
                if (cnt == 2'd3) begin
                    out <= {s2[2:0], in2, s1[2:0], in1, s0[2:0], in0};
                    done <= 1'b1; // Send a 1-clock-cycle pulse to Memory
                end
            end
        end
    end
endmodule
