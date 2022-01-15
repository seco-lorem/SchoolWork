`timescale 1ns / 1ps

// Testbench module that runs the instructions on imem module of Pipelined MIPS implementation
module testbench();
	initial begin
		$dumpfile("dump.vcd");
		$dumpvars(1);
	end
  
	logic clk, reset, PcSrcD, MemWriteD, MemtoRegD, ALUSrcD, BranchD, RegDstD, RegWriteD, ForwardAD, ForwardBD;
  logic [2:0]  alucontrol;
  logic [1:0]  ForwardAE, ForwardBE;
  logic [31:0] instrF, PC, PCF, instrD, ALUOutE, WriteDataE;
	
  top_mips dut( clk, reset, instrF, PC, PCF, PcSrcD, MemWriteD, MemtoRegD, ALUSrcD, BranchD, RegDstD, RegWriteD, alucontrol, instrD, ALUOutE, WriteDataE, ForwardAE, ForwardBE, ForwardAD, ForwardBD);
	
	initial begin
		clk <= 0;
		reset <= 1;
		for(int i = 0; i < 100; i++)
		begin
			#100; clk <= ~clk;
			reset <= 0;
		end
	end
endmodule


// Pipelined MIPS Implementation according to given Template

// Define pipes that exist in the PipelinedDatapath. 
// The pipe between Writeback (W) and Fetch (F), as well as Fetch (F) and Decode (D) is given to you.
// Create the rest of the pipes where inputs follow the naming conventions in the book.


module PipeFtoD(input logic[31:0] instr, PcPlus4F,
                input logic EN, clear, clk, reset,
                output logic[31:0] instrD, PcPlus4D);

                always_ff @(posedge clk, posedge reset)
                  if(reset)
                        begin
                        instrD <= 0;
                        PcPlus4D <= 0;
                        end
                    else if(EN)
                        begin
                          if(clear) // Can clear only if the pipe is enabled, that is, if it is not stalling.
                            begin
                        	   instrD <= 0;
                        	   PcPlus4D <= 0;
                            end
                          else
                            begin
                        		instrD<=instr;
                        		PcPlus4D<=PcPlus4F;
                            end
                        end
                
endmodule

// Similarly, the pipe between Writeback (W) and Fetch (F) is given as follows.

module PipeWtoF(input logic[31:0] PC,
                input logic EN, clk, reset,		// ~StallF will be connected as this EN
                output logic[31:0] PCF);

                always_ff @(posedge clk, posedge reset)
                    if(reset)
                        PCF <= 0;
                    else if(EN)
                        PCF <= PC;
endmodule

module PipeDtoE(input logic[31:0] RD1, RD2, SignImmD,
                input logic[4:0] RsD, RtD, RdD,
                input logic RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD,
                input logic[2:0] ALUControlD,
                input logic clear, clk, reset,
                output logic[31:0] RsData, RtData, SignImmE,
                output logic[4:0] RsE, RtE, RdE, 
                output logic RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, RegDstE,
                output logic[2:0] ALUControlE);

        always_ff @(posedge clk, posedge reset)
          if(reset || clear)
                begin
                // Control signals
                RegWriteE <= 0;
                MemtoRegE <= 0;
                MemWriteE <= 0;
                ALUControlE <= 0;
                ALUSrcE <= 0;
                RegDstE <= 0;
                
                // Data
                RsData <= 0;
                RtData <= 0;
                RsE <= 0;
                RtE <= 0;
                RdE <= 0;
                SignImmE <= 0;
                end
            else
                begin
                // Control signals
                RegWriteE <= RegWriteD;
                MemtoRegE <= MemtoRegD;
                MemWriteE <= MemWriteD;
                ALUControlE <= ALUControlD;
                ALUSrcE <= ALUSrcD;
                RegDstE <= RegDstD;
                
                // Data
                RsData <= RD1;
                RtData <= RD2;
                RsE <= RsD;
                RtE <= RtD;
                RdE <= RdD;
                SignImmE <= SignImmD;
                end

endmodule

module PipeEtoM(input logic[31:0] ALUOutE, WriteDataE,
                input logic[4:0] WriteRegE,
                input logic RegWriteE, MemtoRegE, MemWriteE,
                input logic clk, reset,
                output logic[31:0] ALUOutM, WriteDataM,
                output logic[4:0] WriteRegM,
                output logic RegWriteM, MemtoRegM, MemWriteM);

        always_ff @(posedge clk, posedge reset)
          if(reset)
                begin
                // Control signals
                RegWriteM <= 0;
                MemtoRegM <= 0;
                MemWriteM <= 0;
                
                // Data
                ALUOutM <= 0;
                WriteDataM <= 0;
                WriteRegM <= 0;
                end
            else
                begin
                // Control signals
                RegWriteM <= RegWriteE;
                MemtoRegM <= MemtoRegE;
                MemWriteM <= MemWriteE;
                
                // Data
                ALUOutM <= ALUOutE;
                WriteDataM <= WriteDataE;
                WriteRegM <= WriteRegE;
                end

endmodule

module PipeMtoW(input logic[31:0] ALUOutM, ReadDataM,
                input logic[4:0] WriteRegM,
                input logic RegWriteM, MemtoRegM,
                input logic clk, reset,
                output logic[31:0] ALUOutW, ReadDataW,
                output logic[4:0] WriteRegW,
                output logic RegWriteW, MemtoRegW);

        always_ff @(posedge clk, posedge reset)
          if(reset)
                begin
                // Control signals
                RegWriteW <= 0;
                MemtoRegW <= 0;
                
                // Data
                ALUOutW <= 0;
                ReadDataW <= 0;
                WriteRegW <= 0;
                end
            else
                begin
                // Control signals
                RegWriteW <= RegWriteM;
                MemtoRegW <= MemtoRegM;
                
                // Data
                ALUOutW <= ALUOutM;
                ReadDataW <= ReadDataM;
                WriteRegW <= WriteRegM;
                end
endmodule



// *******************************************************************************
// End of the individual pipe definitions.
// ******************************************************************************

// *******************************************************************************
// Below is the definition of the datapath.
// The signature of the module is given. The datapath will include (not limited to) the following items:
//  (1) Adder that adds 4 to PC
//  (2) Shifter that shifts SignImmD to left by 2
//  (3) Sign extender and Register file
//  (4) PipeFtoD
//  (5) PipeDtoE and ALU
//  (5) Adder for PcBranchD
//  (6) PipeEtoM and Data Memory
//  (7) PipeMtoW
//  (8) Many muxes
//  (9) Hazard unit
//  ...?
// *******************************************************************************

module datapath (input  logic clk, reset,
                input  logic[2:0]  ALUControlD,
                input logic RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD, BranchD,
                 output logic [31:0] instrF,		
                 output logic [31:0] instrD, PC, PCF,
                output logic PcSrcD,                 
                output logic [31:0] ALUOutE, WriteDataE,
                output logic [1:0] ForwardAE, ForwardBE,
                 output logic ForwardAD, ForwardBD); // Add or remove input-outputs if necessary

	// ********************************************************************
	// Here, define the wires that are needed inside this pipelined datapath module
	// ********************************************************************
  
  	//* We have defined a few wires for you
    logic [31:0] PcSrcA, PcSrcB, PcBranchD, PcPlus4F;	
  	logic StallF;
  
	//* You should define others down below
  	logic[31:0] PcPlus4D, resultW, rd1, rd2, eqSrcA, eqSrcB, ALUOutM, SignImmd, SignImmdSL2, RsData, RtData, SignImmE, SrcAE, SrcBE, WriteDataM, ALUOutW, ReadDataW, ReadDataM;
  	logic[4:0] WriteRegW, RsE, RtE, RdE, WriteRegE, WriteRegM;
  	logic RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, RegDstE, RegWriteM, MemtoRegM, MemWriteM, RegWriteW, MemtoRegW;
  	logic StallD, FlushE;
    logic[2:0] ALUControlE;
	// ********************************************************************
	// Instantiate the required modules below in the order of the datapath flow.
	// ********************************************************************

  
  	//* We have provided you with some part of the datapath
    
  	// Instantiate PipeWtoF
  	PipeWtoF pipe1(PC,
                ~StallF, clk, reset,
                PCF);
  
  	// Do some operations
    assign PcPlus4F = PCF + 4;
    assign PcSrcB = PcBranchD;
	assign PcSrcA = PcPlus4F;
  	mux2 #(32) pc_mux(PcSrcA, PcSrcB, PcSrcD, PC);

    imem im1(PCF[7:2], instrF);
    
  	// Instantiate PipeFtoD
  	PipeFtoD pipe2( instrF, PcPlus4F,
               	~StallD, PcSrcD, clk, reset,
                instrD, PcPlus4D);
  
  	// Do some operations
 	regfile the_rf( clk, reset, RegWriteW, instrD[25:21], instrD[20:16], WriteRegW, resultW, rd1, rd2);
  	mux2 #(32) eq_mux1(rd1, ALUOutM, ForwardAD, eqSrcA);
  	mux2 #(32) eq_mux2(rd2, ALUOutM, ForwardBD, eqSrcB);
  	assign PcSrcD = (eqSrcA == eqSrcB) && BranchD;

  	signext signExtend(instrD[15:0], SignImmd);
	sl2 sl(SignImmd, SignImmdSL2);
	assign PcBranchD = PcPlus4D + SignImmdSL2;
  
  	// Instantiate PipeDtoE
  	PipeDtoE pipe3( rd1, rd2, SignImmd, instrD[25:21], instrD[20:16], instrD[15:11],
                	RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD, ALUControlD,
               		FlushE, clk, reset,
                	RsData, RtData, SignImmE,
                	RsE, RtE, RdE, 
                	RegWriteE, MemtoRegE, MemWriteE, ALUSrcE, RegDstE, ALUControlE);
  
  	// Do some operations
  	mux2 #(32) regDst_mux( RtE, RdE, RegDstE, WriteRegE);
  	mux2 #(32) aluSrc_mux( WriteDataE, SignImmE, ALUSrcE, SrcBE);
  	mux4 #(32) forward_muxA( RsData, resultW, ALUOutM, 0, ForwardAE, SrcAE);
  	mux4 #(32) forward_muxB( RtData, resultW, ALUOutM, 0, ForwardBE, WriteDataE);

  	logic unused;
	alu the_alu( SrcAE, SrcBE, ALUControlE, ALUOutE, unused);
  
  	// Instantiate PipeEtoM
  	PipeEtoM pipe4( ALUOutE, WriteDataE, WriteRegE,
    				RegWriteE, MemtoRegE, MemWriteE,
                	clk, reset,
                   	ALUOutM, WriteDataM, WriteRegM,
                   	RegWriteM, MemtoRegM, MemWriteM);
  
  	// Do some operations
  	dmem memory( clk, MemWriteM, ALUOutM, WriteDataM, ReadDataM);

  	// Instantiate PipeMtoW
  	PipeMtoW pipe5( ALUOutM, ReadDataM, WriteRegM,
                 	RegWriteM, MemtoRegM,
                 	clk, reset,
                 	ALUOutW, ReadDataW,
                  	WriteRegW,
    				RegWriteW, MemtoRegW);
  
  	// Do some operations
  	mux2 #(32) res_mux( ALUOutW, ReadDataW, MemtoRegW, resultW);
  
  	// Instantiate the Hazard Unit
  	HazardUnit hazard_unit( RegWriteW, BranchD,
    						WriteRegW, WriteRegE,
                 			RegWriteM, MemtoRegM,
                           	WriteRegM,
 							RegWriteE, MemtoRegE,
                 			RsE, RtE,
                 			instrD[25:21], instrD[20:16],
                 			ForwardAE, ForwardBE,
                			FlushE, StallD, StallF, ForwardAD, ForwardBD);

endmodule

module HazardUnit( input logic RegWriteW, BranchD,
                input logic [4:0] WriteRegW, WriteRegE,
                input logic RegWriteM,MemtoRegM,
                input logic [4:0] WriteRegM,
                input logic RegWriteE,MemtoRegE,
                input logic [4:0] rsE,rtE,
                input logic [4:0] rsD,rtD,
                output logic [1:0] ForwardAE,ForwardBE,
                output logic FlushE,StallD,StallF,ForwardAD, ForwardBD
                 ); // Add or remove input-outputs if necessary
       
	// ********************************************************************
	// Here, write equations for the Hazard Logic.
	// If you have troubles, please study pages ~420-430 in your book.
	// ********************************************************************
  	logic branchstall, lwstall;
  
    assign ForwardAE = ((rsE != 0) && (rsE == WriteRegM) && RegWriteM) ? 10 : ((((rsE != 0) && (rsE == WriteRegW) && RegWriteW)) ? 01 : 00);
    assign ForwardBE = ((rtE != 0) && (rtE == WriteRegM) && RegWriteM) ? 10 : ((((rtE != 0) && (rtE == WriteRegW) && RegWriteW)) ? 01 : 00);
    assign ForwardAD = (rsD !=0) && (rsD == WriteRegM) && RegWriteM;
    assign ForwardBD = (rtD !=0) && (rtD == WriteRegM) && RegWriteM ;

    assign branchstall = BranchD && RegWriteE && (WriteRegE == rsD || WriteRegE == rtD) || BranchD && MemtoRegM && (WriteRegM == rsD || WriteRegM == rtD);
    assign lwstall = ((rsD==rtE) || (rtD==rtE)) && MemtoRegE;
    assign StallF = (lwstall || branchstall);
    assign StallD = (lwstall || branchstall);
    assign FlushE = (lwstall || branchstall);
endmodule


// You can add some more logic variables for testing purposes
// but you cannot remove existing variables as we need you to output 
// these values on the waveform for grading
module top_mips (input  logic        clk, reset,
             output  logic[31:0]  instrF,
             output logic[31:0] PC, PCF,
             output logic PcSrcD,
             output logic MemWriteD, MemtoRegD, ALUSrcD, BranchD, RegDstD, RegWriteD,
             output logic [2:0]  alucontrol,
             output logic [31:0] instrD, 
             output logic [31:0] ALUOutE, WriteDataE,
             output logic [1:0] ForwardAE, ForwardBE,
             output logic ForwardAD, ForwardBD);


	// ********************************************************************
	// Below, instantiate a controller and a datapath with their new (if modified) signatures
	// and corresponding connections.
	// ********************************************************************
  	datapath the_dp(clk, reset,
    				alucontrol, RegWriteD, MemtoRegD, MemWriteD, ALUSrcD, RegDstD, BranchD,
                 	instrF, instrD, PC, PCF, PcSrcD, ALUOutE, WriteDataE, ForwardAE, ForwardBE, ForwardAD, ForwardBD);

  	controller the_cnt( instrD[31:26], instrD[5:0],
						MemtoRegD, MemWriteD, ALUSrcD, RegDstD, RegWriteD, alucontrol, BranchD);
endmodule


// External instruction memory used by MIPS
// processor. It models instruction memory as a stored-program 
// ROM, with address as input, and instruction as output
// Modify it to test your own programs.

module imem ( input logic [5:0] addr, output logic [31:0] instr);

// imem is modeled as a lookup table, a stored-program byte-addressable ROM
	always_comb
	   case ({addr,2'b00})		   	// word-aligned fetch
//
// 	***************************************************************************
//	Here, you can paste your own test cases that you prepared for the part 1-e.
//  An example test program is given below.        
//	***************************************************************************
//
//		address		instruction
//		-------		-----------
	   8'h00: instr = 	32'h20080007;
        8'h04: instr = 	32'h20090005;
        8'h08: instr = 	32'h01095020;
        8'h0c: instr = 	32'had280002;
        8'h10: instr = 	32'h8d090000;
        8'h14: instr = 	32'h11000001;
        8'h18: instr = 	32'h200a000a;
        8'h1c: instr = 	32'h2009000c;
        8'h20: instr = 	32'h20080005;
        8'h24: instr = 	32'h21090006;
        8'h28: instr = 	32'hAD090005;
        8'h2c: instr = 	32'h20090006;
        8'h30: instr = 	32'h20040001;
        8'h34: instr = 	32'h20050002;
        8'h38: instr = 	32'had280000;
        8'h3c: instr = 	32'h8d090001;
        8'h40: instr = 	32'h8d090001;
        8'h44: instr = 	32'h01245020;
        8'h48: instr = 	32'h01255022;
        8'h4c: instr = 	32'h20090002;
        8'h50: instr = 	32'h11200001;
        8'h54: instr = 	32'h11290001;
        8'h58: instr = 	32'h20090005;
        8'h5c: instr = 	32'h21290006;
        8'h60: instr = 	32'h20040000;
        8'h64: instr = 	32'h20050000;
        8'h68: instr = 	32'hac090000;
       default:  instr = {32{1'bx}};	// unknown address
	   endcase
endmodule


// 	***************************************************************************
//	Below are the modules that you shouldn't need to modify at all..
//	***************************************************************************

module controller(input  logic[5:0] op, funct,
                  output logic     memtoreg, memwrite,
                  output logic     alusrc,
                  output logic     regdst, regwrite,
                  output logic[2:0] alucontrol,
                  output logic branch);

   logic [1:0] aluop;

  maindec md (op, memtoreg, memwrite, branch, alusrc, regdst, regwrite, aluop);

   aludec  ad (funct, aluop, alucontrol);

endmodule

// External data memory used by MIPS single-cycle processor

module dmem (input  logic        clk, we,
             input  logic[31:0]  a, wd,
             output logic[31:0]  rd);

   logic  [31:0] RAM[63:0];
  
   assign rd = RAM[a[31:2]];    // word-aligned  read (for lw)

   always_ff @(posedge clk)
     if (we)
       RAM[a[31:2]] <= wd;      // word-aligned write (for sw)

endmodule

module maindec (input logic[5:0] op, 
	              output logic memtoreg, memwrite, branch,
	              output logic alusrc, regdst, regwrite,
	              output logic[1:0] aluop );
  logic [7:0] controls;

   assign {regwrite, regdst, alusrc, branch, memwrite,
                memtoreg,  aluop} = controls;

  always_comb
    case(op)
      6'b000000: controls <= 8'b11000010; // R-type
      6'b100011: controls <= 8'b10100100; // LW
      6'b101011: controls <= 8'b00101000; // SW
      6'b000100: controls <= 8'b00010001; // BEQ
      6'b001000: controls <= 8'b10100000; // ADDI
      default:   controls <= 8'bxxxxxxxx; // illegal op
    endcase
endmodule

module aludec (input    logic[5:0] funct,
               input    logic[1:0] aluop,
               output   logic[2:0] alucontrol);
  always_comb
    case(aluop)
      2'b00: alucontrol  = 3'b010;  // add  (for lw/sw/addi)
      2'b01: alucontrol  = 3'b110;  // sub   (for beq)
      default: case(funct)          // R-TYPE instructions
          6'b100000: alucontrol  = 3'b010; // ADD
          6'b100010: alucontrol  = 3'b110; // SUB
          6'b100100: alucontrol  = 3'b000; // AND
          6'b100101: alucontrol  = 3'b001; // OR
          6'b101010: alucontrol  = 3'b111; // SLT
          default:   alucontrol  = 3'bxxx; // ???
        endcase
    endcase
endmodule

module regfile (input    logic clk, reset, we3, 
                input    logic[4:0]  ra1, ra2, wa3, 
                input    logic[31:0] wd3, 
                output   logic[31:0] rd1, rd2);

  logic [31:0] rf [31:0];

  // three ported register file: read two ports combinationally
  // write third port on falling edge of clock. Register0 hardwired to 0.

  always_ff @(negedge clk)
     if (we3) 
         rf [wa3] <= wd3;
  	 else if(reset)
       for (int i=0; i<32; i++) rf[i] = {32{1'b0}};	

  assign rd1 = (ra1 != 0) ? rf [ra1] : 0;
  assign rd2 = (ra2 != 0) ? rf[ ra2] : 0;

endmodule

module alu(input  logic [31:0] a, b, 
           input  logic [2:0]  alucont, 
           output logic [31:0] result,
           output logic zero);
    
    always_comb
        case(alucont)
            3'b010: result = a + b;
            3'b110: result = a - b;
            3'b000: result = a & b;
            3'b001: result = a | b;
            3'b111: result = (a < b) ? 1 : 0;
            default: result = {32{1'bx}};
        endcase
    
    assign zero = (result == 0) ? 1'b1 : 1'b0;
    
endmodule

module adder (input  logic[31:0] a, b,
              output logic[31:0] y);
     
     assign y = a + b;
endmodule

module sl2 (input  logic[31:0] a,
            output logic[31:0] y);
     
     assign y = {a[29:0], 2'b00}; // shifts left by 2
endmodule

module signext (input  logic[15:0] a,
                output logic[31:0] y);
              
  assign y = {{16{a[15]}}, a};    // sign-extends 16-bit a
endmodule

// parameterized register
module flopr #(parameter WIDTH = 8)
              (input logic clk, reset, 
	       input logic[WIDTH-1:0] d, 
               output logic[WIDTH-1:0] q);

  always_ff@(posedge clk, posedge reset)
    if (reset) q <= 0; 
    else       q <= d;
endmodule


// paramaterized 2-to-1 MUX
module mux2 #(parameter WIDTH = 8)
             (input  logic[WIDTH-1:0] d0, d1,  
              input  logic s, 
              output logic[WIDTH-1:0] y);
  
   assign y = s ? d1 : d0; 
endmodule

// paramaterized 4-to-1 MUX
module mux4 #(parameter WIDTH = 8)
             (input  logic[WIDTH-1:0] d0, d1, d2, d3,
              input  logic[1:0] s, 
              output logic[WIDTH-1:0] y);
  
   assign y = s[1] ? ( s[0] ? d3 : d2 ) : (s[0] ? d1 : d0); 
endmodule