`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/05/2022 07:49:46 PM
// Design Name: 
// Module Name: quadSevenSeg
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

module quadSevenSeg(
    output [6:0] seg,
    output reg dp,
    output an0,
    output an1,
    output an2,
    output an3,
    input [3:0] num0,
    input [3:0] num1,
    input [3:0] num2,
    input [3:0] num3,
    input clk,
    input [3:0] dots
    );
    
    reg [1:0] ns;
    reg [1:0] ps; 
    reg [3:0] dispEn; 
    
    reg [3:0] hexIn;
    wire [6:0] segments;
    assign seg=segments;
    
    hexToSevenSeg segDecode(segments,hexIn);
//    assign dp=0; 
    assign {an3,an2,an1,an0}=~dispEn;

    always @(posedge clk)
        ps=ns;
    
    always @(ps) 
        ns=ps+1;
    
    always @(ps)
        case(ps)
            2'b00: dispEn=4'b0001;
            2'b01: dispEn=4'b0010;
            2'b10: dispEn=4'b0100;
            2'b11: dispEn=4'b1000;
        endcase
    
    always @(ps)
        case(ps)
            2'b00: hexIn=num0;
            2'b01: hexIn=num1;
            2'b10: hexIn=num2;
            2'b11: hexIn=num3;
        endcase
        
    initial
        dp=0;
    always @(ps)
        case(ps)
            2'b00: dp=dots[0];
            2'b01: dp=dots[1];
            2'b10: dp=dots[2];
            2'b11: dp=dots[3];
        endcase
    
endmodule