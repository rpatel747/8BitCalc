// Code your testbench here
// or browse Examples

module calculator_testbench;
  reg [7:0] x,y;
  reg [15:0] out;
  reg [2:0] operation;
  
  reg [7:0] input_x,input_y;
  
  simple_calculator sc(input_x,input_y,operation,out);
  
  
  initial begin
    $display("**TO GET EXPECTED VALUES THE BUILT IN OPERATIONS PROVIDED BY VERILOG WERE USED **");
    $display("Testing Operation: Addition");
    input_x = 8'b00000001;
    input_y = 8'b00000001;
    operation = 3'b000;
    #100
    $display("Test 1: X = %b ,Y = %b ,X+Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x+input_y);

    input_x = 8'b00000010;
    input_y = 8'b00000010;
    operation = 3'b000;
    #100
    $display("Test 2: X = %b ,Y = %b ,X+Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x+input_y);    
    
    input_x = 8'b10000000;
    input_y = 8'b01000000;
    operation = 3'b000;
    #100
    $display("Test 3: X = %b ,Y = %b ,X+Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x+input_y);     
    
    input_x = 8'b00000111;
    input_y = 8'b01101011;
    operation = 3'b000;
    #100
    $display("Test 4: X = %b ,Y = %b ,X+Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x+input_y); 
    
    input_x = 8'b10001100;
    input_y = 8'b01111000;
    operation = 3'b000;
    #100
    $display("Test 5: X = %b ,Y = %b ,X+Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x+input_y); 
    
    
    $display("Testing Operation: Subtraction - - - - - - - - - - - - - - - - - - ");
    #100
    input_x = 8'b00000001;
    input_y = 8'b00000001;
    operation = 3'b001;
    #100
    $display("Test 6:   X = %b ,Y = %b ,X-Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x-input_y);
    
    #100
    input_x = 8'b00000010;
    input_y = 8'b00000001;
    operation = 3'b001;
    #100
    $display("Test 7:   X = %b ,Y = %b ,X-Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x-input_y);

    #100
    input_x = 8'b00000100;
    input_y = 8'b00000010;
    operation = 3'b001;
    #100
    $display("Test 8:   X = %b ,Y = %b ,X-Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x-input_y);
    
    
    #100
    input_x = 8'b00001000;
    input_y = 8'b00000001;
    operation = 3'b001;
    #100
    $display("Test 9:   X = %b ,Y = %b ,X-Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x-input_y);
    
    
    #100
    input_x = 8'b10000000;
    input_y = 8'b00010000;
    operation = 3'b001;
    #100
    $display("Test 10:  X = %b ,Y = %b ,X-Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x-input_y);
    
    
    
    
    
    
    $display("Testing Operation: Multiplication - - - - - - - - - - - - - - - - - ");
    #100
    input_x = 8'b00000010;
    input_y = 8'b00000010;
    operation = 3'b011;
    #100
    $display("Test 11:  X = %b ,Y = %b ,X*Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x*input_y);

    input_x = 8'b00000100;
    input_y = 8'b00000010;
    operation = 3'b011;
    #100
    $display("Test 12:  X = %b ,Y = %b ,X*Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x*input_y);
    
    input_x = 8'b00010000;
    input_y = 8'b00000100;
    operation = 3'b011;
    #100
    $display("Test 13:  X = %b ,Y = %b ,X*Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x*input_y);
    
    input_x = 8'b00010000;
    input_y = 8'b00000010;
    operation = 3'b011;
    #100
    $display("Test 14:  X = %b ,Y = %b ,X*Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x*input_y);
    
    input_x = 8'b00000010;
    input_y = 8'b00000000;
    operation = 3'b011;
    #100
    $display("Test 15:  X = %b ,Y = %b ,X*Y = %b, Expected = %b",input_x,input_y,out[7:0],input_x*input_y);
    
    
    $display("Testing Operation: 2^y - - - - - - - - - - - - - - - - - - - ");
    $display("The operand x does not matter, only y is important");
    
    input_x = 8'b00000000;
    input_y = 8'b00000001;
    operation = 3'b100;
    #100
    $display("Test 16:  X = %b ,Y = %b ,2^Y = %b, Expected = %b",input_x,input_y,out,2**input_y);
    
    input_x = 8'b00000000;
    input_y = 8'b00000010;
    operation = 3'b100;
    #100
    $display("Test 17:  X = %b ,Y = %b ,2^Y = %b, Expected = %b",input_x,input_y,out,2**input_y);    
    
    input_x = 8'b00000000;
    input_y = 8'b00000011;
    operation = 3'b100;
    #100
    $display("Test 18:  X = %b ,Y = %b ,2^Y = %b, Expected = %b",input_x,input_y,out,2**input_y);    
    
    input_x = 8'b00000000;
    input_y = 8'b00000100;
    operation = 3'b100;
    #100
    $display("Test 19:  X = %b ,Y = %b ,2^Y = %b, Expected = %b",input_x,input_y,out,2**input_y);

    input_x = 8'b00000000;
    input_y = 8'b00000101;
    operation = 3'b100;
    #100
    $display("Test 20:  X = %b ,Y = %b ,2^Y = %b, Expected = %b",input_x,input_y,out,2**input_y);
    
  end
endmodule