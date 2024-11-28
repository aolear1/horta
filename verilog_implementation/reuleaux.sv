`define sqrt3_6 20'b0100_1001_1110_0110_1010 //0.01001 in binary -> 0100100>>7
`define sqrt3_3 20'b1001_0011_1100_1101_0100 //0.10010 in binary -> 1001001>>7

module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);

     /*Logic assignments for Tri-Circles*/
     wire [7:0]  di_2 = ((diameter + 1'b1) >> 1);
     wire [26:0] b_di = diameter;
     wire [7:0]  c_x1 = centre_x + di_2;
     wire [6:0]  c_y1 = centre_y + ((((b_di * `sqrt3_6) >> 19) + 1'b1) >> 1);
     wire signed [8:0]  c_x2 = centre_x - di_2;
     wire [6:0]  c_y2 = centre_y + ((((b_di * `sqrt3_6) >> 19) + 1'b1) >> 1);
     wire [7:0]  c_x3 = centre_x;
     wire signed [7:0]  c_y3 = centre_y - ((((b_di * `sqrt3_3) >> 19) + 1'b1) >> 1);

     /*State definitions*/
     enum {Soct6, Sreload, Scocked, Soct2, Soct3, Soct5, Soct7, Soct8} state;

     /*Signed coordinates and logic for circle drawing*/
     logic signed [8:0] x;
     logic signed [7:0] y;
     logic signed [9:0] crit;
     logic [8:0] offset_x;
     logic [8:0] offset_y;
     logic vga_plot_off;

     /*Sets vga_x and vga_y to the non-sign bits of x and y*/
     assign vga_x = x[7:0];
     assign vga_y = y[6:0];

     /*Ensures vga_plot is low if x or y is negative or outside bounds*/
     assign vga_plot = !(vga_plot_off | x[8] | y[7] | (vga_x >= 160) | (vga_y >= 120));

     /*Assign colour*/
     assign vga_colour = colour;

     always_ff @(posedge clk) begin
          if (!rst_n) begin
               done = 1'b0;
               vga_plot_off <= 1'b1;
               state <= Sreload;
          end else begin
               case(state)
                    /*Begin with reload and cocked state to wait for fillscreen to assert done*/
                    Sreload: begin
                         if(!start) begin
                              done <= 1'b0;
                              vga_plot_off <= 1'b1;
                              state <= Scocked;
                         end else begin
                              state <= Sreload;
                         end
                    end

                    Scocked: begin
                         if(start) begin
                              /*Prep singals to begin drawing Reuleaux Triangle*/
                              crit <= 1'b1 - diameter;
                              offset_x <= diameter;
                              offset_y <= 0;
                              vga_plot_off <= 1'b0;
                              state <= Soct5;
                         end else begin
                              state <= Scocked;
                         end
                    end

                    Soct5: begin
                         x <= c_x1 - offset_x;
                         y <= c_y1 - offset_y;

                         /*Simplified comparison to know which set of octants to run*/
                         if (offset_y < di_2) begin
                              state <= Soct2;
                         end else begin
                              state <= Soct6;
                         end
                    end

                    Soct2: begin
                         x <= c_x3 + offset_y;
                         y <= c_y3 + offset_x;
                         state <= Soct3;
                    end

                    Soct3: begin
                         x <= c_x3 - offset_y;
                         y <= c_y3 + offset_x;
                         state <= Soct8;
                    end

                    Soct6: begin
                         x <= c_x1 - offset_y;
                         y <= c_y1 - offset_x;
                         state <= Soct7;
                    end

                    Soct7: begin
                         x <= c_x2 + offset_y;
                         y <= c_y2 - offset_x;
                         state <= Soct8;
                    end

                    default: begin
                         x <= c_x2 + offset_x;
                         y <= c_y2 - offset_y;

                         if (offset_x - (crit > 0) < offset_y + 1) begin
                              /*Reuleaux Triangle is completed*/
                              done <= 1'b1;
                              state <= Sreload;
                         end else begin
                              /*Update crit and offsets, keep drawing*/
                              if(crit <= 0) begin
                                   crit <= crit + (2'd2*(offset_y+1'b1))+1'b1;
                                   offset_y <= offset_y + 1'b1;
                              end else begin
                                   crit <= crit + 2'd2*((offset_y + 1'b1) - (offset_x - 1'b1)) + 1'b1;
                                   offset_x <= offset_x - 1'b1;
                                   offset_y <= offset_y + 1'b1;
                              end

                              state <= Soct5;
                         end
                    end
               endcase
          end
     end
endmodule

