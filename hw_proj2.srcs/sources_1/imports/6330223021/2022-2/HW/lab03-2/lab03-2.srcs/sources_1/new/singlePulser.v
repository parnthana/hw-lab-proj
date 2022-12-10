`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/12/2022 03:53:04 PM
// Design Name: 
// Module Name: singlePulser
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


module singlePulser(
    output reg z,
    input p,
    input clk
    );
    reg q = 0;
    always @(posedge clk) begin
        case({q,p})
            2'b00: begin q = 0; z=0; end
            2'b01: begin q = 1; z=1; end
            2'b10: begin q = 0; z=0; end
            2'b11: begin q = 1; z=0; end
        endcase
    end
endmodule
