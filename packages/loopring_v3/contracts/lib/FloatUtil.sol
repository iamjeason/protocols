// SPDX-License-Identifier: Apache-2.0
/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
pragma solidity ^0.6.10;

import "./MathUint.sol";


/// @title Utility Functions for floats
/// @author Brecht Devos - <brecht@loopring.org>
library FloatUtil
{
    using MathUint for uint;

    // Decodes a decimal float value that is encoded like `exponent | mantissa`.
    // Both exponent and mantissa are in base 10.
    // Decoding to an integer is as simple as `mantissa * (10 ** exponent)`
    // Will throw when the decoded value overflows an uint96
    /// @param f The float value with 5 bits for the exponent
    /// @param numBits The total number of bits (numBitsMantissa := numBits - numBitsExponent)
    /// @return value The decoded integer value.
    function decodeFloat(
        uint f,
        uint numBits
        )
        internal
        pure
        returns (uint value)
    {
        uint numBitsMantissa = numBits.sub(5);
        uint exponent = f >> numBitsMantissa;
        // log2(10**77) = 255.79 < 256
        require(exponent <= 77, "EXPONENT_TOO_LARGE");
        uint mantissa = f & ((1 << numBitsMantissa) - 1);
        value = mantissa.mul(10 ** exponent);
        require(value < (2 ** 96), "FLOAT_VALUE_TOO_LARGE");
    }
}