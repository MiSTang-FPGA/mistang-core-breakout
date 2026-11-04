// Monochrome pixel of the Breakout playfield. x 0..159, y 0..119, st from breakout_game.
module breakout_pixel (input logic [7:0] x, input logic [6:0] y, input logic [75:0] st, output logic px);
    wire [7:0] bx = st[75:68], by = st[67:60], padx = st[59:52];
    wire [1:0] lives = st[51:50];
    wire [49:0] bricks = st[49:0];
    wire wall = (y < 2) || (x < 2) || (x >= 158);
    wire pad  = (x >= padx) && (x < padx + 24) && (y >= 108) && (y < 111);
    wire ball = (x >= bx) && (x < bx + 3) && (y >= by) && (y < by + 3);
    // bricks: 10 x 5, cell 14 x 8, drawn 13 x 6
    wire in_b = (y >= 14) && (y < 54) && (x >= 10) && (x < 150);
    wire [7:0] bxr = x - 8'd10; wire [6:0] byr = y - 7'd14;
    wire [3:0] col = bxr / 14; wire [2:0] row = byr[5:3];
    wire [3:0] cxm = bxr % 14; wire [2:0] cym = byr[2:0];
    wire [5:0] idx = row * 10 + col;
    wire brick = in_b && (cxm < 13) && (cym < 6) && bricks[idx];
    wire life = (y >= 114) && (y < 118) && (x >= 6) && (x < 24) && (((x - 6) % 6) < 4) && (((x - 6) / 6) < lives);
    assign px = wall | pad | ball | brick | life;
endmodule
