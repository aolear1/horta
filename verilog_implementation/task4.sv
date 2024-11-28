`define Sfire     2'd0
`define Sreload   2'd1
`define Scocked   2'd2


module task4(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module
logic [9:0] VGA_R_10;
logic [9:0] VGA_G_10;
logic [9:0] VGA_B_10;
logic VGA_BLANK, VGA_SYNC;
logic done_all;
logic done_f;
logic done;
logic r_start;

assign VGA_R = VGA_R_10[9:2];
assign VGA_G = VGA_G_10[9:2];
assign VGA_B = VGA_B_10[9:2];

assign LEDR[0] = done_f;
assign LEDR[1] = done_all;

logic [2:0] colour;
logic [7:0] centre_x;
logic [6:0] centre_y;
logic [7:0] diameter;

//connections

logic plot;
logic plot_f;
logic plot_r;

logic [2:0] vga_colour_r;
logic [7:0] vga_xr; //r for reuleaux
logic [6:0] vga_yr;
logic [7:0] x;
logic [6:0] y;

assign VGA_X = done_f ? (vga_xr >= 160) ? 8'd0: vga_xr : x; //driver either circle or fillscreen
assign VGA_Y = done_f ? (vga_yr >= 120) ? 7'd0: vga_yr : y;
assign VGA_COLOUR = done_f ? vga_colour_r : 3'b000;
 
assign plot = done_f ? plot_r : 1'b1;
assign VGA_PLOT = plot & !done_all;
assign done_all = done;
 
assign colour = 3'b010;
assign centre_x = 8'd80;
assign centre_y = 7'd60;
assign diameter = 8'd80;

assign r_start = done_f;



/*Module Connections*/
vga_adapter#(.RESOLUTION("160x120"))vga_u0(.resetn(KEY[3]), .clock(CLOCK_50), .colour(VGA_COLOUR),
		.x(VGA_X), .y(VGA_Y), .plot(VGA_PLOT),
		.VGA_R(VGA_R_10), .VGA_G(VGA_G_10), .VGA_B(VGA_B_10),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.VGA_BLANK(VGA_BLANK),
		.VGA_SYNC(VGA_SYNC),
		.VGA_CLK(VGA_CLK)
		);

reuleaux dut( .clk(CLOCK_50),
                .rst_n(KEY[3]),
                .colour(colour),
                .centre_x(centre_x),
                .centre_y(centre_y),
                .diameter(diameter),
                .start(r_start), //starts when fillscreen is done
                .done(done),
                .vga_x(vga_xr),
                .vga_y(vga_yr),
                .vga_colour(vga_colour_r),
                .vga_plot(plot_r));

/*fill screen*/
always_ff @(posedge CLOCK_50) begin
     if (!KEY[3]) begin
          /*Reset Case*/
          done_f <= 1'b0;
          x <= 8'd0;
          y <= 8'd0;
     end else begin
          if (!done_f) begin
               if (x == 159) begin
                    if (y == 119) begin
                         done_f <= 1'b1;
                    end else begin
                         x <= 8'd0;
                         y <= y + 1;
                    end
               end else begin
                    x <= x + 1;
               end
          end
     end
end
                
endmodule: task4
