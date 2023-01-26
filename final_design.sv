// VLSI Final Project: 8-bit simple calculator
// Supports fast addition/subtraction, fast multplication and 2^y
// Name: Rushabh Patel


module simple_calculator(x,y,operation,out);

  // Assign all inpputs
  input [7:0] x,y;
  input [2:0] operation;

  // Assign all outputs
  output reg [15:0] out;  // Multplying two 8 bit numbers can result in amaximum of a 16 bit output


  reg signed [15:0] adder_out;   // Stores the output from addition/subtraction operation
  reg signed [15:0] multiplier_out;  // Stores the output from multplication operation
  
  reg trigger;    // Used to trigger the addition operation
  reg booth_trigger;  // Used to trigger the booth multiplier
  
  integer i;
  
  reg signed [15:0] input_x;

  reg carry_in, carry_out;
  
  reg signed [15:0] yy;

  carry_lookahead_adder_16bit cla(input_x,yy,carry_in,adder_out,carry_out,trigger);
  booth_multiplier bm(x,y,multiplier_out,booth_trigger);
	
  always @(*)
    begin
      if (operation == 3'b000) begin
        input_x = {8'b00000000,x[7:0]};
        yy = {8'b00000000,y[7:0]};
        carry_in = 0;
        trigger = 1;
        #40
        out = adder_out;
        trigger = 0;
      end
      else if(operation == 3'b001) begin
        input_x = {8'b00000000,x[7:0]};
        yy = (~({8'b00000000,y[7:0]})) + 7'b1; // Should it be 8'b1 or 7'b1
        // yy = ~y + 7'b1;
        
        trigger = 1;
        #40
		out = adder_out;
        trigger = 0;
      end
      else if(operation == 3'b011) begin
      	booth_trigger = 1;
        booth_trigger = 0;
        out = multiplier_out;
      end
      else if(operation == 3'b100) begin
        carry_in = 1;
      	out = 2**y;
      end
    end
endmodule


module half_adder(x,y,sum,carry_out);
    // Assign all inputs and outputs
    input x,y;
    output reg sum,carry_out;

    assign sum = x ^ y;
    assign carry_out = x & y;
endmodule

module full_adder(x,y,carry_in,sum,carry_out);
    // Assign all inputs and outputs
    input  x,y,carry_in;
    output reg sum,carry_out;

    reg intermediate_sum1,intermediate_carry1,intermediate_carry2,final_sum;
    // Instaniate the two half adders that will be used
    half_adder ha1(x,y,intermediate_sum1,intermediate_carry1);
    half_adder ha2(intermediate_carry1,carry_in,final_sum,intermediate_carry2);
    assign carry_out = intermediate_carry1 | intermediate_carry2;
    assign sum = final_sum;
endmodule



module booth_multiplier(x,y,product,trigger);
    // Assign all inputs and outputs
    input [7:0] x,y;    // X is the multiplicand and Y is the multplier
    input trigger;      
    output reg [15:0] product;

    reg signed [15:0] adder_sum;

    reg signed [15:0] partial_products[1:0];   // Store all partial products in an array


    integer i;
    integer j;

    reg [4:0] bit_enconding_temp;
    reg [4:0] bit_enconding;

    reg cla_trigger,carry_in,carry_out;


  carry_lookahead_adder_16bit cla(partial_products[0],partial_products[1],carry_in,product,carry_out,cla_trigger);

    // Get the booth encoding and get the corresponding partial product
    always @(posedge trigger) begin
      for(i=0;i<2;i = i + 1) begin
            if (i == 0) begin
                bit_enconding_temp = y[3:0];
                bit_enconding = bit_enconding_temp << 1;
                
                case (bit_enconding)
                    5'b00000:partial_products[i] = 16'b0000000000000000; 
                    5'b00001:partial_products[i] = {8'b00000000,x[7:0]};
                    5'b00010:partial_products[i] = {8'b00000000,x[7:0]};
                    5'b00011:partial_products[i] = {8'b00000000,x[7:0]} << 1;
                    5'b00100:partial_products[i] = {8'b00000000,x[7:0]} << 1;
                    5'b00101:partial_products[i] = ({8'b00000000,x[7:0]} << 1) + (x[7:0]);
                    5'b00110:partial_products[i] = ({8'b00000000,x[7:0]} << 1) + (x[7:0]);
                    5'b00111:partial_products[i] = {8'b00000000,x[7:0]} << 2;
                    5'b01000:partial_products[i] = {8'b00000000,x[7:0]} << 2;
                    5'b01001:partial_products[i] = ({8'b00000000,x[7:0]} << 2) + (x[7:0]); 
                    5'b01010:partial_products[i] = ({8'b00000000,x[7:0]} << 2) + (x[7:0]);
                    5'b01011:partial_products[i] = ({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]);
                    5'b01100:partial_products[i] = ({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]);
                    5'b01101:partial_products[i] = ({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0]);
                    5'b01110:partial_products[i] = ({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0]);
                    5'b01111:partial_products[i] = {8'b00000000,x[7:0]} << 3;
                    5'b10000:partial_products[i] = ~({8'b00000000,x[7:0]} << 3) + 16'b1;
                    5'b10001:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0])) + 16'b1;
                    5'b10010:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0])) + 16'b1;
                    5'b10011:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0])) + 16'b1;
                    5'b10100:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0])) + 16'b1;
                    5'b10101:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0])) + 16'b1;
                    5'b10110:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0])) + 16'b1;
                    5'b10111:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2)) + 16'b1;
                    5'b11000:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2)) + 16'b1;
                    5'b11001:partial_products[i] = ~(({8'b00000000,x[7:0]} << 1) + (x[7:0])) + 16'b1;
                    5'b11010:partial_products[i] = ~(({8'b00000000,x[7:0]} << 2) + (x[7:0])) + 16'b1;
                    5'b11011:partial_products[i] = ~(({8'b00000000,x[7:0]} << 1)) + 16'b1;
                    5'b11100:partial_products[i] = ~(({8'b00000000,x[7:0]} << 1)) + 16'b1;
                    5'b11101:partial_products[i] = ~(({8'b00000000,x[7:0]})) + 16'b1;
                    5'b11110:partial_products[i] = ~(({8'b00000000,x[7:0]})) + 16'b1;
                    5'b11111:partial_products[i] = 16'b0000000000000000;
                endcase 

            end
            else begin
                bit_enconding_temp = y[7:3];
                case (bit_enconding_temp)
                    5'b00000:partial_products[i] = 16'b0000000000000000 << 4; 
                    5'b00001:partial_products[i] = {8'b00000000,x[7:0]} << 4;
                    5'b00010:partial_products[i] = {8'b00000000,x[7:0]} << 4;
                    5'b00011:partial_products[i] = ({8'b00000000,x[7:0]} << 1) << 4;
                    5'b00100:partial_products[i] = ({8'b00000000,x[7:0]} << 1) << 4;
                    5'b00101:partial_products[i] = (({8'b00000000,x[7:0]} << 1) + (x[7:0])) << 4;
                    5'b00110:partial_products[i] = (({8'b00000000,x[7:0]} << 1) + (x[7:0])) << 4;
                    5'b00111:partial_products[i] = ({8'b00000000,x[7:0]} << 2) << 4;
                    5'b01000:partial_products[i] = ({8'b00000000,x[7:0]} << 2) << 4;
                    5'b01001:partial_products[i] = (({8'b00000000,x[7:0]} << 2) + (x[7:0])) << 4; 
                    5'b01010:partial_products[i] = (({8'b00000000,x[7:0]} << 2) + (x[7:0])) << 4; 
                    5'b01011:partial_products[i] = (({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0])) << 4;
                    5'b01100:partial_products[i] = (({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0])) << 4;
                    5'b01101:partial_products[i] = (({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0])) << 4;
                    5'b01110:partial_products[i] = (({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0])) << 4;
                    5'b01111:partial_products[i] = ({8'b00000000,x[7:0]} << 3) << 4;
                    5'b10000:partial_products[i] = (~({8'b00000000,x[7:0]} << 3) + 16'b1) << 4;
                    5'b10001:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0])) + 16'b1) << 4;
                    5'b10010:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0]) + (x[7:0])) + 16'b1) << 4;
                    5'b10011:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0])) + 16'b1) <<4;
                    5'b10100:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2) + (x[7:0]) + (x[7:0])) + 16'b1) <<4;
                    5'b10101:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2) + (x[7:0])) + 16'b1) << 4;
                    5'b10110:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2) + (x[7:0])) + 16'b1) << 4;
                    5'b10111:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2)) + 16'b1) << 4;
                    5'b11000:partial_products[i] = (~(({8'b00000000,x[7:0]} << 2)) + 16'b1) << 4;
                    5'b11001:partial_products[i] = (~(({8'b00000000,x[7:0]} << 1) + (x[7:0])) + 16'b1) << 4;
                    5'b11010:partial_products[i] = (~(({8'b00000000,x[7:0]} << 1) + (x[7:0])) + 16'b1) << 4;
                    5'b11011:partial_products[i] = (~(({8'b00000000,x[7:0]} << 1)) + 16'b1) << 4;
                    5'b11100:partial_products[i] = (~(({8'b00000000,x[7:0]} << 1)) + 16'b1) << 4;
                    5'b11101:partial_products[i] = (~(({8'b00000000,x[7:0]})) + 16'b1) << 4;
                    5'b11110:partial_products[i] = (~(({8'b00000000,x[7:0]})) + 16'b1) << 4;
                    5'b11111:partial_products[i] = 16'b0000000000000000 << 4;
                endcase                
            end
        end
      carry_in = 0;
      cla_trigger = 1;
      cla_trigger = 0;
    end
