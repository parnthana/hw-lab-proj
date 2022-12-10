`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2022 09:26:24 PM
// Design Name: 
// Module Name: system
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


module system(
    output wire [11:0]led, // debug state
    output [6:0] seg,
    output dp,
    output [3:0] an,
    output wire [3:0] vgaRed, vgaGreen, vgaBlue,
    output wire Hsync, Vsync,
    output wire RsTx, 
    input wire RsRx,
    input btnC,
    input clk
    );
    
    // uart
    reg en, last_rec;
    reg [7:0] data_in;
    wire [7:0] data_out;
    wire sent, received, baud;
    
    baudrate baudrate(clk, baud);
    uart_rx receiver(baud, RsRx, received, data_out);
    uart_tx transmitter(baud, data_in, en, sent, RsTx);
    
    // reset button
    wire reset;
    singlePulser sp(reset, btnC, baud);
    
    // calculator
    reg [1:0] op;
    reg cal_en;
    reg signed [31:0] start_val;
    wire signed [31:0] value_in;
    wire signed [31:0] result;
    wire overflow;
    calculator cal(start_val, value_in, op, reset, cal_en, baud, result, overflow);
    
    // manage input
    reg [1:0] state, prev_state;
    reg [39:0] str_in; // [39:32] sign, [31:0] value
    wire [39:0] str_out; // [39:32] sign, [31:0] value
    reg [1:0] next_op;
    reg [2:0] counter;
    initial begin
        state = 0;
        counter = 0;
        str_in = 0;
        op = 0;
        cal_en = 0;
        start_val = 0;
    end
    strToInt s(str_in, value_in);
    IntToStr i(result, str_out);
    
    always @(posedge baud) begin
        cal_en=0;
        if (en) en = 0;
        if (reset) begin
            state = 2'b00;
            str_in = 0;
        end
        if (~last_rec & received) begin        
            data_in = data_out;
            if (data_in != 8'hFF) en = 1;
                if(state == 2'b00 || state == 2'b10) begin
                    cal_en = 0;
                    if(data_out==8'h2D && counter == 0) str_in[39:32] = data_out;
                    else if(data_out >= 8'h30 && data_out <= 8'h39) begin
                        case(counter)
                            0: begin
                                str_in[31:24] = 0;
                                str_in[23:16] = 0;
                                str_in[15:8] = 0;
                                str_in[7:0] = data_out;
                            end
                            1: begin
                                str_in[31:24] = 0;
                                str_in[23:16] = 0;
                                str_in[15:8] = str_in[7:0];
                                str_in[7:0] = data_out;
                            end
                            2: begin
                                str_in[31:24] = 0;
                                str_in[23:16] = str_in[15:8];
                                str_in[15:8] = str_in[7:0];
                                str_in[7:0] = data_out;
                            end
                            3: begin
                                str_in[31:24] = str_in[23:16];
                                str_in[23:16] = str_in[15:8];
                                str_in[15:8] = str_in[7:0];
                                str_in[7:0] = data_out;
                            end
                        endcase
                        counter = counter + 1;
                    end
                    else begin
                        if(state==2'b00) begin
                            start_val = value_in;
                            state = 2'b01;
                            prev_state = 2'b00;
                        end
                        else if (state==2'b10 && data_out == 8'h3D) state = 2'b11;
                    end
                end
                if(state == 2'b01 || state == 2'b11) begin
                    counter = 0;
                    if(state==2'b01) begin
                        cal_en = 0;
                        if(prev_state == 2'b11) start_val = 0;
                        case(data_out)
                            8'h2B: op = 2'b00; // +
                            8'h2D: op = 2'b01; // -
                            8'h2A: op = 2'b10; // *
                            8'h2F: op = 2'b11; // /
                        endcase
                        str_in = 0;
                        state = 2'b10;
                    end
                    else if (state==2'b11) begin
                        cal_en = 1;
                        state = 2'b01;
                        prev_state = 2'b11;
                    end
                end 
        end
        last_rec = received;
    end
    
    // check input from UART
//    reg [3:0] num3,num2,num1,num0;
//    reg [3:0] dots;
//    wire an0,an1,an2,an3;
//    assign an={an3,an2,an1,an0};
//
//    reg neg;
//    reg [31:0] res;
//    always @(*) begin
//        neg = (value_in<0);
//        res = (neg) ? -value_in:value_in;
//        case(state[0])
//            0: begin
//                num3=res/1000;
//                num2=(res/100)%10;
//                num1=(res/10)%10;
//                num0=res%10;
//                dots=(neg) ? 4'b0111: 4'b1111;
//            end
//            1: begin
//                num3=0;
//                num2=0;
//                num1=op[1];
//                num0=op[0];
//                dots=4'b0000;
//            end
//        endcase
//    end
//    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,baud,dots);

    // debug result
    reg [3:0] lout;
    reg [3:0] lout2;
    assign led[3:0] = lout;
    assign led[7:4] = lout2;
    always @(*) begin
        case({cal_en,state})
            3'b000: lout = 4'b0000;
            3'b100: lout = 4'b1000;
            3'b001: lout = 4'b0001;
            3'b101: lout = 4'b1001;
            3'b010: lout = 4'b0010;
            3'b110: lout = 4'b1010;
            3'b011: lout = 4'b0011;
            3'b111: lout = 4'b1011;
        endcase
        if(result == 0) lout[2] = 1;
        else if (result) lout[2] = 0;
        
        if(result<0) lout2[0] = 1;
        else if(result>0) lout2[0] = 0;
        
        if(value_in<0) lout2[1] = 1;
        else if(value_in>0) lout2[1] = 0; 
    end
    
    // output 7 seg    
    reg [3:0] num3,num2,num1,num0;
    reg [3:0] dots;
    wire an0,an1,an2,an3;
    assign an={an3,an2,an1,an0};
    
    wire neg;
    wire [31:0] res_pos;
    assign neg = (result<0);
    assign res_pos = (neg) ? -result: result;
      
    always @(*) begin
        if(data_out == 8'h3D || reset) begin
            case(overflow)
                0: begin
                    num3=res_pos/1000;
                    num2=(res_pos/100)%10;
                    num1=(res_pos/10)%10;
                    num0=res_pos%10;
                    if(neg) dots=4'b0111;
                    else dots=4'b1111;
                end
                1: begin // NaN
                    num3=4'b1111;
                    num2=4'b1111;
                    num1=4'b1111;
                    num0=4'b1111;
                    dots=4'b0000;
                end
            endcase
        end
    end
    quadSevenSeg q7seg(seg,dp,an0,an1,an2,an3,num0,num1,num2,num3,baud,dots);
    
    // rgbCycle module
    wire [11:0]rgb_cycle;
    rgbModule(targetClk,rgb_cycle);
    
    // vga
    vga_control vga_control(clk,video_on,x, y,
                num3,num2,num1,num0,
                neg,overflow,rgb_cycle,
                {vgaRed, vgaGreen, vgaBlue}
    );
    
    wire video_on,p_tick;
    wire [9:0] x, y;
    
    vga_sync vga_sync(clk, reset,Hsync, Vsync, video_on, p_tick,x, y);
    
endmodule
