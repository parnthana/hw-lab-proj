`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////
// Authored by David J. Marion aka FPGA Dude
// Created on 4/11/2022
//
// Purpose: receive clock BCD values, write clock on VGA screen
///////////////////////////////////////////////////////////////////////

module vga_control(
    input clk,
    input video_on,
    input [9:0] x, y,
    input [3:0] D3,D2,D1,D0,
    input NEG,isNan,
    input [11:0]current_rgb,
    output reg [11:0] rgb
    );
  
    // *** Constant Declarations ***
    //DIGIT0=RIGHTMOSTDIGIT
    
    // DIGIT0 Digit section = 64 x 128
    localparam N_X_L = 128;
    localparam N_X_R = 191;
    localparam N_Y_T = 128;
    localparam N_Y_B = 255;
    
    // DIGIT1 Digit section = 64 x 128
    localparam D3_X_L = 192;
    localparam D3_X_R = 255;
    localparam D3_Y_T = 128;
    localparam D3_Y_B = 255;
    
    // DIGIT2 Digit section = 64 x 128
    localparam D2_X_L = 256;
    localparam D2_X_R = 319;
    localparam D2_Y_T = 128;
    localparam D2_Y_B = 255;
    
    // DIGIT3 Digit section = 64 x 128
    localparam D1_X_L = 320;
    localparam D1_X_R = 383;
    localparam D1_Y_T = 128;
    localparam D1_Y_B = 255;
    
    // NEG section = 64 x 128
    localparam D0_X_L = 384;
    localparam D0_X_R = 447;
    localparam D0_Y_T = 128;
    localparam D0_Y_B = 255;
    
    wire D0_on, D1_on, D2_on, D3_on, N_on;
    
    // ROM Interface Signals
    wire [10:0] rom_addr;
    reg [6:0] char_addr;   // 3'b011 + BCD value of digit component
    wire [6:0] char_addr_D0, char_addr_D1, char_addr_D2, char_addr_D3, char_addr_N;
    reg [3:0] row_addr;    // row address of digit
    wire [3:0] row_addr_D0, row_addr_D1, row_addr_D2, row_addr_D3, row_addr_N;
    reg [2:0] bit_addr;    // column address of rom data
    wire [2:0] bit_addr_D0, bit_addr_D1, bit_addr_D2, bit_addr_D3, bit_addr_N;
    wire [7:0] digit_word;  // data from rom
    wire digit_bit;
    
    
    assign char_addr_D0 = {3'b011, D0};
    assign row_addr_D0 = y[6:3];   // scaling to 64 x 128
    assign bit_addr_D0 = x[5:3];   // scaling to 64 x 128
    
    assign char_addr_D1 = {3'b011, D1};
    assign row_addr_D1 = y[6:3];   // scaling to 64 x 128
    assign bit_addr_D1 = x[5:3];   // scaling to 64 x 128
    
    assign char_addr_D2 = {3'b011, D2};
    assign row_addr_D2 = y[6:3];   // scaling to 64 x 128
    assign bit_addr_D2 = x[5:3];   // scaling to 64 x 128
    
    assign char_addr_D3 = {3'b011, D3};
    assign row_addr_D3 = y[6:3];   // scaling to 64 x 128
    assign bit_addr_D3 = x[5:3];   // scaling to 64 x 128
    
    assign char_addr_N = 7'h3a;
    assign row_addr_N = y[6:3];    // scaling to 64 x 128
    assign bit_addr_N = x[5:3];    // scaling to 64 x 128
    
    // Instantiate digit rom
    digits_rom cdr(.clk(clk), .addr(rom_addr), .data(digit_word));
    
    //DIGIT1 Assert Signal
    assign D0_on = (D0_X_L <= x) && (x <= D0_X_R) &&
                    (D0_Y_T <= y) && (y <= D0_Y_B);
                    
    //DIGIT1 Assert Signal  
    assign D1_on =  (D1_X_L <= x) && (x <= D1_X_R) &&
                    (D1_Y_T <= y) && (y <= D1_Y_B);
    
    //DIGIT1 Assert Signal  
    assign D2_on = (D2_X_L <= x) && (x <= D2_X_R) &&
                   (D2_Y_T <= y) && (y <= D2_Y_B);
    
    //DIGIT1 Assert Signal  
    assign D3_on = (D3_X_L <= x) && (x <= D3_X_R) &&
                    (D3_Y_T <= y) && (y <= D3_Y_B);
    
    //NEG Assert Signal
    assign N_on =  (N_X_L <= x) && (x <= N_X_R) &&
                    (N_Y_T <= y) && (y <= N_Y_B) && NEG;                             
        
    // Mux for ROM Addresses and RGB    
    always @* begin
        rgb = 12'h222;             // black background
        if(D0_on&&!isNan) begin
            char_addr = char_addr_D0;
            row_addr = row_addr_D0;
            bit_addr = bit_addr_D0;
            if(digit_bit)
                rgb = {4'hE,D0,D1};     // cycle rgb
        end
        else if (D0_on&isNan) begin
            char_addr = 7'h3c;
            row_addr = row_addr_D0;
            bit_addr = bit_addr_D0;
            if(digit_bit)
                rgb = {4'hE,D0,D1};     // cycle rgb
        end
        else if(D1_on&&!isNan) begin
            char_addr = char_addr_D1;
            row_addr = row_addr_D1;
            bit_addr = bit_addr_D1;
            if(digit_bit)
                rgb = {4'hE,D0,D1};     // cycle rgb
        end
        else if(D1_on&&isNan) begin
            char_addr = 7'h3b;
            row_addr = row_addr_D1;
            bit_addr = bit_addr_D1;
            if(digit_bit)
                rgb = {4'hE,D0,D1};     // cycle rgb
        end
        else if(D2_on&&!isNan) begin
            char_addr = char_addr_D2;
            row_addr = row_addr_D2;
            bit_addr = bit_addr_D2;
            if(digit_bit)
                rgb = {4'hE,D0,D1};     // cycle rgb
        end
        else if(D2_on&&isNan) begin
            char_addr = 7'h3c;
            row_addr = row_addr_D2;
            bit_addr = bit_addr_D2;
            if(digit_bit)
                rgb = {4'hE,D0,D1};   // cycle rgb
        end
        else if(D3_on&&!isNan) begin
            char_addr = char_addr_D3;
            row_addr = row_addr_D3;
            bit_addr = bit_addr_D3;
            if(digit_bit)
                rgb = {4'hE,D0,D1};    // cycle rgb
        end
        else if(N_on&&!isNan) begin
            char_addr = char_addr_N;
            row_addr = row_addr_N;
            bit_addr = bit_addr_N;
            if(digit_bit)
                rgb = {4'hE,D0,D1};    // cycle rgb
        end
        
        
    end    
    
    // ROM Interface    
    assign rom_addr = {char_addr, row_addr};
    assign digit_bit = digit_word[~bit_addr];

endmodule