endmodule



module carry_lookahead_adder_16bit(x,y,cin,sum,cout,trigger);
  
 
  //Assign all inputs
  input signed [15:0] x,y;
  input cin;
  input trigger;
  
  // Assign all outputs
  output reg [15:0] sum;
  output reg cout;

  
  //Setup all the internal wires
  reg p0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15;
  reg g0,g1,g2,g3,g4,g5,g6,g7,g8,g9,g10,g11,g12,g13,g14,g15;
  reg c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13,c14,c15,c16;
  

 

  // Check the invert_y input, if it is 1 then we are performing subtraction
  // This requires us to invert the second operand before we compute the addition
  // If it invert_y is 0, then we are performing regular addition
  always @(posedge trigger) begin
    //Compute the propogation for each stage
    p0 = x[0] ^ y[0];
    p1 = x[1] ^ y[1];
    p2 = x[2] ^ y[2];
    p3 = x[3] ^ y[3];
    p4 = x[4] ^ y[4];
    p5 = x[5] ^ y[5];
    p6 = x[6] ^ y[6];
    p7 = x[7] ^ y[7];
    p8 = x[8] ^ y[8];
    p9 = x[9] ^ y[9];
    p10 = x[10] ^ y[10];
    p11 = x[11] ^ y[11];
    p12 = x[12] ^ y[12];
    p13 = x[13] ^ y[13];
    p14 = x[14] ^ y[14];
    p15 = x[15] ^ y[15];


    // Compute the generated for each stage
     g0 = x[0] & y[0];
     g1 = x[1] & y[1];
     g2 = x[2] & y[2];
     g3 = x[3] & y[3];
     g4 = x[4] & y[4];
     g5 = x[5] & y[5];
     g6 = x[6] & y[6];
     g7 = x[7] & y[7];
     g8 = x[8] & y[8];
     g9 = x[9] & y[9];
     g10 = x[10] & y[10];
     g11 = x[11] & y[11];
     g12 = x[12] & y[12];
     g13 = x[13] & y[13];
     g14 = x[14] & y[14];
     g15 = x[15] & y[15];

    // Compute the carry for each stage
     c1 = g0 | (p0 & cin);
     c2 = g1 | (p1 & g0) | (p1 & p0 & cin);
     c3 = g2 | (p2 & g1) | (p2 & p1 & g0) | (p2 & p1 & p0 & cin);
     c4 = g3 | (p3 & g2) | (p3 & p2 & g1) | (p3 & p2 & p1 & g0) | (p3 & p2 & p1 & p0 & cin);
     c5 = g4 | (p4 & g3) | (p4 & p3 & g2) | (p4 & p3 & p2 & g1) | (p4 & p3 & p2 & p1 & g0) | (p4 & p3 & p2 & p1 & p0 & cin);
     c6 = g5 | (p5 & g4) | (p5 & p4 & g3) | (p5 & p4 & p3 & g2) | (p5 & p4 & p3 & p2 & g1) | (p5 & p4 & p3 & p2 & p1 & g0) | (p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c7 = g6 | (p6 & g5) | (p6 & p5 & g4) | (p6 & p5 & p4 & g3) | (p6 & p5 & p4 & p3 & g2) | (p6 & p5 & p4 & p3 & p2 & g1) | (p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c8 = g7 | (p7 & g6) | (p7 & p6 & g5) | (p7 & p6 & p5 & g4) | (p7 & p6 & p5 & p4 & g3) | (p7 & p6 & p5 & p4 & p3 & g2) | (p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c9 = g8 | (p8 & g7) | (p8 & p7 & g6) | (p8 & p7 & p6 & g5) | (p8 & p7 & p6 & p5 & g4) | (p8 & p7 & p6 & p5 & p4 & g3) | (p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c10 = g9 | (p9 & g8) | (p9 & p8 & g7) | (p9 & p8 & p7 & g6) | (p9 & p8 & p7 & p6 & g5) | (p9 & p8 & p7 & p6 & p5 & g4) | (p9 & p8 & p7 & p6 & p5 & p4 & g3) | (p9 & p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c11 = g10 | (p10 & g9) | (p10 & p9 & g8) | (p10 & p9 & p8 & g7) | (p10 & p9 & p8 & p7 & g6) | (p10 & p9 & p8 & p7 & p6 & g5) | (p10 & p9 & p8 & p7 & p6 & p5 & g4) | (p10 & p9 & p8 & p7 & p6 & p5 & p4 & g3) | (p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c12 = g11 | (p11 & g10) | (p11 & p10 & g9) | (p11 & p10 & p9 & g8) | (p11 & p10 & p9 & p8 & g7) | (p11 & p10 & p9 & p8 & p7 & g6) | (p11 & p10 & p9 & p8 & p7 & p6 & g5) | (p11 & p10 & p9 & p8 & p7 & p6 & p5 & g4) | (p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & g3) | (p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c13 = g12 | (p12 & g11) | (p12 & p11 & g10) | (p12 & p11 & p10 & g9) | (p12 & p11 & p10 & p9 & g8) | (p12 & p11 & p10 & p9 & p8 & g7) | (p12 & p11 & p10 & p9 & p8 & p7 & g6) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & g5) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & g4) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & g3) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c14 = g13 | (p13 & g12) | (p13 & p12 & g11) | (p13 & p12 & p11 & g10) | (p13 & p12 & p11 & p10 & g9) | (p13 & p12 & p11 & p10 & p9 & g8) | (p13 & p12 & p11 & p10 & p9 & p8 & g7) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & g6) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & g5) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & g4) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & g3) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
     c15 = g14 | (p14 & g13) | (p14 & p13 & g12) | (p14 & p13 & p12 & g11) | (p14 & p13 & p12 & p11 & g10) | (p14 & p13 & p12 & p11 & p10 & g9) | (p14 & p13 & p12 & p11 & p10 & p9 & g8) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & g7) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & g6) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & g5) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & g4) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & g3) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & g2) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & g1) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & g0) | (p14 & p13 & p12 & p11 & p10 & p9 & p8 & p7 & p6 & p5 & p4 & p3 & p2 & p1 & p0 & cin);
    
    
    // Compute the sum
     sum[0] = p0 ^ cin;
     sum[1] = p1 ^ c1;
     sum[2] = p2 ^ c2;
     sum[3] = p3 ^ c3;
     sum[4] = p4 ^ c4;
     sum[5] = p5 ^ c5;
     sum[6] = p6 ^ c6;
     sum[7] = p7 ^ c7;
     sum[8] = p8 ^ c8;
     sum[9] = p9 ^ c9;
     sum[10] = p10 ^ c10;
     sum[11] = p11 ^ c11;
     sum[12] = p12 ^ c12;
     sum[13] = p13 ^ c13;
     sum[14] = p14 ^ c14;
     sum[15] = p15 ^ c15;
    
    // Assign carry output
    cout = c15;
   	
  
  end
endmodule