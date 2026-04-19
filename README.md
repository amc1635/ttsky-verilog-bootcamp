![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg)
# 8-Bit Cryptographic Pipelined Processor
- [Read the documentation for project](docs/info.md)

- This repository contains the Verilog RTL for a custom 8-bit, two-stage pipelined processor designed for submission to [Tiny Tapeout](https://tinytapeout.com/). 

The processor features a custom 16-instruction ISA, an integrated Arithmetic Logic Unit (ALU), a scratchpad memory system, and a unique hardware-level **LFSR Cryptography Engine** for data encryption and decryption.

---

## 🏗️ Architecture Overview

The processor is divided into two primary pipeline stages to maximize clock frequency and throughput:

### 1. Fetch & Pipeline Stage (`top_processor`)
Instead of utilizing an internal ROM, this design streams instructions directly from the outside world via the Tiny Tapeout input pins. 
* **Program Counter (PC):** Runs continuously to track execution cycles (available as an internal monitor).
* **Pipeline Registers:** Buffers the incoming raw instruction to ensure stable delivery to the execution stage on the next clock edge.

### 2. Execute & Memory Stage (`ex_stage_top`)
* **Decoder:** Splits the incoming instruction bus into a 4-bit Opcode and an 8-bit Operand.
* **Integrated ALU:** Performs arithmetic (ADD, SUB), logical (AND, OR, XOR, NOT), and bitwise operations (SHL, SHR). It updates the main Accumulator and sets condition flags (Zero, Negative, Carry).
* **Memory & Storage:** Manages the primary 8-bit **Accumulator** and a secondary 8-bit **Scratchpad** register for temporary data storage (`STORE` and `LOAD_MEM` instructions).


---

## 🔐 LFSR Cryptography Engine

A standout feature of this processor is the integrated 8-bit Linear Feedback Shift Register (LFSR) used for hardware-accelerated stream cipher operations.

* **Feedback Polynomial:** `x^8 + x^6 + x^5 + x^4 + 1`
* **`LOAD_SEED` (0xC):** Initializes the LFSR with a user-defined 8-bit seed from the operand.
* **`CRYPTO` (0xD):** XORs the current Accumulator value with the LFSR state and automatically shifts the LFSR to generate the next pseudo-random byte. This can be used to symmetrically encrypt or decrypt a stream of data bytes.

---

## 📜 Instruction Set Architecture (ISA)

The ALU and Memory controller use a 4-bit Opcode space, yielding 16 distinct operations.

| Opcode (Bin) | Mnemonic    | Description |
| :--- | :--- | :--- |
| `0000` | **ADD** | Acc = Acc + Operand |
| `0001` | **SUB** | Acc = Acc - Operand |
| `0010` | **AND** | Acc = Acc & Operand |
| `0011` | **OR** | Acc = Acc \| Operand |
| `0100` | **NOT** | Acc = ~Acc (Bitwise Invert) |
| `0101` | **MOV** | Acc = Operand |
| `0110` | **XOR** | Acc = Acc ^ Operand |
| `0111` | **CMP** | Sets Z, N, C flags based on (Acc - Operand). Acc is *not* updated. |
| `1000` | **SHL** | Logical Shift Left. Acc = Acc << 1 |
| `1001` | **SHR** | Logical Shift Right. Acc = Acc >> 1 |
| `1010` | **INC** | Acc = Acc + 1 |
| `1011` | **DEC** | Acc = Acc - 1 |
| `1100` | **LOAD_SEED**| LFSR Seed = Operand. Acc is *not* updated. |
| `1101` | **CRYPTO** | Acc = Acc ^ LFSR. Advances LFSR to next state. |
| `1110` | **STORE** | Scratchpad = Acc |
| `1111` | **LOAD_MEM** | Acc = Scratchpad |

---

## 🔌 Tiny Tapeout I/O Mapping

The top-level module (`tt_um_processor_top`) interfaces directly with the standard Tiny Tapeout PCB pins.

### Inputs
* **`ui_in [7:0]`**: Dedicated Instruction Input. Feeds directly into the processor's fetch stage.
* **`clk`**: System clock.
* **`rst_n`**: Active-low reset.

### Outputs
* **`uo_out [7:0]`**: Dedicated Output. Continuously broadcasts the current value of the Accumulator.

*(Note: Bidirectional `uio` pins are tied low to act as high-Z inputs to comply with TT multiplexer requirements).*

---
