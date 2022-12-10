`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2022 03:53:48 PM
// Design Name: 
// Module Name: strToInt
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


module strToInt(
    input [39:0] num_str,
    output signed [31:0] num_int
    );
    wire [7:0] snum0, snum1, snum2, snum3, sign1;
    wire [3:0] inum0, inum1, inum2, inum3;
    wire signed [3:0] sign2;
    wire signed [31:0] val0, val1, val2, val3;
    
    assign {sign1,snum3,snum2,snum1,snum0} = num_str;
    
    charToInt c0(snum0, inum0);
    charToInt c1(snum1, inum1);
    charToInt c2(snum2, inum2);
    charToInt c3(snum3, inum3);
    
    assign val3 = inum3*1000;
    assign val2 = inum2*100;
    assign val1 = inum1*10;
    assign val0 = inum0;
    assign sign2 = (sign1==8'h2D) ? -1: 1;
    assign num_int = (val3+val2+val1+val0)*sign2;

endmodule


module charToInt(
    input [7:0] c,
    output reg [3:0] i
    );
    
    always @(c) begin
        case(c)
            8'h30: i=0;
            8'h31: i=1;
            8'h32: i=2;
            8'h33: i=3;
            8'h34: i=4;
            8'h35: i=5;
            8'h36: i=6;
            8'h37: i=7;
            8'h38: i=8;
            8'h39: i=9;
            default: i=0;
        endcase
    end
endmodule