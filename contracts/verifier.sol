// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x05981db89689be4d762c5280592a27eed9310e567be49cfc54e4ad21c8798da1), uint256(0x05bb997422ee7b19bb645642162e5f8fde112036980a197b33296e052c13de1d));
        vk.beta = Pairing.G2Point([uint256(0x22c88207c9dcb31f4aab5dbdca04c834f42508f1a0bc312dc5ca4e84e429ae80), uint256(0x01d0bedc0d76e2caff4035a181da48033fa92d12e40f310c45fb205150b02a25)], [uint256(0x1961fd7bd57345a3917ca3d820aea34280a2828d8f54a25c31df521434414cb0), uint256(0x1dcdbcdeec271d85bc35d0e342961fbaa3f58f1047a75fbf3d0ec801dcf46488)]);
        vk.gamma = Pairing.G2Point([uint256(0x05ed7739bd3ac21af116aeb950e5fcb68a2de6e26b1e0b1151ff3b9677124a67), uint256(0x294e9acab45ab7e344d99ffdb2e60f8d63fa51b13b32b75015e4cefd8cc6ee7b)], [uint256(0x2dbb86a7b83ed10d4222b20eb7a6270be1c307d23a1deeda5d8fce99508dcc22), uint256(0x2ff9c130f72aebf9509c29a7434110fd3092ac06e261a3da72e153fa4cb1e98b)]);
        vk.delta = Pairing.G2Point([uint256(0x1dc0f2e93095a58b4f478038c667736dabf69fc70da71465f995355c7eca321a), uint256(0x2a75679234cfd610e6fbeac61cf6a7ca6399fca6cdaec78e1749f53052532110)], [uint256(0x10da80b0a89b691de94bb690ef25f74537db15f389f92aa6b3d948942535ab7f), uint256(0x1c2bc8b5b3fc52c9740ca21b786362ed4752c0ec4aaf7431507011a63fe2418e)]);
        vk.gamma_abc = new Pairing.G1Point[](8);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2cf6ce9a82755fd9a6fe09bf5c1605c1aa59ae318e6c67360de420d89c04d8fc), uint256(0x0649a328fd348ef886a2e20f217ed0b1e054f1bc055e6e2fe6a2f90afe93ea9d));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1e45736061c9f92e3253dc6b610395d54d2e072149901595574a481b8c6753d1), uint256(0x20d7c4f7b77f5f8804eacc0792adeabb3ba6da4bea141feed317b4c8c6a8b0c7));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0d64c36605089a3a87e03b3ccf5185c8d4c33ef617fec0b5a1afee17419d327c), uint256(0x037a2c450f88bdccefc70ebb679e32be03d3acb6975d38eae529ae5e9cf4f9b5));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x0338fd1966b8c039a032e722a0bd90cddc750180c4b9c5bd7ee4182837c6c881), uint256(0x23526bd7add626a37ab83a53266dedeb0b35aa2124ab6bf906e5d268798eeb56));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2210b57ea1cac8316f15762eff4a27c2bb1bd8bf3621941d62b52c3689d118bc), uint256(0x1ece15e2ce4d76b30ed249b7644065a72d885b3382d96a8147106ff02769e220));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x11017a720676b94d568c4c3589977dd7b564be646e8c407221de159f11013ba5), uint256(0x2acc6f39ed848c28a09d463907533bb7eac59b71c805f688b72278cfb509e52a));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2f3fef87ee77fc969ca529a5eb75338a514fbe1b360a9e65b9613e228bc14847), uint256(0x2ba54fb0020272ab747566c1cd7510679341c1af558745311826f4fc57848330));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x03bca4d50863d653d1dc28a5ede94531d7357c922c134243c5dbfb19d4a91d51), uint256(0x1a407cd9f6985413f4d678ca697529b8bce15041a34f42d32172d7cdc22778be));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[7] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](7);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
