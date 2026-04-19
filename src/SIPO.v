module sipo(
    input clk,rst,in0,in1, in2,
    output reg [11:0] out,
    output reg done
);

reg [3:0] s0, s1, s2;
reg [2:0] cnt;

always @(posedge clk) begin
    if (rst) begin
        s0 <= 0;
        s1 <= 0;
        s2 <= 0;
        cnt <= 0;
        out <= 0;
        done <= 0;
    end else if(mod==1'b0) begin
        s0 <= {s0[2:0], in0};
        s1 <= {s1[2:0], in1};
        s2 <= {s2[2:0], in2};

        if (cnt == 3'd4) begin
            out <= {s2, s1, s0};
            done <= 1;
            cnt <= 0;
        end else begin
            cnt <= cnt + 1;
            done <= 0;
            
        end
    end
end

endmodule
