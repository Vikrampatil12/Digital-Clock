`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.04.2024 10:44:19
// Design Name: 
// Module Name: digital_clock
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


module digital_clock(
input clk,
input rst,
input set,
input hrup,
input minup,
input clockdisplay,
input alarm,
input set_alarm,
input alarmhrs_up,
input alarmmins_up,
output reg alarm_triggered,
input stopwatch,
input stopwatchstart,
input stopwatchreset,
output reg [3:0] Anode_Activation,
 output reg[6:0] Cathode_Activation,
 output reg[4:0]hours=0,
 output reg [5:0] stopwatch_mins=0
 );

reg  [4:0]set_alarm_hours=0;
reg  [5:0]set_alarm_mins=0;
reg [6:0] stopwatch_ms=0;
reg [5:0] stopwatch_secs=0;


wire divclk;
wire clocksw;
reg [5:0] secs=0;
reg [5:0]mins=0;

clkDivider clkDividerInst(clk,divclk);
clockdividersw stopwatchclkdivider1(clk,clocksw);

always @(posedge divclk or posedge rst)
begin
    if (rst == 1)
    begin
        secs <= 0;
        mins <= 0;
        hours <= 0;
    end 
    else
    begin
        if (alarm==1)
        begin
            if (set_alarm_hours == hours && set_alarm_mins == mins)
                alarm_triggered <= 1;
            else
                alarm_triggered <= 0;
        end
        
        if(alarm==0)
        alarm_triggered=0;

        if (set == 1)
        begin
            if (minup == 1) begin
                mins <= mins + 1;
                if(mins==59)
                mins<=0;
                end
            if (hrup == 1)begin
                hours <= hours + 1;
                if (hours==23)
                hours<=0;
                end
        end
        else
        begin
            if (secs == 59)
            begin
                secs <= 0;
                if (mins == 59)
                begin
                    mins <= 0;
                    if (hours == 23)
                        hours <= 0;
                    else
                        hours <= hours + 1;
                end
                else
                    mins <= mins + 1;
            end
            else
                secs <= secs + 1;
        end
    end
end

always @(posedge divclk) begin
     begin
        if (set_alarm == 1) begin
            if (alarmhrs_up) begin
                // Increment hour
                if (set_alarm_hours == 23)
                    set_alarm_hours <= 0;
                else
                    set_alarm_hours <= set_alarm_hours + 1;
            end
            if (alarmmins_up) begin
                // Increment minute
                if (set_alarm_mins == 59)
                    set_alarm_mins <= 0;
                else
                    set_alarm_mins <= set_alarm_mins + 1;
            end
        end
    end
end


always @(posedge clocksw)
begin
if(stopwatchreset==1)
begin
stopwatch_ms<=0;
stopwatch_secs<=0;
stopwatch_mins<=0;
end

if(stopwatch==1 && stopwatchstart==1)
begin
stopwatch_ms<=stopwatch_ms+1;
if(stopwatch_ms==99)
begin
stopwatch_secs=stopwatch_secs+1;
stopwatch_ms<=0;
if(stopwatch_secs==59)
begin
stopwatch_mins=stopwatch_mins+1;
stopwatch_secs<=0;
end
end
end
end


reg [3:0] LED_BCD;
reg [19:0] refresh_counter;
wire [1:0] LED_activation_counter;

always @(posedge clk or posedge rst) begin
    if (rst == 1) begin
        refresh_counter <= 0;
    end else begin
        refresh_counter <= refresh_counter + 1;
    end
end
assign LED_activation_counter = refresh_counter[19:18];

always @(*) begin
    case(LED_activation_counter)
    2'b00: begin
        Anode_Activation = 4'b0111; 
        // activate LED1 and Deactivate LED2, LED3, LED4
       if(set_alarm==0 && stopwatch==0)
        LED_BCD = mins/10;
        if(set_alarm==1 && stopwatch==0)
        LED_BCD=set_alarm_hours/10;
        if(stopwatch==1 && set_alarm==0)
        LED_BCD=stopwatch_secs/10;
        // the first digit of the 16-bit number
    end
    2'b01: begin
        Anode_Activation = 4'b1011; 
        // activate LED2 and Deactivate LED1, LED3, LED4
        if(set_alarm==0 && stopwatch==0)
        LED_BCD = mins%10;
        if(set_alarm==1 && stopwatch==0)
        LED_BCD=set_alarm_hours%10;
        if(stopwatch==1 && set_alarm==0)
        LED_BCD=stopwatch_secs%10;
        // the second digit of the 16-bit number
    end
    2'b10: begin
        Anode_Activation = 4'b1101; 
        // activate LED3 and Deactivate LED2, LED1, LED4
        if(set_alarm==0 && stopwatch==0)
        LED_BCD = secs/10;
        if(set_alarm==1 && stopwatch==0)
        LED_BCD=set_alarm_mins/10;
        if(stopwatch==1 && set_alarm==0)
        LED_BCD=stopwatch_ms/10;
        // the third digit of the 16-bit number
    end
    2'b11: begin
        Anode_Activation = 4'b1110; 
        // activate LED4 and Deactivate LED2, LED3, LED1
        if(set_alarm==0 && stopwatch==0)
        LED_BCD = secs%10;
        if(set_alarm==1 && stopwatch==0)
        LED_BCD=set_alarm_mins%10;
        if(stopwatch==1 && set_alarm==0)
        LED_BCD=stopwatch_ms%10;
        // the fourth digit of the 16-bit number    
    end
    endcase
end
always @(*) begin
    case(LED_BCD)
    4'b0000: Cathode_Activation = 7'b0000001; // "0"     
    4'b0001: Cathode_Activation = 7'b1001111; // "1" 
    4'b0010: Cathode_Activation = 7'b0010010; // "2" 
    4'b0011: Cathode_Activation = 7'b0000110; // "3" 
    4'b0100: Cathode_Activation = 7'b1001100; // "4" 
    4'b0101: Cathode_Activation = 7'b0100100; // "5" 
    4'b0110: Cathode_Activation = 7'b0100000; // "6" 
    4'b0111: Cathode_Activation = 7'b0001111; // "7" 
    4'b1000: Cathode_Activation = 7'b0000000; // "8"     
    4'b1001: Cathode_Activation = 7'b0000100; // "9" 
    default: Cathode_Activation = 7'b0000001; // "0"
    endcase
end

endmodule



