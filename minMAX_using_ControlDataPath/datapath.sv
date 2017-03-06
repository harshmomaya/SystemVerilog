`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////
//  datapath.sv - Data path logic 
//  Harsh Momaya
//  ECE 571- SystemVerilog  |   Prof. Roy Kravitz
//  Portland State University
//  01/30/2017
//
//  I/O description:
//      clk   : Clock signal to the datapath logic.
//      reset : Reset clears the temoprary register and output register of the datapath.
//      loadA : Input from the control path to initiate computation
//      inputA: Parameterized input data port
//      endop :  
/////////////////////////////////////////////////////////////////////////////////////////


module datapath(clk, reset, loadA, inputA, endop, Mvalue);

    // Importing package...
    import hw2::*;
    
    input logic clk, reset, loadA, endop;
    input logic [(SIZE-1):0] inputA;
    output logic [(SIZE-1):0] Mvalue;
    
    //Temporary register
    logic [(SIZE-1):0] tempReg;
   
        
    always_ff @(posedge clk)
        begin
            if(!reset) 
                begin
                    Mvalue <= minMAX ? {SIZE{1'b0}}: {SIZE{1'b1}};
                    tempReg <= minMAX ? {SIZE{1'b0}}: {SIZE{1'b1}};
                end    
            else if(loadA) 
                begin
                    tempReg <= inputA;
                    Mvalue <= minMAX ? ((Mvalue > tempReg) ? Mvalue : tempReg) : ((Mvalue < tempReg) ? Mvalue : tempReg);
                end
            // End of operation    
            else if(endop) 
                begin
                    Mvalue <= Mvalue;
                    tempReg <= minMAX ? {SIZE{1'b0}}: {SIZE{1'b1}};
                end
            // Invalid 
            else 
                begin
                    Mvalue <= minMAX ? {SIZE{1'b0}}: {SIZE{1'b1}};
                    tempReg <= minMAX ? {SIZE{1'b0}}: {SIZE{1'b1}};
                end                      
        end
    
endmodule
