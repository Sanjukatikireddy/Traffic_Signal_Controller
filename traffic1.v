module traffic1(
    input clk,
    input rst,
    input ped_req,
    input emergency_NS,
    input emergency_EW,
    output reg [2:0] NS,
    output reg [2:0] EW
);

parameter GREEN  = 3'b001;
parameter YELLOW = 3'b010;
parameter RED    = 3'b100;

parameter S_NS_GREEN   = 3'd0;
parameter S_NS_YELLOW  = 3'd1;
parameter S_EW_GREEN   = 3'd2;
parameter S_EW_YELLOW  = 3'd3;
parameter S_PED        = 3'd4;
parameter S_EM_NS      = 3'd5;
parameter S_EM_EW      = 3'd6;

reg [2:0] state;
reg [4:0] timer;
reg       ped_req_latch;   

always @(posedge clk or posedge rst)
begin
    if (rst)
        ped_req_latch <= 0;
    else if (ped_req)
        ped_req_latch <= 1;
    else if (state == S_PED)
        ped_req_latch <= 0;
end

always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        state <= S_NS_GREEN;
        timer <= 0;
    end
    else
    begin
        if (emergency_NS)
        begin
            state <= S_EM_NS;
            timer <= 0;
        end
        else if (emergency_EW)
        begin
            state <= S_EM_EW;
            timer <= 0;
        end
        else
        begin
            case (state)

                S_NS_GREEN:
                begin
                    if (timer == 9)
                    begin
                        state <= S_NS_YELLOW;
                        timer <= 0;
                    end
                    else
                        timer <= timer + 1;
                end

                S_NS_YELLOW:
                begin
                    if (timer == 1)
                    begin
                        if (ped_req_latch)          //  use latched value
                            state <= S_PED;
                        else
                            state <= S_EW_GREEN;
                        timer <= 0;
                    end
                    else
                        timer <= timer + 1;
                end

                S_EW_GREEN:
                begin
                    if (timer == 9)
                    begin
                        state <= S_EW_YELLOW;
                        timer <= 0;
                    end
                    else
                        timer <= timer + 1;
                end

                S_EW_YELLOW:
                begin
                    if (timer == 1)
                    begin
                        if (ped_req_latch)          //  use latched value
                            state <= S_PED;
                        else
                            state <= S_NS_GREEN;
                        timer <= 0;
                    end
                    else
                        timer <= timer + 1;
                end

                S_PED:
                begin
                    if (timer == 4)
                    begin
                        state <= S_NS_GREEN;
                        timer <= 0;
                    end
                    else
                        timer <= timer + 1;
                end

                S_EM_NS:
                begin
                    if (!emergency_NS)
                    begin
                        state <= S_NS_GREEN;
                        timer <= 0;
                    end
                    else
                        timer <= 0;
                end

                S_EM_EW:
                begin
                    if (!emergency_EW)
                    begin
                        state <= S_EW_GREEN;
                        timer <= 0;
                    end
                    else
                        timer <= 0;
                end

                default:
                begin
                    state <= S_NS_GREEN;
                    timer <= 0;
                end

            endcase
        end
    end
end

always @(*)
begin
    NS = RED;
    EW = RED;
    case (state)
        S_NS_GREEN:  begin NS = GREEN;  EW = RED;    end
        S_NS_YELLOW: begin NS = YELLOW; EW = RED;    end
        S_EW_GREEN:  begin NS = RED;    EW = GREEN;  end
        S_EW_YELLOW: begin NS = RED;    EW = YELLOW; end
        S_PED:       begin NS = RED;    EW = RED;    end
        S_EM_NS:     begin NS = GREEN;  EW = RED;    end
        S_EM_EW:     begin NS = RED;    EW = GREEN;  end
        default:     begin NS = RED;    EW = RED;    end
    endcase
end

endmodule
