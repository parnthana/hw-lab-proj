`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2022 11:16:16 PM
// Design Name: 
// Module Name: baudrate
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


module baudrate(
    input clk,
    output reg baud
    );
    
    integer counter;
    always @(posedge clk) begin
        counter = counter + 1;
        if (counter == 325) begin counter = 0; baud = ~baud; end 
        // Clock = 10ns
        // ClockFreq = 1/10ns = 100 MHz
        // Baudrate = 9600
        // counter = ClockFreq/Baudrate/16/2
        // sampling every 16 ticks
    end
endmodule
