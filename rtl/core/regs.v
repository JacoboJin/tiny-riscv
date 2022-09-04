/*
Module Name: regs
Description: register
*/
`include "defines.v"

module regs(
    input wire  clk,
    input wire  rst,

    //  from ex
    input wire              we_i,               //write reg flag
    input wire[`RegAddrBus] waddr_i,            //write reg addr
    input wire[`RegBus]     wdata_i,            //write reg data

    //  from jtag
    input wire              jtag_we_i,          //write reg flag
    input wire[`RegAddrBus] jtag_addr_i,        //w&r reg addr
    input wire[`RegBus]     jtag_data_i,        //write reg data

    //  from id
    input wire[`RegAddrBus] raddr1_i,           //read reg1 addr
    input wire[`RegAddrBus] raddr2_i,           //read reg2 addr
    
    //  to id
    output reg[`RegBus]     rdata1_o,           //read reg1 data
    output reg[`RegBus]     rdata2_o,           //read reg2 data

    //  to jtag
    output reg[`RegBus]     jtag_data_o         //read reg data
);

reg[`RegBus] regs[0:`RegNum - 1];


    //写寄存器
    always @ (posedge clk) begin
        if (rst == `RstDisable) begin
            // 优先ex模块写操作
            if ((we_i == `WriteEnable) && (waddr_i != `ZeroReg)) begin
                regs[waddr_i] <= wdata_i;
            end
            else if ((jtag_we_i == `WriteEnable) && (jtag_addr_i != `ZeroReg)) begin
                regs[jtag_addr_i] <= jtag_data_i;
            end
        end
    end

    // 读寄存器1
    always @ (*) begin
        if (raddr1_i == `ZeroReg) begin
            rdata1_o = `ZeroWord;
        // 如果读地址等于写地址，并且正在写操作，则直接返回写数据
        end 
        else if (raddr1_i == waddr_i && we_i == `WriteEnable) begin
            rdata1_o = wdata_i;
        end 
        else begin
            rdata1_o = regs[raddr1_i];
        end
    end

    // 读寄存器2
    always @ (*) begin
        if (raddr2_i == `ZeroReg) begin
            rdata2_o = `ZeroWord;
        // 如果读地址等于写地址，并且正在写操作，则直接返回写数据
        end else if (raddr2_i == waddr_i && we_i == `WriteEnable) begin
            rdata2_o = wdata_i;
        end else begin
            rdata2_o = regs[raddr2_i];
        end
    end

    // jtag读寄存器
    always @ (*) begin
        if (jtag_addr_i == `ZeroReg) begin
            jtag_data_o = `ZeroWord;
        end else begin
            jtag_data_o = regs[jtag_addr_i];
        end
    end

endmodule