////////////////////////////////////////////////////////////////////////////////////////////////
//  Testbench.sv: tests the design with different test cases
//  ECE 571  ||  Portland State University
//  Date: 03-March-2017
//  Created by Harsh Momaya
//  Description:
//      Corner cases, constrained random testing and complete memory testing was performed. 
//      $display and waveforms were used for debugging.
//      top_module is instantiated and signals are driven from this module.
//      Test scenarios are described below and breifly in design report.
///////////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/10ps

import mcDefs::*;

`ifndef FULL_TEST
`define FULL_TEST 0
`endif

module Testbench;

	logic clk = 1, reset = 0;
	instr_t instr_tb;
	
	logic [63:0] datain ='0, dataout ='0;

	top_module top(clk, reset, instr_tb, datain, dataout);

	parameter logic RD = 1;
	parameter logic WR = 0;
    logic match = 0;
    logic [11:0] AddrTemp;
    assign AddrTemp = top.memIF.addr;
//    int j = 0;
    logic [15:0] wr_arr [2**16];
    logic [15:0] rd_arr [2**16];
    
    integer file;
    
	always
	  #5 clk = ~clk;

	initial begin
	reset = 1;
	instr_tb.InstrType = 1'bz;
	repeat(2) @(posedge clk);
	
    repeat(1)@(posedge clk);
    reset = 0;

         /////////////////////////////////////////////////
         // Reset active during Read and Write operation
         ////////////////////////////////////////////////     
             @(posedge clk) begin 
                 instr_tb.InstrType =  WR;
                 instr_tb.Addr.page =  MEMPAGE1;
                 instr_tb.Addr.loc  =  12'h020;
                 datain = 64'h1F2F3F4F5F6F7F8F;
            end
            
            repeat(2) @(posedge clk);
            @(posedge clk) reset = 1'b1;
            @(posedge clk) reset = 1'b0;
            repeat(1)@(posedge clk);
            
             @(posedge clk) begin 
                   instr_tb.InstrType =  WR;
                   instr_tb.Addr.page =  MEMPAGE1;
                   instr_tb.Addr.loc  =  12'hABC;
                   datain = 64'h1F2F3F4F5F6F7F8F;
              end
            
            repeat(5) @(posedge clk);
                    
            @(posedge clk) begin
                instr_tb.InstrType = RD;
                instr_tb.Addr.page = MEMPAGE1;
                instr_tb.Addr.loc = 12'hABC;
            end
            
            repeat(2) @(posedge clk);
            @(posedge clk) reset = 1'b1;
            @(posedge clk) reset = 1'b0;
            @(posedge clk);
            
        /////////////////////////////////////////////////////////
        // Writing to 2 pages with same base addresses and then 
        // reading from those locations.
        /////////////////////////////////////////////////////////
         
             @(posedge clk) begin 
                 instr_tb.InstrType =  WR;
                 instr_tb.Addr.page =  MEMPAGE1;
                 instr_tb.Addr.loc  =  12'h100;
                 datain = 64'h1020304050607080;
            end
            
            repeat(5) @(posedge clk);
                
            @(posedge clk) begin
                instr_tb.InstrType = WR;
                instr_tb.Addr.page = MEMPAGE2;
                instr_tb.Addr.loc = 12'h100;
                datain = 64'h90A0B0C0D0E0F000;
            end
            
            repeat(5) @(posedge clk);
                    
            @(posedge clk) begin
                instr_tb.InstrType = RD;
                instr_tb.Addr.page = MEMPAGE1;
                instr_tb.Addr.loc = 12'h100;
            end
            
            repeat(5) @(posedge clk);
                    
            @(posedge clk) begin
                instr_tb.InstrType = RD;
                instr_tb.Addr.page = MEMPAGE2;
                instr_tb.Addr.loc = 12'h100;
            end
                
            /////////////////////////////////////////////////////////
            // Writing to 2 pages with different base addresses 
            // and then reading from those locations.
            /////////////////////////////////////////////////////////
            repeat(10) @(posedge clk);
            
            @(posedge clk) begin 
                instr_tb.InstrType =  WR;
                instr_tb.Addr.page =  MEMPAGE1;
                instr_tb.Addr.loc  =  12'hABC;
                datain = 64'h1F2F3F4F5F6F7F8F;
           end
           
           repeat(5) @(posedge clk);
               
           @(posedge clk) begin
               instr_tb.InstrType = WR;
               instr_tb.Addr.page = MEMPAGE2;
               instr_tb.Addr.loc = 12'hDEF;
               datain = 64'h9FAFBFCFDFEFFF0F;
           end
           
           repeat(5) @(posedge clk);
                   
           @(posedge clk) begin
               instr_tb.InstrType = RD;
               instr_tb.Addr.page = MEMPAGE1;
               instr_tb.Addr.loc = 12'hABC;
           end
           
           repeat(5) @(posedge clk);
                   
           @(posedge clk) begin
               instr_tb.InstrType = RD;
               instr_tb.Addr.page = MEMPAGE2;
               instr_tb.Addr.loc = 12'hDEF;
           end
        
           repeat(5) @(posedge clk);
       
       /////////////////////////////////////////////////////////////
       // Testing a complete memory page.
       ////////////////////////////////////////////////////////////
    if(`FULL_TEST) begin
        for(int i=0; i<4096; i=i+4) begin
            @(posedge clk) begin
                   instr_tb.InstrType = WR;
                   instr_tb.Addr.page = MEMPAGE2;
                   instr_tb.Addr.loc = 12'(i);
                   datain = 64'({32'hFFFFFFFF, 32'(i/4)});
               end
			   
               wr_arr[i]   = datain[15:0];
               wr_arr[i+1] = datain[31:16];
               wr_arr[i+2] = datain[47:32];
               wr_arr[i+3] = datain[63:48];
               
               repeat(5) @(posedge clk);
         end

	   for(int i=0;i <4096;i= i+4) begin
	      @(posedge clk) begin
              instr_tb.InstrType = RD;
              instr_tb.Addr.page = MEMPAGE2;
              instr_tb.Addr.loc = 12'(i);
          end
          repeat(5) @(posedge clk);
          
          @(posedge clk) begin
              rd_arr[i] = dataout[15:0];
              rd_arr[i+1] = dataout[31:16];
              rd_arr[i+2] = dataout[47:32];
              rd_arr[i+3] = dataout[63:48];
          end 
        end       

        file = $fopen("Memory.txt", "w");
		$fwrite(file,"PAGE = %4b", MEMPAGE2);
        $fwrite(file, "\nBase Addr\tData written\tData read\tMatch?");
	    
	    for(int i=0;i<4096;i++) begin
	       if (wr_arr[i] == rd_arr[i]) match = 1;
	       else match = 0;
	       
	       $fwrite(file,"\n%h \t %h \t \t %h \t\t %b",i,wr_arr[i],rd_arr[i],match);
	       end
	       
	    $fclose(file); 
	   
	   end
	   
	   ////////////////////////////////////////////////////////////////////
	   // Illegal Page
	   ////////////////////////////////////////////////////////////////////
	   
	   @(posedge clk) begin
         instr_tb.InstrType = RD;
         instr_tb.Addr.page = 4'hB;
         instr_tb.Addr.loc = 12'h607;
       end
       
       repeat(5) @(posedge clk);
	   /////////////////////////////////////////////////////////////////// 
	   //  Randomization
	   ///////////////////////////////////////////////////////////////////
	   
	   // Address randomization
	   for(int i=0;i<5;i++) begin
	       @(posedge clk) begin
             instr_tb.InstrType = WR;
             instr_tb.Addr.page = MEMPAGE2;
             instr_tb.Addr.loc = $urandom_range(0,4095);
             datain = 64'hFFFF0000EEEE1111;
           end
          repeat(5) @(posedge clk);
        end
        
       // page randomization
       for(int i=0;i<5;i++) begin
          @(posedge clk) begin
            instr_tb.InstrType = RD;
            instr_tb.Addr.page = $urandom_range(0,15);
            instr_tb.Addr.loc =  12'h555;
          end
         repeat(5) @(posedge clk);
       end
       
       //Data randomization     
	   for(int i=0;i<5;i++) begin
         @(posedge clk) begin
           instr_tb.InstrType = WR;
           instr_tb.Addr.page = MEMPAGE2;
           instr_tb.Addr.loc =  12'(100*i);
           datain = $urandom_range(0,65536);
         end
       
        repeat(5) @(posedge clk);
       
         @(posedge clk) begin
          instr_tb.InstrType = RD;
          instr_tb.Addr.page = MEMPAGE2;
          instr_tb.Addr.loc =  12'(100*i);
        end
       
        repeat(5) @(posedge clk);       
       
       end            
  
	end    
	   
endmodule
