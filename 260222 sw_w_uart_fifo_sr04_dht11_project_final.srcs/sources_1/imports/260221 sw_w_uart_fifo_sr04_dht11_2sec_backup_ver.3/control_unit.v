`timescale 1ns / 1ps

module control_unit (
    input clk,
    input rst,
    input i_sel_mode,  
    input i_mode,      
    input i_run_stop,  
    input i_clear,     
    input i_down_u,    
    input i_down_d,    

    output reg o_mode,
    output reg o_run_stop,
    output reg o_clear,

    output reg o_watch_up_l,    
    output reg o_watch_up_r,    
    output reg o_watch_down_u,  
    output reg o_watch_down_d,  
    output reg o_watch_change   
);

    reg [1:0] current_st, next_st;
    localparam STOP = 2'b00, RUN = 2'b01, CLEAR = 2'b10;

    
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            current_st <= STOP;
        end else begin
            current_st <= next_st;
        end
    end

    always @(*) begin
        
        next_st = current_st;
        o_run_stop = 1'b0;
        o_clear = 1'b0;
        o_mode = 1'b0;

        o_watch_change = 1'b0;
        o_watch_up_l = 1'b0;
        o_watch_up_r = 1'b0;
        o_watch_down_u = 1'b0;
        o_watch_down_d = 1'b0;

        
        if (i_sel_mode == 0) begin
            
            o_mode = i_mode;  

            case (current_st)
                STOP: begin
                    o_run_stop = 0;
                    o_clear = 0;
                    if (i_run_stop == 1) begin
                        next_st = RUN;
                    end else if (i_clear == 1) begin
                        next_st = CLEAR;
                    end else begin
                        next_st = STOP;
                    end
                end

                RUN: begin
                    o_run_stop = 1;  
                    o_clear = 0;
                    if (i_run_stop == 1) begin
                        next_st = STOP;
                    end else begin
                        next_st = RUN;
                    end
                end

                CLEAR: begin
                    o_run_stop = 0;
                    o_clear = 1;  
                    next_st = STOP; 
                end

                default: begin
                    next_st = STOP;
                    o_clear = 0;
                    o_run_stop = 0;
                end
            endcase

        end else begin
            
            o_watch_change = i_mode;  

            
            o_watch_up_l = i_clear;  
            o_watch_up_r = i_run_stop;  

            
            o_watch_down_u = i_down_u;    
            o_watch_down_d = i_down_d;    
        end
    end

endmodule
