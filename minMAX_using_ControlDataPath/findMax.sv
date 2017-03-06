`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////////////////////////
//  findMax.sv - Top level findMax module to calculate minimum and maximum value 
//  Harsh Momaya
//  ECE 571- SystemVerilog  |   Prof. Roy Kravitz
//  Portland State University
//  01/30/2017
//
//  The package consists of 3 parameter declaration which are as follows:
//  SIZE: This defines the bus size of the input data and output data.
//        It is defaulted to 8.
//  TPERIOD: This is the signle clock cycle time period which is used for testbench.
//           It is set to 10 unit time as default
//  minMAX: This parameter is used to toggle betweeen calculation of min and max.
//          1-> it will calculate max, 0-> it will calculate min
//
//  I/O description:
//      clk   : clock to the design.
//      reset : Active LOW reset input to clear the system outputs and internal signals
//      start : 1-bit input to initiate the calcuation process.
//      inputA: This is port from where data is inserted into the design. It is kept parameterized.
//      Mvalue: This is output port from where min/ max value is obtained.
//      done  : This 1-bit output signal denotes end of operation. It goes HIGH for 1 cycle when 
//              start signal is deasserted. 
//
/////////////////////////////////////////////////////////////////////////////////////////////////////

package hw2;
    parameter SIZE = 8;
    parameter TPERIOD = 10;
    parameter minMAX = 0;       // 1- max, 0-min
      
endpackage

module findMax(clk, reset, start,inputA, Mvalue, done);
    
    // importing the package
    import hw2::*;
    
    input logic clk, reset, start;
    input logic [(SIZE-1):0] inputA;
    output logic [(SIZE-1):0] Mvalue;
    output logic done;
    
    //internal signals
    logic loadA, endop;
    
    //datapath instance
    datapath dp ( .clk(clk), 
                  .reset(reset), 
                  .loadA(loadA), 
                  .inputA(inputA), 
                  .endop(endop), 
                  .Mvalue(Mvalue)
                 );
    
    //control path instance             
    controlpath cp ( .clk(clk), 
                     .reset(reset), 
                     .start(start), 
                     .loadA(loadA),
                     .endop(endop), 
                     .done(done)
                    ); 
endmodule
