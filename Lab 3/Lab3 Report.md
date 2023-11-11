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
![image.png](https://hackmd.io/_uploads/SkzEgEG7a.png)

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
![image.png](https://hackmd.io/_uploads/S1U0ZNzXa.png)

## Block Diagram
### Datapath :
![image](https://hackmd.io/_uploads/HkQDyMTX6.png)

### Waveform :
![image](https://hackmd.io/_uploads/r1hKkfpQT.png)

## Simulation
### Write Transaction
![image](https://hackmd.io/_uploads/Sk-UmGTQ6.png)

### Read Transaction
![image](https://hackmd.io/_uploads/SybPXGpXa.png)

### Calculation
![image](https://hackmd.io/_uploads/S194VM6Xp.png)

### Last Data
![image](https://hackmd.io/_uploads/Sy0ZBG67T.png)

## Synthesis
### Slice logic
![image](https://hackmd.io/_uploads/S1fU8z6mT.png)

### Bram
![image](https://hackmd.io/_uploads/SysaLfama.png)

### DSP
![image](https://hackmd.io/_uploads/ry5JwGTQT.png)

## Timing Report
![image](https://hackmd.io/_uploads/r1kk8f67p.png)
