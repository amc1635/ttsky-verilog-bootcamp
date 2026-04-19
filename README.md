# 🔒 TinyCrypto-8: An 8-Bit Pipelined ALU with Hardware Encyption

**TinyCrypto-8** is a custom, lightweight 8-bit processor designed specifically for the [Tiny Tapeout](https://tinytapeout.com/) ASIC fabrication process. It features a fully custom 2-stage pipelined architecture, an integrated ALU, and a dedicated hardware cryptographic engine (LFSR) optimized for ultra-low area constraints.

## 🌟 Overview
Traditional microprocessors require large amounts of physical silicon for data memory and instruction decoding. To fit within a constrained Tiny Tapeout tile, this processor utilizes an **Accumulator-based datapath** supplemented by a single 8-bit **Scratchpad** register. 

Its defining feature is the integrated **Hardware Stream Cipher**. By executing the `CRYPTO` instruction, the processor leverages an 8-bit Linear Feedback Shift Register (LFSR) to perform single-cycle pseudo-random masking (XOR), making it ideal for lightweight IoT sensor encryption.

## 🏗️ Architecture

The chip is physically divided into two main pipeline stages separated by a wall of pipeline registers (`ex_opcode` and `ex_operand`), allowing instruction overlap and higher clock speeds.

```mermaid
graph LR
    subgraph IF [Fetch Stage]
        direction TB
        SIPO[SIPO Loader] -->|12-bit| IMEM[(10-Slot Mem)]
        PC[PC] --> IMEM
    end
    PIPE[IF/EX Pipeline Reg]
    subgraph EX [Execute Stage]
        direction TB
        ALU[ALU + LFSR] <--> ACC[Accumulator]
        ACC <--> SPAD[(Scratchpad)]
    end
    IMEM --> PIPE --> ALU
    ACC --> PINS((Output Pins))
