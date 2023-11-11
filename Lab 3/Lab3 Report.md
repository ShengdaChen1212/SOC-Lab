# Lab3 Report

## Function specification:
* **y[t] = Σ (h[i] * x[t - i])**

## Design specification
* Data_Width : 32
* Tape_Num : 11
* Data_Num : To be determined by data size
* Interface
    * **data_in** : *stream* （Xn）
    * **data_out** : *stream* ( Yn)
    * **coef [Tape_Num-1:0]** : *axilite*
    * **len** : *axilite*
    * **ap_start** : *axilite*
    * **ap_done** : *axilite*
* Using one Multiplier and one Adder
* Shift register implemented with SRAM (Shift_RAM, size = 10 DW) – size = 10 DW
* Tap coefficient implemented with SRAM (Tap_RAM = 11 DW) and initialized by axilite write
* Operation
    * ap_start to initiate FIR engine (ap_start valid for one clock cycle)
    * Stream-in Xn. The rate is depending on the FIR processing speed. Use axi-stream valid/ready for flow control
    * Stream out Yn, the output rate depends on FIR processing speed.

### AXI4-Lite Read Transaction
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/d9192231-bc6e-4955-9019-3cfd4fe031de)

### AXI4-Lite Write Transaction
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/b3a5e18c-8740-4460-9e45-69be8cf0c309)

### AXI4-Stream Transfer Protocol
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/1db95a32-c5a5-4695-95b0-11a1108e88f1)

### Configuration Register Address map
**Address**
* 0x00 
    * **bit 0 - ap_start** (r/w)
    set when ap_start signal assert reset, when start data transfer, i.e. 1st axi-stream data come in
    * **bit 1 – ap_done (ro)** -> 
    when FIR process all the dataset, i.e. receive tlast, and last Y is generated and transferred
    * **bit 2 – ap_idle (ro**) -> 
    indicate FIR is actively processing data
* 0x10-14 - data-length
* 0x20-FF – Tap parameters, (e.g., 0x20-23 Tap0, in sequence...)

### Host software / Testbench Programming Sequence
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/bb0533e1-d512-406a-bd84-d9b2001f09a1)

## Block Diagram
### Datapath :
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/8979d438-cc42-46ab-9d19-c32e8a514eb9)

### Waveform :
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/6b508fb0-4fac-4ba2-9992-d897558a9f08)

## Simulation
### Write Transaction
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/c6ef13e7-6025-4451-9b08-ee9ee324429e)

### Read Transaction
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/9b2378a2-5a97-4d39-9b76-443bc5198c32)

### Calculation
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/ded3ecb4-7267-43cc-810f-8ad8375230a4)

### Last Data
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/e16838b9-a9d8-4ab8-99ad-8b322562b915)

## Synthesis
### Slice logic
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/2d5c53f0-a212-4bb9-b7b9-e270307553d0)

### Bram
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/eefe8a85-3815-4f9f-aad5-23bf8ae1137f)

### DSP
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/404dc7d9-9a3f-4ec3-88ae-b144e4ba479f)

## Timing Report
![image](https://github.com/ShengdaChen1212/SOC-Lab/assets/97797875/e0450f33-9c3c-4f70-a7cd-4529743f54b6)
