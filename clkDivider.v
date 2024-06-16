`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 10:40:48
// Design Name: 
// Module Name: clkDivider
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


module clkDivider(clk, clkOut);
input clk;
output reg clkOut=0;

reg [31:0] count = 0;

always@(negedge clk)
begin
    if (count == 49999999)
    //if (count == 9)
    begin
        clkOut <= ~clkOut;
        count <= 0;
    end
    else
        count <= count + 1;
end
endmodule