/*
Module Name: pc_reg
Description: 
用于产生PC寄存器的值，该值会被用作指令存储器的地址信号。
*/

`include "defines.v"

//PC register module
module pc_reg(
    input wire clk,
    input wire rst,

    input wire                  jump_flag_i,        //跳转标志
    input wire[`InstAddrBus]    jump_addr_i,        //跳转地址
    input wire[`Hold_Flag_Bus]  hold_flag_i,        //流水线暂停标志
    input wire                  jtag_reset_flag_i,  //复位标志

    output reg[`InstAddrBus]    pc_o                //PC指针

);

    always @(posedge clk) begin
        //Reset
        if (rst == `RstEnable || jtag_reset_flag_i == 1'b1) begin
            pc_o <= `CpuResetAddr;
        end
        // Jump
        else if (jump_flag_i == `JumpEnable) begin
            pc_o <= jump_addr_i;
        end 
        //Stop
        else if (hold_flag_i >= `Hold_Pc) begin
            pc_o <= pc_o;
        end 
        //Addr + 4
        else begin
            pc_o <= pc_o + 4'h4;
        end
    end

endmodule