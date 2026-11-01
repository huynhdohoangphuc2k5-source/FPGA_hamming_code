module hamming_encode (
    input  wire [3:0] data,
    output wire [6:0] codeword
);
    wire p1;
    wire p2;
    wire p3;

    assign p1 = data[0] ^ data[1] ^ data[3];
    assign p2 = data[0] ^ data[2] ^ data[3];
    assign p3 = data[1] ^ data[2] ^ data[3];

    assign codeword = {data[3],data[2],data[1],p3,data[0],p2,p1}; // nguoc lai vi {} trong verilog chi so cao nhat sang tri 6 5 4 3 2 1

endmodule
