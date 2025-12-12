# Memory System - Five-Stage RISC Processor

## Overview
This directory contains the shared memory system that serves all pipeline stages. The memory is **independent** and does not belong to any specific pipeline stage.

## Architecture

### Harvard Architecture with Unified Memory
Although conceptually a Harvard architecture (separate instruction and data paths), the implementation uses a single physical memory with:
- Separate interfaces for instruction fetch and data access
- Priority-based arbitration for memory access
- Independent read/write paths for different stages

## Components

### 1. Shared_Memory.vhd
The actual memory storage array.
- **Size**: Configurable (default 1024 words)
- **Width**: 32-bit words
- **Operations**: Read and Write
- **Timing**: Synchronous (single clock cycle access)

### 2. Memory_Interface.vhd
Memory access controller that arbitrates between different requesters.

**Interfaces**:
- **Fetch Interface**: For instruction fetch from PC
- **Memory Stage Interface**: For load/store operations

**Arbitration Policy**:
- Memory stage has priority when `mem_stage_priority` is asserted
- Fetch stage accesses memory during normal operation
- Prevents conflicts between instruction fetch and data access

### 3. Memory_System.vhd
Top-level integration of shared memory and interface controller.

**Inputs**:
- Fetch stage: address and read enable
- Memory stage: address, write data, write/read enables
- Priority control signal

**Outputs**:
- Fetch stage: instruction data
- Memory stage: load data

## Connections to Pipeline Stages

### Fetch Stage Connection
```
Fetch Stage → Memory System
  - fetch_address (from PC)
  - fetch_read_enable (always '1')
  
Memory System → Fetch Stage
  - fetch_read_data (instruction)
```

### Memory Stage Connection
```
Memory Stage → Memory System
  - mem_address (from ALU result)
  - mem_write_data (store data)
  - mem_write_enable (control signal)
  - mem_read_enable (control signal)
  
Memory System → Memory Stage
  - mem_read_data (load data)
```

## Memory Access Priority

### Normal Operation
1. **Fetch Stage**: Continuously reads instructions
2. **Memory Stage**: Accesses memory when needed (load/store)

### Priority Handling
- When memory stage needs access → `mem_stage_priority = '1'`
- Memory stage access takes precedence
- Fetch stage may stall if needed

### Conflict Resolution
The memory interface ensures:
- No simultaneous access conflicts
- Proper data routing to requesting stage
- Registered outputs for timing closure

## Usage

### Instantiation in Top-Level Design
```vhdl
Memory_Sys: Memory_System
    generic map (
        ADDR_WIDTH => 32,
        DATA_WIDTH => 32,
        MEM_SIZE => 1024
    )
    port map (
        clk => clk,
        rst => rst,
        
        -- Fetch interface
        fetch_address => fetch_addr,
        fetch_read_enable => fetch_rd,
        fetch_read_data => fetch_data,
        
        -- Memory stage interface
        mem_address => mem_addr,
        mem_write_data => mem_wr_data,
        mem_write_enable => mem_wr_en,
        mem_read_enable => mem_rd_en,
        mem_read_data => mem_rd_data,
        
        -- Control
        mem_stage_priority => mem_priority
    );
```

## Design Benefits

1. **Modularity**: Memory is separate from pipeline stages
2. **Flexibility**: Easy to replace with different memory implementations
3. **Scalability**: Can add more interfaces (e.g., DMA, cache)
4. **Clarity**: Clear separation of concerns
5. **Testability**: Memory can be tested independently

## Performance Considerations

### Single-Port Memory Limitation
- Only one access per cycle
- May cause pipeline stalls if both fetch and memory stage need access

### Future Enhancements
- Dual-port memory for simultaneous access
- Cache hierarchy (I-Cache and D-Cache)
- Memory management unit (MMU)
- Burst access support

## Memory Initialization

Memory can be initialized with program code:
- Modify the reset logic in `Shared_Memory.vhd`
- Load from file during simulation
- Use configuration memory in FPGA synthesis

## Address Space

Default configuration:
- **Address Width**: 32 bits (full address space)
- **Physical Memory**: 1024 words (10-bit addressing used)
- **Upper bits**: Ignored in current implementation
- **Byte Addressing**: Not implemented (word-aligned only)

## Testing

See `Memory_System_tb.vhd` for comprehensive testbench covering:
- Fetch-only access
- Memory stage access
- Priority arbitration
- Simultaneous access handling
