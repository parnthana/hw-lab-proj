`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2022 10:47:34 PM
// Design Name: 
// Module Name: calculator
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


module calculator(
    input signed [31:0] start_val,
    input signed [31:0] value_in,
    input [1:0] op,
    input reset,
    input enable,
    input clk,
    output reg signed [31:0] result,
    output reg overflow
    );
    reg signed [31:0] prev;
    reg signed [31:0] c1, c2, check;
    
    initial begin 
        prev = 0;
        overflow = 0;
    end
    always @(posedge clk)
    begin
        if(reset) begin 
            prev = 0; 
            result = 0;
            overflow = 0;
        end
        else if(enable) begin
            prev = prev + start_val;
            case(op)
                2'b00: result = prev + value_in; // +
                2'b01: result = prev - value_in; // -
                2'b10: begin // *
                   result = prev * value_in;
                   c1 = (prev<0) ? -prev : prev;
                   c2 = (value_in<0) ? -value_in : value_in;
                   check = c1 * c2;
                   if(c2 != 0 && check < c1) overflow=1;
                end
                2'b11: begin // /
                    if(value_in == 0) overflow=1;
                    else result = prev / value_in;
                end        
            endcase
            prev = result;
            if(result>9999 || result<-9999) overflow=1;
        end
    end

endmodule
