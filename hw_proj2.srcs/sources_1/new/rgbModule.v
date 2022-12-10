`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/10/2022 12:29:17 PM
// Design Name: 
// Module Name: rgbModule
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


module rgbModule(input clk,output [11:0]rgb_out);

    reg rgb=12'hE00;
    reg [2:0]state;

    wire [2:0] tclk;
    
    assign tclk[0]=clk;
    
    genvar c;
    generate for(c=0;c<2;c=c+1) begin
        clockDiv fDiv(tclk[c+1],tclk[c]);
    end endgenerate

    always@(posedge tclk[1])begin
        if(rgb==12'hE00) state<=0;
        if(rgb==12'hEE0) state<=1;
        if(rgb==12'h0E0) state<=2;
        if(rgb==12'h0EE) state<=3;
        if(rgb==12'h00E) state<=4;
        if(rgb==12'hE0E) state<=5;
    end

    always@(posedge tclk[2])begin
    case(state)
        3'd0: rgb<=rgb+12'h010;
        3'd1: rgb<=rgb-12'h100;
        3'd2: rgb<=rgb+12'h001;
        3'd3: rgb<=rgb-12'h010;
        3'd4: rgb<=rgb+12'h100;
        3'd5: rgb<=rgb-12'h001;
    endcase
end

    assign rgb_out = rgb;

endmodule
