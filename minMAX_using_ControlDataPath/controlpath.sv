`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////////////////////////////////
//  controlpath.sv - This logic controls the operation of datapath based on the input signals. 
//  Harsh Momaya
//  ECE 571- SystemVerilog  |   Prof. Roy Kravitz
//  Portland State University
//  01/30/2017
//
//  I/O description:
//      clk  : Clock to the design
//      reset: Resets the system
//      start: Starts the FSM and initiates data input and computation process.
//      loadA: This is outputted by the system to datapath logic to start accepting the data
//              and computing minimum/ maximum value.
//      endop: Denotes the end of operation when start signal goes low. This signal is provided
//              to datapath logic to stop accepting inputs and output the max value until next time
//              when start goes HIGH. 
//      done : Output signal of the top level design indicating end of operation which can be provided
//              to other circuitary.
//
////////////////////////////////////////////////////////////////////////////////////////////////////////


module controlpath (clk, reset, start, loadA, endop, done);

    input logic clk, reset, start;
    output logic loadA, endop, done;
    
    // enumerated list
    enum bit {init, compare} state, nextState;
    
    // Mealy machine
    // State transition
    always_ff @(posedge clk)
        begin
            if(!reset) state <= init;
            else state <= nextState;
        end
    
    // Next state logic and output logic combined   
    always_comb
        begin
            case(state)
                init: begin  
                        if (!start) begin 
                            nextState = init;
                            loadA = 1'b0;
                            endop = 1'b0;
                        end
                        else begin
                            nextState = compare;
                            loadA = 1'b1;
                            endop = 1'b0;
                        end
                      end
                compare: begin
                            if(!start) begin
                                nextState = init;
                                endop = 1'b1;
                                loadA = 1'b0;
                            end
                            else begin
                                nextState = compare;
                                endop = 1'b0;
                                loadA = 1'b1;
                            end
                          end
                endcase
           end                      
                                                
    assign done = endop;
    
endmodule
