`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.03.2024 11:36:05
// Design Name: 
// Module Name: cordic_sin_cos
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


module cordic_sin_cos(clk,rst,target_angle,x_res,y_res);
 input clk,rst;  // Input clock and reset signals
 input signed [19:0] target_angle;   // 20 bits to denote the target angle of rotation (16 bits including MSB for the integer part and 4 bits for the fractional part)
 
 
 output reg signed [19:0] x_res; // 20 bits (4 for integer part and 16 for fractional part) to store the x-coordinate of the final rotated vector
 output reg signed [19:0] y_res; // 20 bits (4 for integer part and 16 for fractional part) to store the y-coordinate of the final rotated vector
// output reg [19:0] final_rotation_angle; // dummy output register to overcome RTL error 
 
 wire signed [19:0] x_res_comb; // 20 bits (4 for integer part and 16 for fractional part) to store the x-coordinate of the final rotated vector
 wire signed [19:0] y_res_comb; // 20 bits (4 for integer part and 16 for fractional part) to store the y-coordinate of the final rotated vector
 
 reg signed [19:0] x [9:0];  // to store the x-coordinates of each step (4 bits for the integer part including MSB and 16 bits for the fractional part)
 reg signed [19:0] y [9:0];  // to store the y-coordinates of each step (4 bits for the integer part including MSB and 16 bits for the fractional part)
 
 wire signed[19:0] arc_tan [8:0];  // to store look up values of arc tan using 20 bits (16 bits including MSB to denote the integer part and 4 bits to denote the fractional part)
 reg  signed[19:0] z[8:0];  // Array of 20 bit registers to store the rotated angle 
 reg  d[8:0]; // Array of 1 bit registers to denote the direction of rotation. 1/0 => Anticlockwise / Clockwise rotation 
 
 wire signed [19:0] target_angle_conv;  // 20 bits to denote the target angle of rotation (16 bits including MSB for the integer part and 4 bits for the fractional part)
 
 wire [2:0] quadrant_loc; // the quadrant in which the target angle is located
 

 assign arc_tan[0] = {{6{1'b0}},10'b0000101101,4'b0000};   // 45      degrees
 assign arc_tan[1] = {{6{1'b0}},10'b0000011010,4'b1001};   // 26.565  degrees
 assign arc_tan[2] = {{6{1'b0}},10'b0000001110,4'b0000};   // 14.0362 degrees
 assign arc_tan[3] = {{6{1'b0}},10'b0000000111,4'b0010};   // 7.125   degrees
 assign arc_tan[4] = {{6{1'b0}},10'b0000000011,4'b1001};   // 3.5763  degrees
 assign arc_tan[5] = {{6{1'b0}},10'b0000000001,4'b1100};   // 1.7899  degrees
 assign arc_tan[6] = {{6{1'b0}},10'b0000000000,4'b1110};   // 0.8951  degrees
 assign arc_tan[7] = {{6{1'b0}},10'b0000000000,4'b0111};   // 0.4476  degrees
 assign arc_tan[8] = {{6{1'b0}},10'b0000000000,4'b0011};   // 0.2238  degrees
// assign arc_tan[9] = {{6{1'b0}},10'b0000000000,4'b0001};   // 0.1119  degrees

 get_conv_target_angle conv_angle(.target_angle(target_angle),.target_angle_conv(target_angle_conv),.quadrant_loc(quadrant_loc));
 output_mapping out_map(.x(x[9][19:0]),.y(y[9][19:0]),.quadrant_loc(quadrant_loc),.x_res(x_res_comb),.y_res(y_res_comb));
 
 always@(posedge clk)
  begin
    if (rst == 0)
       begin
         x_res [19:0]     <= 20'b0;
         y_res [19:0]     <= 20'b0;  
       end 
    else 
       begin
         x_res [19:0] <= x_res_comb;
         y_res [19:0] <= y_res_comb;
       end
  end

 // Place them in a separate always block as they are fixed (This helps us avoid numerous RTL errors)
 always@(*)
   begin
      x[0] = 20'b00001001101101110001; // x[0] = 0.6072 (4 bits for the integer part and 10 bits for the fractional part)
      y[0] = 20'b00000000000000000000; // y[0] = 0.0000 (4 bits for the integer part and 10 bits for the fractional part)
      z[0] = target_angle_conv; // First we always rotate by 0 degrees => Update the rotated angle accordingly
      d[0] = (z[0][19] == 0) ? 1 : 0;  //Using sign convention as 1 for +ve angle value and 0 for -ve angle value
   end
   
   
 always@(*)
   begin
//step 1
     x[1] = (d[0] == 1) ? (x[0] - y[0]) : (x[0]+y[0]);
     y[1] = (d[0] == 1) ? (y[0] + x[0]) : (y[0]-x[0]);
     z[1] = (d[0] == 1) ? (z[0] - arc_tan[0]) : (z[0]+arc_tan[0]);
     d[1] = (z[1][19] == 0) ? 1 : 0;
      

//step 2
     x[2] = (d[1] == 1) ? (x[1] - (y[1]>>>1)) : (x[1]+(y[1]>>>1));
     y[2] = (d[1] == 1) ? (y[1] + (x[1]>>>1)) : (y[1]-(x[1]>>>1));
     z[2] = (d[1] == 1) ? (z[1] - arc_tan[1]) : (z[1]+arc_tan[1]);
     d[2] = (z[2][19] == 0) ? 1 : 0;   
     
//step 3
     x[3] = (d[2] == 1) ? (x[2] - (y[2]>>>2)) : (x[2]+(y[2]>>>2));
     y[3] = (d[2] == 1) ? (y[2] + (x[2]>>>2)) : (y[2]-(x[2]>>>2));
     z[3] = (d[2] == 1) ? (z[2] - arc_tan[2]) : (z[2]+arc_tan[2]);
     d[3] = (z[3][19] == 0) ? 1 : 0; 
     
//step 4
     x[4] = (d[3] == 1) ? (x[3] - (y[3]>>>3)) : (x[3]+(y[3]>>>3));
     y[4] = (d[3] == 1) ? (y[3] + (x[3]>>>3)) : (y[3]-(x[3]>>>3));
     z[4] = (d[3] == 1) ? (z[3] - arc_tan[3]) : (z[3]+arc_tan[3]);
     d[4] = (z[4][19] == 0) ? 1 : 0; 
     
//step 5
     x[5] = (d[4] == 1) ? (x[4] - (y[4]>>>4)) : (x[4]+(y[4]>>>4));
     y[5] = (d[4] == 1) ? (y[4] + (x[4]>>>4)) : (y[4]-(x[4]>>>4));
     z[5] = (d[4] == 1) ? (z[4] - arc_tan[4]) : (z[4]+arc_tan[4]);
     d[5] = (z[5][19] == 0) ? 1 : 0; 
     
//step 6
     x[6] = (d[5] == 1) ? (x[5] - (y[5]>>>5)) : (x[5]+(y[5]>>>5));
     y[6] = (d[5] == 1) ? (y[5] + (x[5]>>>5)) : (y[5]-(x[5]>>>5));
     z[6] = (d[5] == 1) ? (z[5] - arc_tan[5]) : (z[5]+arc_tan[5]);
     d[6] = (z[6][19] == 0) ? 1 : 0; 
     
//step 7
     x[7] = (d[6] == 1) ? (x[6] - (y[6]>>>6)) : (x[6]+(y[6]>>>6));
     y[7] = (d[6] == 1) ? (y[6] + (x[6]>>>6)) : (y[6]-(x[6]>>>6));
     z[7] = (d[6] == 1) ? (z[6] - arc_tan[6]) : (z[6]+arc_tan[6]);
     d[7] = (z[7][19] == 0) ? 1 : 0; 
     
//step 8
     x[8] = (d[7] == 1) ? (x[7] - (y[7]>>>7)) : (x[7]+(y[7]>>>7));
     y[8] = (d[7] == 1) ? (y[7] + (x[7]>>>7)) : (y[7]-(x[7]>>>7));
     z[8] = (d[7] == 1) ? (z[7] - arc_tan[7]) : (z[7]+arc_tan[7]);
     d[8] = (z[8][19] == 0) ? 1 : 0; 
     
//step 9
     x[9] = (d[8] == 1) ? (x[8] - (y[8]>>>8)) : (x[8]+(y[8]>>>8));
     y[9] = (d[8] == 1) ? (y[8] + (x[8]>>>8)) : (y[8]-(x[8]>>>8));
     z[9] = (d[8] == 1) ? (z[8] - arc_tan[8]) : (z[8]+arc_tan[8]);
     d[9] = (z[9][19] == 0) ? 1 : 0; 
   end

endmodule