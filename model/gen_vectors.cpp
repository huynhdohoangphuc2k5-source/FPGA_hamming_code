// Sinh file vectors.txt cho testbench Verilog (khong loi + 1 loi)
// Moi dong (hex): data code_clean err_mask code_rx syndrome data_out
// 16 data x 8 mask = 128 vector
//
// Can file hamming_golden.h nam CUNG THU MUC voi file nay.
#include <fstream>
#include <iostream>
#include <iomanip>
#include "hamming_golden.h"
using namespace std;

// k = 0 : khong loi; k = 1..7 : lat bit thu k
int tao_mask(int k) {
    if (k == 0) return 0;
    return 1 << (k - 1);
}

int main() {
    ofstream outFile("vectors.txt");
    if (!outFile) {
        cout << "Loi: khong mo duoc vectors.txt" << endl;
        return 1;
    }

    int so_dong = 0;
    int so_sai  = 0;

    // In hex viet hoa, dien so 0 ben trai khi dung setw
    outFile << uppercase << hex << setfill('0');

    for (int data = 0; data < 16; data++) {

        // Tach 4 bit data (data = {d4,d3,d2,d1})
        int d1 = (data >> 0) & 1;
        int d2 = (data >> 1) & 1;
        int d3 = (data >> 2) & 1;
        int d4 = (data >> 3) & 1;

        int code_dung = hamming_encode(d1, d2, d3, d4);

        for (int k = 0; k < 8; k++) {
            int mask      = tao_mask(k);
            int code_nhan = code_dung ^ mask;

            int syndrome = 0;
            int data_ra  = hamming_decode(code_nhan, syndrome);

            outFile << setw(1) << data       << ' '
                    << setw(2) << code_dung  << ' '
                    << setw(2) << mask       << ' '
                    << setw(2) << code_nhan  << ' '
                    << setw(1) << syndrome   << ' '
                    << setw(1) << data_ra    << '\n';

            so_dong++;
            if (data_ra != data) so_sai++;
        }
    }

    outFile.close();

    if (so_sai == 0) {
        cout << "Da ghi " << so_dong << " vector. Self-check golden: PASS" << endl;
        return 0;
    } else {
        cout << "Da ghi " << so_dong << " vector. Self-check golden: FAIL ("
             << so_sai << " dong sai)" << endl;
        return 1;
    }
}
