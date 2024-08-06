`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2024 23:11:52
// Design Name: 
// Module Name: output_mapping
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

module output_mapping(
input signed [19:0] x, 
input signed [19:0] y,
input [2:0] quadrant_loc,
output reg signed [19:0] x_res,
output reg signed [19:0] y_res
    );
    
// Updating the x values of the result
always@(*)
    begin
        if (quadrant_loc == 3'd2) x_res = -y;
        else if (quadrant_loc == 3'd3) x_res = -x;
        else  x_res = x;// including both 1st and 4th quadrant      
    end
 
// Updating the y values of the result   
 always@(*)
   begin
     if (quadrant_loc == 3'd2)       y_res = x;
     else if (quadrant_loc == 3'd3)  y_res = -y;
     else                            y_res = y; 
   end
    
endmodule
