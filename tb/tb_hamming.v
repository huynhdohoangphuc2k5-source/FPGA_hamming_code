`timescale 1ns/1ps
module tb_hamming;
    reg  [3:0] data;
    wire [6:0] enc_code;
    reg  [6:0] code_rx;
    wire [3:0] dec_data;
    wire [2:0] dec_syn;
    wire       dec_err;

    hamming_encode u_enc (.data(data), .codeword(enc_code));
    hamming_decode u_dec (.codeword(code_rx), .data(dec_data),
                          .syndrome_out(dec_syn), .error_detected(dec_err));

    integer fd, rc;
    integer total, pass_enc, fail_enc, pass_dec, fail_dec;
    reg [3:0] g_data, g_dout;
    reg [6:0] g_code, g_mask, g_rx;
    reg [2:0] g_syn;
    reg ok_enc, ok_dec;

    initial begin
        total = 0; pass_enc = 0; fail_enc = 0; pass_dec = 0; fail_dec = 0;

        fd = $fopen("vectors.txt", "r");
        if (fd == 0) begin
            $display("LOI: khong mo duoc vectors.txt (dat file cung thu muc chay mo phong)");
            $finish;
        end

        rc = $fscanf(fd, "%h %h %h %h %h %h\n",
                     g_data, g_code, g_mask, g_rx, g_syn, g_dout);
        while (rc == 6) begin
            total = total + 1;

            // ---- Check 1: RTL encoder so voi golden ----
            data = g_data;
            #1;
            ok_enc = (enc_code === g_code);
            if (ok_enc) pass_enc = pass_enc + 1;
            else begin
                fail_enc = fail_enc + 1;
                $display("FAIL ENC: data=%h  rtl=%h  golden=%h", g_data, enc_code, g_code);
            end

            // ---- Check 2: RTL decoder so voi golden + data goc + co bao loi ----
            code_rx = g_rx;
            #1;
            ok_dec = (dec_data === g_dout) && (dec_syn === g_syn) &&
                     (dec_data === g_data) && (dec_err === (g_syn != 3'b000));
            if (ok_dec) pass_dec = pass_dec + 1;
            else begin
                fail_dec = fail_dec + 1;
                $display("FAIL DEC: data=%h mask=%h rx=%h | rtl: data=%h syn=%h err=%b | golden: data=%h syn=%h",
                         g_data, g_mask, g_rx, dec_data, dec_syn, dec_err, g_dout, g_syn);
            end

            rc = $fscanf(fd, "%h %h %h %h %h %h\n",
                         g_data, g_code, g_mask, g_rx, g_syn, g_dout);
        end
        $fclose(fd);

        $display("==============================");
        $display(" Tong so vector : %0d", total);
        $display(" Encoder  PASS/FAIL: %0d / %0d", pass_enc, fail_enc);
        $display(" Decoder  PASS/FAIL: %0d / %0d", pass_dec, fail_dec);
        if (fail_enc == 0 && fail_dec == 0 && total > 0) $display(" KET QUA: PASS");
        else                                              $display(" KET QUA: FAIL");
        $display("==============================");
        $finish;
    end
endmodule
