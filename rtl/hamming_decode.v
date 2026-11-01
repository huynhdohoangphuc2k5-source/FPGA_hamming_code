module hamming_decode (
    input  wire [6:0] codeword,
    output wire [3:0] data,
    output wire [2:0] syndrome_out,
    output wire       error_detected
);

    wire s1 = codeword[0] ^ codeword[2] ^codeword[4] ^ codeword[6];
    wire s2 = codeword[1] ^ codeword[2] ^codeword[5] ^ codeword[6];
    wire s3 = codeword[3] ^ codeword[4] ^codeword[5] ^ codeword[6];

    assign syndrome_out   = {s3,s2,s1};
    assign error_detected = (syndrome_out != 3'b000);
    wire [6:0] mask  = error_detected ? (7'b1 << (syndrome_out - 3'd1)) : 7'b0;
    wire [6:0] fixed = codeword ^ mask;


    assign data = {fixed[6], fixed[5], fixed[4], fixed[2]};

endmodule
