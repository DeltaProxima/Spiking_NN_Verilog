# Spiking Neural Network (SNN) Implementation in Verilog

This project implements a Spiking Neural Network (SNN) system in Verilog with two different arithmetic implementations: **Integer** and **Floating Point**. The system processes pixel values through a Poisson spike encoder and a two-layer neural network using Leaky Integrate-and-Fire (LIF) neurons.

## Table of Contents

- [Overview](#overview)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Components](#components)
- [Implementation Details](#implementation-details)
- [Usage](#usage)
- [Simulation](#simulation)
- [Parameters](#parameters)

## Overview

This SNN implementation processes input pixel values (16-bit) through:
1. **Poisson Spike Generator**: Converts pixel intensity values into stochastic spike trains
2. **Two-Layer Neural Network**: Two LIF neurons connected in series to process spike trains

The project provides two implementations:
- **Integer Implementation**: Uses 16-bit integer arithmetic for faster computation and lower resource usage
- **Floating Point Implementation**: Uses 32-bit IEEE 754 floating point arithmetic for higher precision

## Project Structure

```
Spiking_NN_Verilog/
│
├── Integer Implementation/
│   ├── SNN_system.v              # Top-level system module
│   ├── SNN_system_tb.v            # Testbench for integer implementation
│   ├── leaky_integrate_fire.v     # LIF neuron module
│   └── poisson_spike_generator.v  # Poisson encoder module
│
├── Floating Point Implementation/
│   ├── neuron_system.v            # Top-level system module
│   ├── neuron_system_tb.v         # Testbench for floating point implementation
│   ├── leaky_integrate_fire.v     # LIF neuron module (FP)
│   ├── poisson_spike_generator.v  # Poisson encoder module
│   ├── Addition_Subtraction.v     # FP adder/subtractor
│   ├── comparator.v              # FP comparator
│   └── priority_encoder.v         # Normalization for FP operations
│
├── EE605_Project_Report_Group_3.pdf
└── README.md
```

## Architecture

### System Block Diagram

```
Pixel Value (16-bit)
    │
    ▼
┌─────────────────────────┐
│ Poisson Spike Generator │
│  (LFSR-based encoding)  │
└─────────────────────────┘
    │
    ▼
Spike Train
    │
    ▼
┌─────────────────────────┐
│   LIF Neuron 1          │
│  (Weight, Threshold,    │
│   Leak, Refractory)     │
└─────────────────────────┘
    │
    ▼
Spike Out 1
    │
    ▼
┌─────────────────────────┐
│   LIF Neuron 2          │
│  (Weight, Threshold,    │
│   Leak, Refractory)     │
└─────────────────────────┘
    │
    ▼
Spike Out 2
```

## Components

### 1. Poisson Spike Generator

Converts pixel intensity values into stochastic spike trains using a Linear Feedback Shift Register (LFSR) for random number generation.

**Features:**
- Parameterizable width (default: 16 bits)
- Window size tracking (default: 5 cycles)
- LFSR seed: `0x005A`
- Generates spikes when random number < pixel value

**Ports:**
- `clk`: Clock signal
- `rst`: Reset signal (active low)
- `pixel_value[15:0]`: Input pixel intensity
- `spike_train`: Output spike signal
- `spike_train_array[4:0]`: Window of recent spikes
- `random_number[15:0]`: Current LFSR value

### 2. Leaky Integrate-and-Fire (LIF) Neuron

Implements the LIF neuron model with the following dynamics:

**Neuron Dynamics:**
1. **Integration**: Adds weighted input spikes to membrane potential
2. **Leak**: Subtracts leak value from membrane potential
3. **Fire**: Generates output spike when threshold is exceeded
4. **Refractory Period**: Prevents firing during recovery period

**Ports:**
- `clk`: Clock signal
- `reset_n`: Reset signal (active low)
- `spike_in`: Input spike signal
- `weight`: Synaptic weight (16-bit integer or 32-bit float)
- `threshold`: Firing threshold (16-bit integer or 32-bit float)
- `leak_value`: Leak constant (16-bit integer or 32-bit float)
- `tref[7:0]`: Refractory period duration
- `memb_potential_out`: Current membrane potential
- `spike_out`: Output spike signal
- `tr[7:0]`: Remaining refractory period countdown

**Integer Implementation:**
- Uses simple addition/subtraction operations
- Effective leak: `min(leak_value, voltage)`

**Floating Point Implementation:**
- Uses custom FP adder/subtractor module
- Uses FP comparator for threshold checking
- Includes normalization via priority encoder

### 3. Floating Point Arithmetic Modules

#### Addition_Subtraction.v
- Custom IEEE 754 single-precision (32-bit) FP adder/subtractor
- Handles sign, exponent alignment, and significand operations
- Supports both addition and subtraction modes

#### comparator.v
- FP comparator using subtraction
- Outputs comparison result for threshold checking

#### priority_encoder.v
- Normalizes significand after subtraction
- Adjusts exponent accordingly
- Handles 25-bit significand normalization

## Implementation Details

### Integer Implementation

- **Data Width**: 16 bits
- **Operations**: Direct integer arithmetic
- **Advantages**: 
  - Lower resource usage
  - Faster computation
  - Simpler design
- **Use Case**: Applications where precision can be traded for speed/area

### Floating Point Implementation

- **Data Width**: 32 bits (IEEE 754 single precision)
- **Operations**: Custom FP arithmetic units
- **Advantages**:
  - Higher precision
  - Better dynamic range
  - More biologically accurate
- **Use Case**: Applications requiring high precision or wide dynamic range

## Usage

### Module Instantiation

#### Integer Implementation

```verilog
SNN_system uut (
    .clk(clk),
    .rst(rst),
    .pixel_value(pixel_value),
    .weight1(weight1),
    .weight2(weight2),
    .threshold1(threshold1),
    .threshold2(threshold2),
    .leak_value1(leak_value1),
    .leak_value2(leak_value2),
    .tref1(tref1),
    .tref2(tref2),
    .memb_potential_out1(memb_potential_out1),
    .memb_potential_out2(memb_potential_out2),
    .spike_out1(spike_out1),
    .spike_out2(spike_out2),
    .tr1(tr1),
    .tr2(tr2),
    .spike_train(spike_train),
    .random_number(random_number)
);
```

#### Floating Point Implementation

```verilog
neuron_system uut (
    .clk(clk),
    .rst(rst),
    .pixel_value(pixel_value),
    .weight1(weight1),      // 32-bit float
    .weight2(weight2),      // 32-bit float
    .threshold1(threshold1), // 32-bit float
    .threshold2(threshold2), // 32-bit float
    .leak_value1(leak_value1), // 32-bit float
    .leak_value2(leak_value2), // 32-bit float
    .tref1(tref1),
    .tref2(tref2),
    .memb_potential_out1(memb_potential_out1),
    .memb_potential_out2(memb_potential_out2),
    .spike_out1(spike_out1),
    .spike_out2(spike_out2),
    .tr1(tr1),
    .tr2(tr2),
    .spike_train(spike_train),
    .random_number(random_number)
);
```

## Simulation

### Running Testbenches

#### Integer Implementation

```bash
# Compile and simulate
iverilog -o snn_int_tb Integer\ Implementation/*.v
vvp snn_int_tb
gtkwave dump.vcd
```

#### Floating Point Implementation

```bash
# Compile and simulate
iverilog -o snn_fp_tb Floating\ Point\ Implementation/*.v
vvp snn_fp_tb
gtkwave dump.vcd
```

### Testbench Parameters

#### Integer Implementation Example
- `pixel_value`: 16-bit values (0-65535)
- `weight1`: `0x0003` (3)
- `weight2`: `0x0004` (4)
- `threshold1`: `0x0005` (5)
- `threshold2`: `0x0005` (5)
- `leak_value1`: `1`
- `leak_value2`: `1`
- `tref1`, `tref2`: `1` cycle

#### Floating Point Implementation Example
- `pixel_value`: `20000` (16-bit)
- `weight1`: `0x40800000` (4.0 in FP)
- `threshold1`: `0x41400000` (12.0 in FP)
- `leak_value1`: `0x3e4ccccd` (0.2 in FP)
- `tref1`, `tref2`: `2` cycles

## Parameters

### Poisson Spike Generator Parameters

- `WIDTH`: Data width (default: 16)
- `WINDOW_SIZE`: Spike history window size (default: 5)

### Neuron Parameters

- **Weight**: Synaptic connection strength
- **Threshold**: Membrane potential threshold for firing
- **Leak Value**: Decay constant for membrane potential
- **Refractory Period (tref)**: Recovery time after firing (0-255 cycles)

### Design Considerations

1. **Clock Frequency**: Ensure sufficient setup/hold time for FP operations
2. **Reset**: Active low reset initializes all state variables
3. **Refractory Period**: Prevents neuron from firing immediately after a spike
4. **Leak Mechanism**: Prevents unbounded membrane potential growth

## Applications

This SNN implementation can be used for:
- Image processing and pattern recognition
- Neuromorphic computing research
- Low-power edge AI applications
- Real-time signal processing
- Hardware acceleration of neural networks

## Notes

- The floating point implementation requires all supporting modules (Addition_Subtraction, comparator, priority_encoder) to be included during compilation
- Both implementations use the same Poisson spike generator logic
- The system processes one pixel value at a time
- Membrane potential and spike outputs are available for monitoring

## References

For detailed project documentation, see: `EE605_Project_Report_Group_3.pdf`

---

**Project**: EE605 Group 3  
**Date**: April 2024  
**Language**: Verilog  
**Target**: FPGA/ASIC Implementation

