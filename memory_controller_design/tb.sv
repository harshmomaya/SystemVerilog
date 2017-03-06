`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//  tb.sv - test bench file for the design
//  Harsh Momaya    ||  ECE 571     || Portland State University
//  Date: 02/11/2017
// 
// This test bench has covered 8 important test cases.
//
//////////////////////////////////////////////////////////////////////////////////

import hw3::*;

module tb();
    
    tri [15:0] AddrData; 
    logic clk = 0, 
          resetH = 1, 
          AddrValid = 0, 
          rw = 0;
     
    logic [15:0] data = 'b0;
    
    //internal signals
    state_t stateTB1, stateTB2;
    logic [15:0] addr1, addr2;
    logic   [DATAWIDTH-1:0] DataMem1, DataMem2;
    logic ReadEnable1, WriteEnable1, ReadEnable2, WriteEnable2;
    logic [($clog2(DATABURST)):0] count1, count2;
    

    // Top module instance
    controller_top dut (
        .AddrData(AddrData),
        .clk(clk),
        .resetH(resetH),
        .AddrValid(AddrValid),
        .rw(rw)
    );

 
    // internal signal assignment
    assign stateTB1 = dut.mem1.state;
    assign addr1 = dut.mem1.addr;
    assign DataMem1 = dut.mem1.DataMem;
    assign ReadEnable1 = dut.mem1.ReadEnable;
    assign WriteEnable1 = dut.mem1.WriteEnable;
    assign count1 = dut.mem1.count;
    
    assign stateTB2 = dut.mem2.state;
    assign addr2 = dut.mem2.addr;
    assign DataMem2 = dut.mem2.DataMem;
    assign ReadEnable2 = dut.mem2.ReadEnable;
    assign WriteEnable2 = dut.mem2.WriteEnable;
    assign count2 = dut.mem2.count;    
    
    // Driving AddrData bus
     assign AddrData = data;      
     
    // Clock    
    always
        #(PERIOD/2) clk = ~clk;
    
            
    initial begin
        
        ///////////////////////////////////////////////
        // Case 1: Normal functionality
        //         Write followed by read
        //////////////////////////////////////////////
        // Write
        data = 'bz;
        repeat (2) @(posedge clk) resetH = 1;
        @(posedge clk) resetH = 0;
        @(posedge clk) data = 16'h200A;     // Address      
        @(negedge clk)AddrValid = 1'b1;
 
        @(posedge clk) begin
            AddrValid = 1'b0;
            data = 16'd55;
        end    
        
        @(posedge clk) data = 16'd255;
        @(posedge clk) data = 16'd128;
        @(posedge clk) data = 16'd17;
        
        repeat(3) @(posedge clk) data = 'bz;        
        
        //Read
        @(posedge clk) data = 16'h200A;
        @(negedge clk) begin  
              AddrValid = 1'b1;
              rw = 1'b1;
        end
        
        @(posedge clk) begin
            data = 'bz;
            AddrValid = 1'b0;
            rw = 0;   
        end

        // Wait for some clock cycles
        repeat(6) @(posedge clk);
        
        //////////////////////////////////////////
        // Case 2: PAGE fault
        /////////////////////////////////////////
        
        // Read
        @(posedge clk) begin
            data = 16'h000A;
            rw = 1'b0;
            end
            
        @(negedge clk) begin
            rw = 1'b1;
            AddrValid = 1'b1;
        end
        
        @(posedge clk) begin
            data = 'bz;
            AddrValid = 1'b0;
            rw = 1'b0;
        end    
        
        repeat(4) @(posedge clk);
        
        //////////////////////////////////////////
        // Case 3: Immediate Write and Read
        //////////////////////////////////////////
        // Write
        @(posedge clk) begin
            data = 16'h20F0;
            rw = 1'b0;
            end
            
        @(negedge clk) begin
            AddrValid = 1'b1;
        end
        
        @(posedge clk) begin
            data = 16'hFFFF;
            AddrValid = 1'b0;
        end
        
        @(posedge clk) data = 16'hF0F0;
        @(posedge clk) data = 16'h0F0F;
        @(posedge clk) data = 16'hFF00;
        
        // Read
        @(posedge clk) begin
            data = 16'h20F0;
        end
            
        @(negedge clk) begin    
            AddrValid = 1'b1;
            rw = 1'b1;
        end
        @(posedge clk) begin
            data = 'bz;
            AddrValid = 1'b0;
            rw = 0;
        end
        repeat(4) @(posedge clk);
    
        ////////////////////////////////////////
        // Case 4: Illegal AddrValid going HIGH
        //         in Read/ Write state
        ///////////////////////////////////////
        @(posedge clk) begin
        data = 16'h20F0;
        end
        
        #(PERIOD/10) begin
            AddrValid = 1'b1;
            rw = 1'b1;
            end
            
        @(posedge clk) begin
            data = 'bz;
            AddrValid = 1'b0;
            rw = 1'b0;
        end     
        
        repeat(2) @(posedge clk);
        @(negedge clk) begin
            AddrValid = 1'b1;
        end
        
        @(posedge clk) AddrValid = 1'b0;
        repeat(4) @(posedge clk) data = 'bz;
        
        
        /////////////////////////////////////////
        // Case 5: Reset during a transaction 
        ////////////////////////////////////////    
        @(posedge clk) data = 'h20F0;
        @(negedge clk) begin
            AddrValid = 1'b1;
            rw = 1'b1;
            end
            
        @(posedge clk) begin
            data = 'bz;
            rw = 1'b0;
            AddrValid = 1'b0;
        end
        
        repeat(2)@(posedge clk);
        
        @(posedge clk) resetH = 1'b1;
        @(posedge clk) resetH = 1'b0;
        
        @(posedge clk) data = 'bz;
        
        /////////////////////////////////////////
        // Case 6: 2nd memory instance
        /////////////////////////////////////////
        //Write
        @(posedge clk) data = 'h80F0;
        @(negedge clk) begin
            AddrValid = 1'b1;
            rw = 1'b0;
        end
        
        @(posedge clk) begin
            AddrValid = 1'b0;
            data = 'h0101;
        end
            
        @(posedge clk) data = 'h1010;
        @(posedge clk) data = 'h0110;
        @(posedge clk) data = 'h1001;
        
        @(posedge clk) data = 'bz;
        
        //Read              
        @(posedge clk) data = 'h80F0;
        #(PERIOD/5) begin
            AddrValid = 1'b1;
            rw = 1'b1;
        end
        
        @(posedge clk) begin
            AddrValid = 1'b0;
            data = 'bz;
            rw = 1'b0;
        end
        
        repeat(4) @(posedge clk);
        
        ////////////////////////////////////////////////////
        // Reading from 1st memory after operating 
        // on 2nd controller  on the same memory address
        /////////////////////////////////////////////////// 
        
        @(posedge clk) data = 'h20F0;
        @(negedge clk) begin
            AddrValid = 1'b1;
            rw = 1'b1;
            end
            
        @(posedge clk) begin
            AddrValid = 1'b0;
            data = 'bz;
            rw = 1'b0;
            end    
        
        repeat(5) @(posedge clk);    
        
        
endmodule
