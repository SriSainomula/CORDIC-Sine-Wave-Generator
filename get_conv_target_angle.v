`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05.08.2024 23:10:59
// Design Name: 
// Module Name: get_conv_target_angle
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

module get_conv_target_angle(
input signed [19:0] target_angle,
output reg signed [19:0] target_angle_conv,
output reg [2:0] quadrant_loc
    );
  
  
  // Shifting the angles by the appropriate amount  
  always@(*)
    begin
        if ((target_angle >{16'd90,4'd0}) && (target_angle <= {16'd180,4'd0})) target_angle_conv = target_angle - {16'd90,4'd0};
        else if ((target_angle >{16'd180,4'd0}) && (target_angle <= {16'd270,4'd0})) target_angle_conv = target_angle - {16'd180,4'd0};
        else if ((target_angle > {16'd270,4'd0}) && (target_angle <= {16'd360,4'd0})) target_angle_conv = target_angle - {16'd360,4'd0};
        else target_angle_conv = target_angle;
    end 
  
    
  always@(*)
    begin
        if ((target_angle >{16'd90,4'd0}) && (target_angle <= {16'd180,4'd0})) quadrant_loc = 3'd2;
        else if ((target_angle >{16'd180,4'd0}) && (target_angle <= {16'd270,4'd0})) quadrant_loc = 3'd3;
        else if ((target_angle > {16'd270,4'd0}) && (target_angle <= {16'd360,4'd0})) quadrant_loc = 3'd4;
        else quadrant_loc = 3'd1;
    end    
endmodule
