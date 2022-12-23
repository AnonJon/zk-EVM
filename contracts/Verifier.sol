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
        vk.alpha = Pairing.G1Point(uint256(0x03279534d8b452055c14259cff79b10734da25e06445819993127953ac4ff91b), uint256(0x0b64cf7919108143c39e9037b85e72d48f10d92a7a3944fe80edd6b05bf0ce43));
        vk.beta = Pairing.G2Point([uint256(0x05e13d056fb974b383da03535cbfde130fb06c87e53f18ba65c4bd9039975f19), uint256(0x2ac72fc5ce0257138b98505ca098eb9bc9e3e63ae62bebc58cfc712c3e143a6b)], [uint256(0x21a979cc38392ccc2f67d426dcf9475066ea36c7099143266233c77f7d9a2393), uint256(0x12d213aa3e8574ae2088e58e2c2f7045fd5572eea06a0a6b097e70372f1f8e7c)]);
        vk.gamma = Pairing.G2Point([uint256(0x1872a6408083022fb26054ab3f8b1e9b69409277354c75958e914cb81ffe5db5), uint256(0x13c9aec9005929d2a7b220d7dafc734deae52251f08ec16c469e01c3324d22aa)], [uint256(0x0c5d4ec6962e7ec95349d39c0c6d38a18d5e4f263307f2c2a0b1e7414c111986), uint256(0x129ceaef11ef548b834994f33b7294dea657dee9126c902171f631c3cdcbb84b)]);
        vk.delta = Pairing.G2Point([uint256(0x2eed3ef7f10e69db0d2720cd19184e4b41c85cb6feb4f56c26aaea379b144264), uint256(0x13797017e51bf043cef56b94937a3ca1f739637bd6304f1e9702274f6d9d5091)], [uint256(0x24c06652145c7e5df7acbc2acd22693d7255c0ed519069778911a550d4aca061), uint256(0x2ee752fa2d2ebade6be5a11349ae1f0d4afc50c62478e06d9ca57c1a5d5eb716)]);
        vk.gamma_abc = new Pairing.G1Point[](8);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1f4c190ea512b89b1a1029e0586173bdc85b84dfa6408b80c8c3b28dab0a5668), uint256(0x1eec1619f485fd15ecd6660232074db2da147e32ae4bc157feee3c34422e5c3f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2995445d285f5dbc77d549be61099d18f37a35d88503a1392ff10780a5da9f7b), uint256(0x294c68e7afca1e0757d6e7591588eb171c1435a1eb9c6d5f5b6be84a7d4413e7));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0dd38ed824d6b9979e44b5ce547f22a016bfb92a4538f27a104a0bfb727f1645), uint256(0x01a67fc7e2430fec1a360bda153a0a593a16a3cea3c4a4d6059042338e156cef));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x247cddb0988acb6a75ceb8063764304f7ebd19e63a4b2f8f0d5777cf0825e44a), uint256(0x260fa344661cbd5ae9ccc17f846d30038ed919fae6d6f31e2bb5608129af9f7c));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0122bb1485bbdda8029890bbf2030a93c407a634249ab9a1e39a5d40f19ab28e), uint256(0x0c385c01fead30c793744bc9eec82382febed4e8a5573970e2fcfc480f2e2902));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0008e130ce835aac7eb563f75ff20d07f44e14343b81f970a52251438b757b71), uint256(0x02f56fa272e9a9efa9b1d1277ae518053c4a2a8c10604ba339412ceb67e499ef));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2982a213fbc185b85f8acc1436ca203541c79c9f2c1368add7aae1a374c9b17d), uint256(0x2af4fedd628716eb0258c68ac8eee7ab3abc8aa6d2ecb2e0b36fd871aaaefee7));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0f6406021ff4e92faf9557ad0604f7a80325ee05e46288e8c838a23332ba71e8), uint256(0x278ead5933b3a8748b66ba6c335538bc6dc25bdd2d0dac3151d459c196d22764));
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
