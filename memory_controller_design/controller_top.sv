`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
//  controller_top.sv - Design top module
//  Harsh Momaya    ||  ECE 571     || Portland State University
//  Date: 02/11/2017
// 
//  This module instantiates 2 memory controller which are linked with two of their
//  respective memories of varied memory size and PAGE size
//
//  All the I/O are common to both controllers so both will be provided with same data. 
//  The memory controller is designed in a way that it will ignore memory location
//  not belonging to its PAGE.
//  
//  Both controllers will never drive the AddrData bus simulataneously
//////////////////////////////////////////////////////////////////////////////////

import hw3::*;

module controller_top(
    inout [15:0] AddrData,
    input AddrValid,
    input rw,
    input clk,
    input resetH
    );
    
    memController #(4'h2
    ) mem1
    (
        .AddrData(AddrData),
        .clk(clk),
        .resetH(resetH),
        .AddrValid(AddrValid),
        .rw(rw)
        );
        
        
     memController #(4'h8, 4096
            ) mem2
            (
                .AddrData(AddrData),
                .clk(clk),
                .resetH(resetH),
                .AddrValid(AddrValid),
                .rw(rw)
                );
                   
endmodule
