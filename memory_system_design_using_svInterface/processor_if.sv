//////////////////////////////////////////////////////////////////////////////////
// processor_if.sv : Interface module which conencts cpu to main bus.
// ECE 571  || Portland State University
// Author : Harsh Momaya
// Date   : 03-March-2017
// Description: 
//      The following interface connects the module CPU to the main_bus interface.
//      This interface unit has 2 tasks: Proc_rdReq and Proc_wrReq which are 
//      responsible to perform read and write operation respectively.
//      Both tasks are implemented in terms of @(posedge clk) events.
//
//////////////////////////////////////////////////////////////////////////////////

import mcDefs::*;

interface processor_if
(
	main_bus_if.master M 			// interface to processor is a master
);
	
	modport SndRcv
	  (
		import Proc_rdReq,
		import Proc_wrReq
	  );
	
	logic [15:0] address = '0;
	logic [15:0] WriteData = '0;
	logic AddrFlag = '0;
	logic DataFlag = '0;

	assign M.AddrData = AddrFlag ? address:(DataFlag? WriteData: 'z);

	///////////////////////////////////////////////////////////////////////////////
	// TASK-> Proc_rdReq
	// performs a 4 word memory read to ?page? starting at ?baseaddr?
	// the data from memory is returned in the 64-bit packed array
	// (four 16-bit words) ?data?
	///////////////////////////////////////////////////////////////////////////////
	
	logic [63:0] dtemp = '0;

	task Proc_rdReq
	
	(
		input bit [3:0] page,
		input bit [11:0] baseaddr,
		output logic [DBUFWIDTH-1:0] data
 	);
		
		
        $display("Processor_if: Read task initiating");
		
		DataFlag = 1'b0;

        @(posedge M.clk) begin
            address      = {page, baseaddr};
            AddrFlag     = 1'b1;
            M.AddrValid  = 1'b1;
            M.rw         = 1'b1;
            $display("Processor_if: Read: Addr registered");
        end

        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            AddrFlag 	= 1'b0;
            M.rw		= 1'b0;
        end
            
        @(negedge M.clk) begin
            data[15:0]	= M.AddrData;
            $display("Processor_if: Read: Data 1 registered");
        end
        
            
        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            AddrFlag 	= 1'b0;
            M.rw		= 1'b0;
        end    
           
        @(negedge M.clk) begin    
            data[31:16]	= M.AddrData;
            $display("Processor_if: Read: Data 2 registered");
        end
            
        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            M.rw		= 1'b0;
            AddrFlag 	= 1'b0;
        end    
           
        @(negedge M.clk) begin    
            data[47:32]	= M.AddrData;
            $display("Processor_if: Read: Data 3 registered");
        end
        
        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            M.rw		= 1'b0;
            AddrFlag 	= 1'b0;
        end
        
        @(negedge M.clk) begin    
            data[63:48]	= M.AddrData;
            $display("Processor_if: Read: Data 4 registered");
        end


        $display("Processor_if: Read-> Main Bus");
        
	endtask: Proc_rdReq
	
	//////////////////////////////////////////////////////////////////////////////////////
	// TASK-> Proc_wrReq
	// performs a 4 word memory write to ?page? starting at ?baseaddr?
	// the data to be written to memory is passed to the task in the
	// 64-bit (four 16-bit words) packed array ?data?
	/////////////////////////////////////////////////////////////////////////////////////

	task Proc_wrReq
	
	(
		input bit [3:0] page,
		input bit [11:0] baseaddr,
		input logic [DBUFWIDTH-1 : 0] data
	);

        $display("Processor_if: Write task initiating");
        
        @(posedge M.clk) begin  
            address     = {page, baseaddr};
            AddrFlag    = 1'b1;
            DataFlag    = 1'b0;
            M.AddrValid = 1'b1;
            M.rw 	    = 1'b0;
        $display("Processor_if: Write: Addr registered");
        end

        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            M.rw		= 1'b0;
            WriteData	= data[15:0];
            AddrFlag	= 1'b0;
            DataFlag	= 1'b1;
            $display("Processor_if: Write: Data 1 written");
        end
    
        @(posedge M.clk) begin
            address = 'z;
            M.AddrValid 	= 1'b0;
            M.rw		= 1'b0;
            WriteData	= data[31:16];
            AddrFlag	= 1'b0;
            DataFlag	= 1'b1;
            $display("Processor_if: Write: Data 2 written");
        end
            
        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            M.rw		= 1'b0;
            WriteData	= data[47:32];
            AddrFlag	= 1'b0;
            DataFlag	= 1'b1;
            $display("Processor_if: Write: Data 3 written");
        end
        @(posedge M.clk) begin
            address     = 'z;
            M.AddrValid = 1'b0;
            M.rw		= 1'b0;
            WriteData	= data[63:48];
            AddrFlag	= 1'b0;
            DataFlag	= 1'b1;
            $display("Processor_if: Write: Data 4 written");
        end

   
    $display("Processor_if: Write-> Main Bus");
    
	endtask: Proc_wrReq
	  	

endinterface: processor_if