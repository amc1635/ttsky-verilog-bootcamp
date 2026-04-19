
---

## How it works

The design implements a **2-stage pipelined 8-bit processor**. [cite_start]It optimizes instruction throughput by overlapping the fetch and execution phases[cite: 6, 7].

### Stage 1: Instruction Fetch (IF)
* **SIPO Interface**: Instructions are received serially through a 3-lane input and converted into a **12-bit parallel instruction** using a Serial-In Parallel-Out (SIPO) register.
* [cite_start]**Program Counter (PC)**: Holds the address of the next instruction and increments by 1 to point to the next entry in memory[cite: 39, 45].
* [cite_start]**Instruction Memory (ROM)**: A **12x8-bit memory** that fetches the 12-bit instruction using the current PC value[cite: 42].
* [cite_start]**Instruction Register (IR)**: Temporarily stores the fetched 12-bit instruction[cite: 48].

### Stage 2: Execute (EX)
* **IF/EX Pipeline Register**: Marks the boundary between stages. [cite_start]It receives the instruction from the IR and passes it to the execution logic[cite: 52].
* [cite_start]**Decoder**: Interprets the 12-bit instruction by decoding the opcode to generate control signals for the ALU and memory[cite: 54].
* **Integrated ALU (8-bit)**: Performs arithmetic, logical, and cryptographic operations. It includes:
    * [cite_start]**Arithmetic/Logic**: ADD, SUB, AND, OR, XOR, NOT, INC, and DEC[cite: 95, 98].
    * **Shift Operations**: SHL (Shift Left) and SHR (Shift Right) for bit manipulation.
    * **Flag Logic**: Updates Zero ($Z$), Negative ($N$), and Carry ($C$) flags based on the operation result.
    * **LFSR Crypto Engine**: A Linear Feedback Shift Register used for stream encryption/decryption (XORing data with a pseudo-random seed).
* [cite_start]**Accumulator (ACC)**: An 8-bit register that stores intermediate or final results[cite: 65, 68].
* [cite_start]**Data Memory (RAM)**: A memory module used for **LOAD** and **STORE** operations[cite: 67, 70].



---

## Technical Specifications

* **Instruction Width**: 12 bits.
* [cite_start]**Data Width**: 8 bits[cite: 5].
* [cite_start]**Pipeline Stages**: 2 (Fetch, Execute)[cite: 5].
* **Cryptographic Engine**: 8-bit LFSR with polynomial $x^8 + x^6 + x^5 + x^4 + 1$.
* **Status Flags**: 
    * **Zero (Z)**: Set if result is `0`.
    * **Negative (N)**: Set if Most Significant Bit (MSB) is `1`.
    * **Carry (C)**: Set if operation results in an overflow or a shift-out.

---

## How to test

[cite_start]The design is verified using a comprehensive **testbench** (`tb_Processor_Top`)[cite: 343].

* **SIPO Stimulus**: The 12-bit instruction is fed through serial lanes over multiple clock cycles.
* **ALU Verification**: Test cases verify arithmetic accuracy and that flags ($Z, N, C$) update correctly.
* **Crypto Testing**: The `LOAD_SEED` operation initializes the LFSR, followed by `CRYPTO` operations to verify encrypted data output.
