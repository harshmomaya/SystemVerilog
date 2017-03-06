`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// tb_findMax.sv - Testbench to test the design  
//  Harsh Momaya
//  ECE 571- SystemVerilog  |   Prof. Roy Kravitz
//  Portland State University
//  01/30/2017
//
//  Testbench signal names are same as design I/O signals.
//  Internal signals were also evaluated using the waveform.
//  $monitor and $display are used to generate transcript
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_findMax();

    import hw2::*;
    
    logic clk, reset, start;
    logic [(SIZE-1):0] inputA;
    logic [(SIZE-1):0] Mvalue;
    logic done;
    
    // internal signals of the design
    logic loadA, endop;
    logic [(SIZE-1):0] tempReg;
    bit state;
    
    findMax dut(.clk(clk), 
                .reset(reset), 
                .start(start),
                .inputA(inputA), 
                .Mvalue(Mvalue), 
                .done(done)
               );
               
     assign loadA = dut.cp.loadA; 
     assign endop = dut.cp.endop;
     assign state = dut.cp.state;
     assign tempReg = dut.dp.tempReg;
     
     // Clock          
     always 
        #(TPERIOD/2) clk = ~clk;
     
     initial 
        $display("\t\t\t\t Time \t InputA \t Start \t Mvalue \t Done \n");
        
     initial 
        $monitor("%t \t %d \t\t %d \t\t %d \t\t %d \n", $time, inputA, start,Mvalue,done);
                     
     
     initial
        begin
            // initializing...
            clk = 1'b0;
            reset = 1'b0;
            start = 1'b0;
            inputA = minMAX ? {SIZE{1'b0}}:{SIZE{1'b1}};
            
            // reset pulled high
            #(2*TPERIOD);
            reset = 1'b1;
            
            ////////////////////////////////////////////////////////////////////////////////
            // General case
            ////////////////////////////////////////////////////////////////////////////////
            #TPERIOD;
            @(posedge clk) start = 1'b1;
            
            repeat(5) @(posedge clk) inputA = $urandom_range(0,({SIZE{1'b1}}));
            @(posedge clk) start = 1'b0;
            inputA = 0;
            
            ////////////////////////////////////////////////////////////////////////////////
            // inputA value greater than the Mvalue before start signal going HIGH.
            // As start signal is not HIGH, it should not register the value on inputA bus.
            ////////////////////////////////////////////////////////////////////////////////
            #TPERIOD;
            @(posedge clk) inputA = $urandom_range(0,({SIZE{1'b1}}));
            repeat (10) @(posedge clk) begin
                start = 1'b1;
                inputA = $urandom_range(0,({SIZE{1'b1}}));  
            end
            @(posedge clk) start = 1'b0;
            
            ////////////////////////////////////////////////////////////////////////////////
            // Reset is activated along with valid data and start signal HIGH.
            // Reset has higher priority.
            /////////////////////////////////////////////////////////////////////////////////
            #TPERIOD;
            repeat(5) @(posedge clk) begin
                reset = 1'b0;
                start = 1'b1;
                inputA = $urandom_range(0,({SIZE{1'b1}}));
            end
            @(posedge clk) begin
                reset = 1'b1;
                inputA = $urandom_range(0,({SIZE{1'b1}}));
                end
            @(posedge clk) start = 1'b0;
             
            /////////////////////////////////////////////////////////////////////////////////
            // start signal active for very short period of time.
            /////////////////////////////////////////////////////////////////////////////////
            #TPERIOD
            inputA = $urandom_range(0,({SIZE{1'b1}}));
            start = 1'b1;
            #1;
            start = 1'b0;
            
            ///////////////////////////////////////////////////////////////////////////////////
            // Start signal active for a long period of time
            ///////////////////////////////////////////////////////////////////////////////////
            #TPERIOD;
            repeat (32) @(posedge clk) begin
                start = 1'b1;
                inputA = $urandom_range(0,({SIZE{1'b1}}));  
            end
            @(posedge clk) begin
                start = 1'b0;
                inputA = 0;
            end                                                
        end
        
endmodule
