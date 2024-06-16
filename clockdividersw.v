`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.04.2024 08:28:13
// Design Name: 
// Module Name: clockdividersw
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


module clockdividersw(clk, clkOutsw);
input clk;
output reg clkOutsw=0;

reg [31:0] count = 0;

always@(negedge clk)
begin
    if (count == 499999)
    //if (count == 9)
    begin
        clkOutsw <= ~clkOutsw;
        count <= 0;
    end
    else
        count <= count + 1;
end
endmodule