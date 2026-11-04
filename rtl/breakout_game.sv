// Breakout game logic for MiSTang. Original implementation. 160x120 logical playfield, one step per `tick`.
// 10x5 bricks (14x8 cells at x 10, y 14), paddle 24 px wide at y 108, ball 3x3. Idle for 3 s -> the paddle plays itself.
module breakout_game (
    input  logic       clk, rst, tick,
    input  logic       left, right,
    output logic [75:0] st                    // {bx, by, padx, lives[1:0], bricks[49:0]}
);
    logic signed [10:0] bx, by, vx, vy;
    logic [7:0] padx;
    logic [1:0] lives;
    logic [49:0] bricks;
    logic [8:0] idle;
    assign st = {bx[7:0], by[7:0], padx, lives, bricks};

    logic signed [10:0] nx, ny, nvx, nvy, off, cx, cy;
    logic [7:0] np;
    logic [3:0] col; logic [2:0] row; logic [5:0] idx;
    logic dead;
    always_ff @(posedge clk) begin
        if (rst) begin
            bx <= 80; by <= 90; vx <= 1; vy <= 2; padx <= 68; lives <= 3; bricks <= {50{1'b1}}; idle <= 0;
        end else if (tick) begin
            nx = bx + vx; ny = by + vy; nvx = vx; nvy = vy; np = padx; dead = 0;
            // paddle
            if (left || right) begin
                idle <= 0;
                if (left && padx > 4) np = padx - 3;
                if (right && padx < 132) np = padx + 3;
            end else begin
                if (idle != 9'd180) idle <= idle + 9'd1;
                else if (bx + 1 < padx + 10 && padx > 4) np = padx - 2;
                else if (bx + 1 > padx + 14 && padx < 132) np = padx + 2;
            end
            padx <= np;
            // walls
            if (nx < 2)   begin nx = 2;   nvx = (vx < 0) ? -vx : vx; end
            if (nx > 154) begin nx = 154; nvx = (vx > 0) ? -vx : vx; end
            if (ny < 2)   begin ny = 2;   nvy = (vy < 0) ? -vy : vy; end
            // paddle hit
            if (vy > 0 && ny + 3 >= 108 && ny <= 110 && nx + 3 > np && nx < np + 24) begin
                ny = 105; nvy = -2;
                off = nx + 1 - (np + 12);
                nvx = (off < -8) ? -2 : (off < 0) ? -1 : (off < 8) ? 1 : 2;
            end
            // bricks
            cx = nx + 1; cy = ny + 1;
            if (cy >= 14 && cy < 54 && ((cy - 14) % 8) < 6 && cx >= 10 && cx < 150) begin
                col = (cx - 10) / 14; row = (cy - 14) / 8; idx = row * 10 + col;
                if (bricks[idx]) begin bricks[idx] <= 1'b0; nvy = -nvy; end
            end
            // miss
            if (ny >= 118) dead = 1;
            if (dead) begin
                if (lives == 2'd1) begin lives <= 3; bricks <= {50{1'b1}}; end
                else lives <= lives - 2'd1;
                nx = 80; ny = 90; nvx = 1; nvy = 2;
            end else if (bricks == 50'd0) begin
                bricks <= {50{1'b1}};
                nx = 80; ny = 90; nvx = 1; nvy = 2;
            end
            bx <= nx; by <= ny; vx <= nvx; vy <= nvy;
        end
    end
endmodule
