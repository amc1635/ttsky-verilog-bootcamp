
---

## How it works

The design implements a **2-stage pipelined 8-bit processor**.It optimizes instruction throughput by overlapping the fetch and execution phases[cite: 6, 7].

### Stage 1: Instruction Fetch (IF)
* **SIPO Interface**: Instructions are received serially through a 3-lane input and converted into a **12-bit parallel instruction** using a Serial-In Parallel-Out (SIPO) register.
**Program Counter (PC)**: Holds the address of the next instruction and increments by 1 to point to the next entry in memory.
**Instruction Memory (ROM)**: A **12x8-bit memory** that fetches the 12-bit instruction using the current PC value.
**Instruction Register (IR)**: Temporarily stores the fetched 12-bit instruction.

### Stage 2: Execute (EX)
**IF/EX Pipeline Register**: Marks the boundary between stages.It receives the instruction from the IR and passes it to the execution logic.
**Decoder**: Interprets the 12-bit instruction by decoding the opcode to generate control signals for the ALU and memory.
* **Integrated ALU (8-bit)**: Performs arithmetic, logical, and cryptographic operations. It includes:
    ]**Arithmetic/Logic**: ADD, SUB, AND, OR, XOR, NOT, INC, and DEC.
    * **Shift Operations**: SHL (Shift Left) and SHR (Shift Right) for bit manipulation.
    * **Flag Logic**: Updates Zero ($Z$), Negative ($N$), and Carry ($C$) flags based on the operation result.
    * **LFSR Crypto Engine**: A Linear Feedback Shift Register used for stream encryption/decryption (XORing data with a pseudo-random seed).**Accumulator (ACC)**: An 8-bit register that stores intermediate or final results
**Data Memory (RAM)**: A memory module used for **LOAD** and **STORE** operations



---

## Technical Specifications

* **Instruction Width**: 12 bits.
**Data Width**: 8 bits
]**Pipeline Stages**: 2 (Fetch, Execute)
* **Cryptographic Engine**: 8-bit LFSR with polynomial $x^8 + x^6 + x^5 + x^4 + 1$.
* **Status Flags**: 
    * **Zero (Z)**: Set if result is `0`.
    * **Negative (N)**: Set if Most Significant Bit (MSB) is `1`.
    * **Carry (C)**: Set if operation results in an overflow or a shift-out.

---

## How to test

The design is verified using a comprehensive **testbench** (`tb_Processor_Top`)

* **SIPO Stimulus**: The 12-bit instruction is fed through serial lanes over multiple clock cycles.
* **ALU Verification**: Test cases verify arithmetic accuracy and that flags ($Z, N, C$) update correctly.
* **Crypto Testing**: The `LOAD_SEED` operation initializes the LFSR, followed by `CRYPTO` operations to verify encrypted data output.
