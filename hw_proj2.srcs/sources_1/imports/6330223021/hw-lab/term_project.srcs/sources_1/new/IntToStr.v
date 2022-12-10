`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2022 09:18:34 PM
// Design Name: 
// Module Name: IntToStr
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IntToStr(
    input signed [31:0] num_int,
    output [39:0] num_str
    );
    wire [7:0] snum0, snum1, snum2, snum3, sign;
    wire [3:0] inum0, inum1, inum2, inum3;
    wire [3:0] i0, i1, i2, i3;
    wire neg;
    wire [31:0] val;
    
    assign neg = (num_int<0);
    assign sign = (neg) ? 8'h2D : 8'h00;
    assign val = (neg) ? -num_int: num_int;
    assign i0 = val % 10;
    assign i1 = (val / 10) % 10;
    assign i2 = (val / 100) %10;
    assign i3 = val / 1000;
   
    IntToChar c0(inum0, snum0);
    IntToChar c1(inum1, snum1);
    IntToChar c2(inum2, snum2);
    IntToChar c3(inum3, snum3);
    
    assign num_str = {sign, snum3, snum2, snum1, snum0};
    
endmodule


module IntToChar(
    input [3:0] i, 
    output reg [7:0] c
    );
    
    always @(i) begin
        case(i)
            0: c=8'h30;
            1: c=8'h31;
            2: c=8'h32;
            3: c=8'h33;
            4: c=8'h34;
            5: c=8'h35;
            6: c=8'h36;
            7: c=8'h37;
            8: c=8'h38;
            9: c=8'h39;
        endcase
    end
endmodule