# Canny Edge Detection Algorithm Implementation in SystemC

## Overview
This repository contains an optimized implementation of the Canny Edge Detection algorithm using SystemC. The implementation demonstrates the power of hardware-software co-design in image processing applications, leveraging SystemC's capabilities for system-level modeling and simulation.

## Why SystemC?
SystemC was chosen for this implementation for several key reasons:
- **Hardware-Software Co-Design**: SystemC allows modeling of both hardware and software components in a unified environment
- **System-Level Modeling**: Enables high-level system architecture design before detailed RTL implementation
- **Performance Analysis**: Built-in simulation capabilities help analyze system performance and bottlenecks
- **Parallel Processing**: SystemC's concurrent execution model matches well with the parallel nature of image processing
- **Industry Standard**: Widely used in embedded systems design and verification

## SystemC Architecture

```
+----------------+     +-----------------+
|   Stimulus     |     | - Read PGM     |
|   Module       +---->| - Image Input  |
+-------+--------+     | - Start Time   |
        |             +-----------------+
        v
+----------------+     +-----------------+
|   Gaussian     |     | - σ = 0.6      |
|   Kernel       +---->| - 1D Kernel    |
+-------+--------+     | - Size: 21     |
        |             +-----------------+
        v
+----------------+     +-----------------+
|    BlurX       |     | - Parallel     |
|    BlurY       +---->| - 4 Slices     |
+-------+--------+     | - Convolution  |
        |             +-----------------+
        v
+----------------+     +-----------------+
|   Magnitude    |     | - Sobel X,Y    |
|   Direction    +---->| - Delta X,Y    |
+-------+--------+     | - Angle Calc   |
        |             +-----------------+
        v
+----------------+     +-----------------+
| Non-Maximum    |     | - Tlow: 0.3    |
| Suppression    +---->| - Thigh: 0.8   |
+-------+--------+     | - 8-Direction  |
        |             +-----------------+
        v
+----------------+     +-----------------+
|   DataOut      |     | - Write PGM    |
|   Module       +---->| - Edge Image   |
+----------------+     +-----------------+

Key Parameters:
- Image Size: 2704 x 1520
- Window Size: 21 (Gaussian)
- Sigma: 0.6
- Thresholds: Low=0.3, High=0.8
```

## Detailed Stage Implementation

### 1. Gaussian Smoothing Stage
- **Purpose**: Reduces image noise and unwanted details
- **Implementation**:
  - Uses a 5x5 Gaussian kernel
  - Implemented as a SystemC module with input/output ports
  - Parallel processing of pixel neighborhoods
  - Optimized convolution operations
```cpp
// Gaussian kernel values (σ = 1.4)
const double gaussian_kernel[5][5] = {
    {2.0/159, 4.0/159, 5.0/159, 4.0/159, 2.0/159},
    {4.0/159, 9.0/159, 12.0/159, 9.0/159, 4.0/159},
    {5.0/159, 12.0/159, 15.0/159, 12.0/159, 5.0/159},
    {4.0/159, 9.0/159, 12.0/159, 9.0/159, 4.0/159},
    {2.0/159, 4.0/159, 5.0/159, 4.0/159, 2.0/159}
};
```

### 2. Gradient Calculation Stage
- **Purpose**: Detects intensity changes in x and y directions
- **Implementation**:
  - Sobel operator for gradient computation
  - Concurrent calculation of magnitude and direction
  - Optimized using look-up tables for angle calculation
```cpp
// Sobel operators
const int sobel_x[3][3] = {{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}};
const int sobel_y[3][3] = {{-1, -2, -1}, {0, 0, 0}, {1, 2, 1}};
```

### 3. Non-Maximum Suppression Stage
- **Purpose**: Thins edges by suppressing non-maximum pixels
- **Implementation**:
  - Direction-based comparison
  - Parallel processing of edge pixels
  - Optimized memory access patterns
- **Key Features**:
  - 8-direction quantization
  - Local maximum preservation
  - Edge continuity maintenance

### 4. Double Threshold and Hysteresis Stage
- **Purpose**: Identifies and connects strong and weak edges
- **Implementation**:
  - Dual-threshold classification
  - Recursive edge tracking
  - Parallel processing of edge segments
- **Parameters**:
  - High threshold: 0.7 * max_gradient
  - Low threshold: 0.3 * max_gradient

## SystemC Implementation Details

### Module Structure
```cpp
SC_MODULE(CannyEdgeDetector) {
    sc_in<bool> clk;
    sc_in<bool> rst;
    sc_in<sc_uint<8>> pixel_in;
    sc_out<sc_uint<8>> pixel_out;
    
    // Internal signals
    sc_signal<sc_uint<8>> gaussian_out;
    sc_signal<sc_uint<8>> gradient_out;
    sc_signal<sc_uint<8>> suppression_out;
    
    // Sub-modules
    GaussianFilter* gaussian_filter;
    GradientCalculator* gradient_calc;
    NonMaxSuppression* non_max_supp;
    DoubleThreshold* double_threshold;
    
    // Constructor and process definitions
    SC_CTOR(CannyEdgeDetector) {
        // Module instantiation and signal binding
        // Process registration
        SC_METHOD(process);
        sensitive << clk.pos();
    }
};
```

### Parallel Processing
- Multiple processing elements for each stage
- Pipelined architecture for continuous processing
- Efficient data transfer between stages

### Memory Management
- Double buffering for efficient data access
- Local cache for frequently accessed data
- Optimized memory layout for spatial locality

## Performance Optimizations
1. **Algorithmic Optimizations**:
   - Look-up tables for trigonometric calculations
   - Optimized convolution operations
   - Efficient edge tracking algorithms

2. **SystemC-Specific Optimizations**:
   - Efficient process synchronization
   - Optimized port bindings
   - Memory-mapped I/O for faster data transfer

3. **Platform-Specific Optimizations**:
   - SIMD instructions utilization
   - Cache-aware data structures
   - Thread-level parallelism

## Building and Running

### Prerequisites
- SystemC 2.3.3 or later
- C++ compiler with C++14 support
- Make build system
- OpenCV library (for image I/O)

### Standard Build
```bash
make
```

### Raspberry Pi Build
```bash
make -f Makefile.pi
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is open source and available under the MIT License.

## Contact
For any questions or suggestions, please open an issue in the GitHub repository.

## Acknowledgments
- ECPS 203 - Embedded Systems Modeling and Design
- Original Canny Edge Detection paper by John F. Canny
- SystemC community and documentation
