# All-Digital-Phase-Locked-Loops

This repository contains Verilog implementations of fully digital Phase-Locked Loops (ADPLLs) with both integer-N and fractional-N architectures. The project includes innovative approaches such as **MASH 1-1 integration** in fractional-N ADPLL and **PNCP (Programmable Numerically Controlled Charge Pump)** in integer-N ADPLL.

---

## Project Folders and Files

- `All-Digital-Phase-Locked-Loops/` - Main folder with verilog files and .txt-files to tests
- `ADPLLs_TESTs/` — Python scripts for output frequency analysis and visualization
- `Matlab_models/` — MATLAB models for second-order loop analysis and ADPLL behavioral modeling
- `work/` and `files "vsim.wlf", "ADPLL.cr.mti", "ADPLL.mpf"` - project system files

---

## ADPLL Architectures

### 1. Fractional-N ADPLL with DCO and MASH 1-1

**Top Module:** `Frac_N_ADPLL_DCO`

**Block Diagram:**
<p align="center">
  <img width="1280" height="620" alt="image" src="https://github.com/user-attachments/assets/1f2da254-e2c0-4805-978a-48051daa4c04" />
  <br/>
  <em>Figure 1.</em>
</p>

**Fractional Control:**
The fractional part is set via `FRAC_bits[1:0]`, allowing fractional steps of 0.0, 0.25, 0.5, and 0.75. The MASH 1-1 modulator converts these fractional bits into a 3-level output (`-1, 0, +1, +2`), which is added to the integer multiplier (`MUL_VAL`). The MASH 1-1 provides second-order noise shaping, pushing quantization noise away from the carrier. 

**Frequency Range:** 300–500 MHz (DCO based on DCO_main_mux architecture)

**Applications:**
- High-resolution frequency synthesis
- Communication systems requiring fine frequency steps
- All-digital PLLs with fractional division capability

---

### 2. Integer-N ADPLL with NCO and PNCP

**Top Module:** `Int_N_ADPLL_NCO_PNCP`

**Block Diagram:**
<p align="center">
  <img width="1280" height="416" alt="image" src="https://github.com/user-attachments/assets/0c8cde68-a22b-46cb-a89b-904345c1c4e3" />
  <br/>
  <em>Figure 2.</em>
</p>

PNCP (Programmable Numerically Controlled Charge Pump)** — A novel block that replaces the classical Phase-Controlled Pump (PCP) or TDC in integer-N ADPLLs.

**Reference Clock:** 4 MHz (from REF_rsvd)
**NCO Clock:** 1 GHz (from external CLK input)

**Applications:**
- High-frequency clock generation
- Digital frequency synthesis without analog components
- Systems requiring quick frequency locking and high stability

---

## Key Components

### Digital Loop Filters

#### `LF (Loop PI-filter)`
- Proportional term: `LF_in * 6`
- Integral term: `LF_in >> 5`

### TDC (Time-to-Digital Converter)
- Measures phase difference between UP and DOWN signals
- Provides signed 16-bit output with +/- 1 error correction
- Output valid signal for loop filter update

### PNCP (Programmable Numerically Controlled Charge Pump)
- Digital replacement for analog charge pump
- Direct conversion of PFD output to signed digital value
- Scalable via CODE input (multiplier value)

### FREQ_DIV (Programmable Frequency Divider)
- Down-counter architecture for dynamic division ratio
- Supports signed division values (for MASH compatibility)

### DCO (Digitally Controlled Oscillator)
- Based on DCO_main_mux architecture
- 8-stage distributed multiplexer structure
- Frequency range: 294–523 MHz (depending on code) to MASH

### NCO (Numerically Controlled Oscillator)
- Fully digital frequency synthesizer
- 17-bit phase accumulator
- Output frequency: `f_out = (FCW * f_clk) / 2^17`

---

## Testbenches

### `Frac_N_ADPLL_DCO_tb`
Tests the fractional-N ADPLL with DCO:
- Generates output frequency log (`Frac_N_ADPLL_DCO_freq_log.txt`)
- DCO output frequency measurement every reference clock cycle (10 MHz)

### `Int_N_ADPLL_NCO_PNCP_tb`
Tests the integer-N ADPLL with NCO and PNCP:
- Generates output frequency log (`Int_N_ADPLL_NCO_PNCP_freq_log.txt`)
- Measures NCO output frequency every reference cycle (4 MHz)

---

## Python Analysis (`ADPLLs_TESTs`)

The `ADPLLs_TESTs` folder contains Python scripts for analyzing ADPLL output frequency logs:

### Features:
- Loads frequency log files (TXT format)
- Visualizes original and smoothed frequency plots

---

## MATLAB Models

### `link_of_the_2_order.m`

This script models an elementary second-order PLL control loop, providing a foundation for understanding the fundamental dynamics of phase-locked loops and optimizing loop filter parameters.

### `pll_model_2016a.m`

This script implements a complete behavioral model of the integer-N ADPLL with NCO and NCP, replicating the digital functionality of the Verilog implementation at the system level.



