`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"
`include "cp0def.v"

module ExceptionGen (
	input   	[`INST_BUS]		inst,
	input		[`INST_OP_BUS]	op,
	input       [`FUNCT_BUS]    funct,
	input       [`DATA_BUS]     operand_2,
	output						eret_flag,
	output						syscall_flag,
	output						break_flag,
	output                      zero_flag
);

	assign zero_flag = ( funct == `FUNCT_DIV || funct == `FUNCT_DIVU ) ?
							( operand_2 == 0 ) : 0;
							
	assign eret_flag = (inst == `CP0_ERET_FULL) ? 1 : 0;
	assign syscall_flag = (op == `OP_SPECIAL && funct == `FUNCT_SYSCALL) ? 1 : 0;
	assign break_flag = (op == `OP_SPECIAL && funct == `FUNCT_BREAK) ? 1 : 0;

endmodule // ExceptionGen