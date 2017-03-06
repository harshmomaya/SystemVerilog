`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//  memController.sv - Memory controller module
//  Harsh Momaya    ||  ECE 571     || Portland State University
//  Date: 02/11/2017
//
// I/O description:
//  AddrData    :  Bidirectional address/ data bus of size 16-bits
//  clk         :  Common clock to both memory and memory controller. All operations are synced with this signal
//  resetH      :  Active high Reset
//  AddrValid   :  Read or Write operation will initiate when this 1-bit signal is asserted
//  rw          :   rw = 1 -> Read operation, rw = 0 -> Write operation
//
//  Memory unit does not interact with CPU directly.
//  Hence, memory module is instantiated in this module.
//  PAGE logic enables memory controller to access only certain part of a memory location.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

package hw3;
    parameter DATAWIDTH =   16,
              DATABURST =   4,
              PERIOD    =    10;   
              
        // 1 hot encoding
      typedef enum logic [2:0] { Init      = 3'b001, 
                                 Read      = 3'b010,
                                 Write     = 3'b100 
                                } state_t;

endpackage


module memController #(
    parameter logic [3:0] PAGE = 4'h2,
    parameter logic [12:0] MEMDEPTH  =  256
)
(
    inout tri [15:0] AddrData,
    input clk,
    input resetH,
    input AddrValid,
    input rw
    );
    
    import hw3::*;
    
    localparam [15:0] ADDRWIDTH = $clog2(MEMDEPTH);
        
    // State variables
    state_t                         nextState, state;           // state variables
    logic [(ADDRWIDTH- 1):0]        addr;                       // Address to the memory
    tri   [DATAWIDTH-1:0]           DataMem;                    // Data from the memory
    
    // This variable is use to store data obtained from AddrData during Write state 
    logic [DATAWIDTH-1:0]           data;                                  
    logic                           ReadEnable, WriteEnable;   
    logic [($clog2(DATABURST)):0]   count;                      // Based on data burst
    
    // Memory module instance
    mem #(MEMDEPTH)
    memory (
        .clk(clk),
        .rdEn(ReadEnable),    
        .wrEn(WriteEnable),    
        .Addr(addr),   
        .Data(DataMem)
    );
    
    
    ///////////////////////////////////////////////////////////////////////////
    //  State transition
    ///////////////////////////////////////////////////////////////////////////
    
    always_ff @(posedge clk)
        begin
            if (resetH == 1'b1) state <= Init;
            else  state <= nextState;    
        end
     
     /////////////////////////////////////////////////////////////////////////
     //  Next State    
     /////////////////////////////////////////////////////////////////////////
     
     always_comb
        begin
            unique case(state)
                Init: begin
                        if (AddrValid && AddrData[15:12] == PAGE) begin         // PAGE logic and AddrValid check
                            if (rw)  nextState = Read;
                            else     nextState = Write; 
                            end
                        else nextState = Init;
                      end
                      
                 Read: begin
                         if(count > 1) nextState = Read;
                         else nextState = Init;
                       end
                       
                 Write: begin
                            if(count > 1) nextState = Write;
                            else nextState = Init;      
                        end
            endcase                    
        end 
     
     /////////////////////////////////////////////////////////////////////////
    // Output logic 
    //////////////////////////////////////////////////////////////////////////
    
    always_comb
            begin
                unique case(state)                      // Only 3 states possible
                    Init: begin
                            data = 'b0;
                            ReadEnable = 1'b0;
                            WriteEnable = 1'b0;
                          end
                          
                     Read: begin
                             data = 'b0;
                             WriteEnable = 1'b0;
                             if(count > 0) ReadEnable = 1'b1;
                             else ReadEnable = 1'b0;
                           end
                           
                     Write: begin
                                ReadEnable = 1'b0;
                                if(count > 0) begin
                                    WriteEnable = 1'b1;
                                    data = AddrData;               // Lock the data to be written
                                end
                                else begin
                                    data = 'b0;
                                    WriteEnable = 1'b0;
                                end        
                            end
                endcase                    
            end     
    
    /////////////////////////////////////////////////////////////////////////////////
    //  Address logic
    //  AddressValid is aynschronous hence its in the sensitivity list.
    /////////////////////////////////////////////////////////////////////////////////
           
    always_ff @(posedge clk, posedge AddrValid)
        begin
            if (resetH) addr <= 'b0;
            else if (state == Init && AddrValid) addr <= AddrData[(ADDRWIDTH-1):0];     // Lock the Address
            else if ((ReadEnable || WriteEnable) && ~AddrValid) addr <= addr + 1'b1;            
            else addr <= addr;
        end                                    
     
     ////////////////////////////////////////////////////////////////////////////////        
     // Counter logic. This counter controls the next state and output logic of FSM 
     // AddressValid is aynschronous hence its in the sensitivity list. 
     /////////////////////////////////////////////////////////////////////////////// 
             
     always_ff @(posedge clk, posedge AddrValid)
        begin
            if(resetH) count <= 0;
            else if (AddrValid && (state == Init)) count <= DATABURST;
            else if ((ReadEnable || WriteEnable) && ~AddrValid) count <= count - 1'b1;
            else count <= count;
        end
     
     ////////////////////////////////////////////////////////////////////////////////
     // Tri state logic
     ////////////////////////////////////////////////////////////////////////////////
        
     // only for read
     assign AddrData = (state == Read)? DataMem:({DATAWIDTH{1'bz}});
     
     // for write
     assign DataMem  = (state == Write) ? data : 'bz;    

endmodule
