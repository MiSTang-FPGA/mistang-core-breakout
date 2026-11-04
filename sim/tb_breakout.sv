`timescale 1ns/1ps
module tb_breakout;
    logic clk=0, rst=1, tk=1; always #5 clk=~clk;
    logic [75:0] st; logic px; logic [7:0] x; logic [6:0] y;
    breakout_game g(.clk(clk), .rst(rst), .tick(tk), .left(1'b0), .right(1'b0), .st(st));
    breakout_pixel p(.x(x), .y(y), .st(st), .px(px));
    integer f, r, c;
    initial begin
        repeat (3) @(posedge clk); rst <= 0;
        repeat (`TICKS) @(posedge clk);
        #1; tk = 0; #20; f = $fopen("build/rtl_breakout.txt", "w");
        for (r = 0; r < 120; r++) begin
            for (c = 0; c < 160; c++) begin x = c; y = r; #1; $fwrite(f, "%s", px ? "#" : "."); end
            $fwrite(f, "\n");
        end
        $fclose(f); $finish;
    end
endmodule
