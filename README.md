# Photovoltaic-Grid-Connected-System-Simulation
A complete simulation of a photovoltaic grid-connected system in MATLAB/Simulink, demonstrating real-world engineering practices for renewable energy integration.

---

## 🎯 Project Overview

This project simulates the entire energy conversion chain from solar panels to grid connection:
☀️ PV Array → 🔌 MPPT → ⚡ Inverter → 🔄 Transformer → 🏭 Grid (400V/50Hz)

### Key Features
- ✅ **Calibrated PV Model** - 0.11% error vs. datasheet (Jinko Solar 250W)
- ✅ **MPPT Algorithm** - 99.45% tracking efficiency under varying irradiance
- ✅ **3-Phase Inverter** - Average-value model with transformer isolation
- ✅ **Grid Compliance** - THD: 3.145% (IEEE 519 limit: 5%)

---

## 📊 Results Summary

| Parameter | Value | Standard |
|-----------|-------|----------|
| System Power | 3.25 kW | - |
| DC Bus | 400 V | ✅ |
| AC Output | 400 V (3-phase) | Turkish Grid ✅ |
| Frequency | 50 Hz | ✅ |
| MPPT Efficiency | 99.45% | >95% ✅ |
| THD | 3.145% | <5% (IEEE 519) ✅ |

---

## 🛠️ Technical Stack

- **Platform**: MATLAB R2025b
- **Toolboxes**: 
  - Simulink
  - Simscape Electrical
  - Optimization Toolbox
  - Signal Processing Toolbox

---

## 📈 Module Breakdown

### Module 1: PV Panel Model
- 5-parameter physics-based model
- Automated calibration using `fmincon`
- I-V and P-V characteristic curves

<img width="856" height="557" alt="image" src="https://github.com/user-attachments/assets/c2413bf0-3d07-4d13-b477-a235f980330b" />


### Module 2: MPPT Controller
- Perturb & Observe algorithm
- Dynamic irradiance response
- 99.45% tracking efficiency

<img width="869" height="547" alt="image" src="https://github.com/user-attachments/assets/fc28af88-1f6e-4dcd-85b0-120242e5ae4f" />


### Module 3: Series Configuration
- 13 × 250W panels in series
- 397.8V DC bus output

### Module 4: Three-Phase Inverter
- Average-value inverter model
- 400V DC → 311V AC conversion

<img width="1280" height="551" alt="image" src="https://github.com/user-attachments/assets/fdbbb016-fc27-4c22-a6bb-06c18233d2e1" />


### Module 5: Step-Up Transformer
- 311V → 400V transformation
- Galvanic isolation
- Yn/Yn configuration


### Module 6: THD Analysis
- FFT-based harmonic analysis
- Hanning windowing for spectral leakage reduction
- IEEE 519 compliance verification


---

## 🚀 Getting Started

### Prerequisites
```matlab
MATLAB R2025b or later
Required toolboxes: Simulink, Simscape Electrical, Optimization
```

### Running the Simulation
```matlab
1. Open MATLAB
2. Navigate to project directory
3. Run: PV_model.m        % Module 1
4. Run: MPPT_PO.m         % Module 2
5. Run: Seri_Panel.m      % Module 3
6. Open: Inverter_Model.slx  % Modules 4-5
7. Run: THD_Analiz.m      % Module 6
```

---

## 📚 Engineering Insights

### Why 13 Panels in Series?
Real-world grid-tied PV systems avoid boost converters by configuring panels to match inverter DC bus requirements directly:

13 × 30.6V = 397.8V ≈ 400V DC bus

### THD Optimization
Initial THD was high due to:
- Low FFT resolution (short simulation time)
- Spectral leakage

Solution:
- Extended simulation to 0.5s (2512 samples)
- Applied Hanning window
- Result: 3.145% THD ✅

---

## 🎓 Learning Outcomes

- System-level renewable energy design
- Control algorithm implementation (MPPT)
- Power electronics modeling
- Grid code compliance (IEEE 519)
- Multi-toolbox MATLAB workflow

---

## 📄 License

MIT License - Feel free to use for educational purposes

---

## 👤 Author

Bilgehan HOP
Electrical & Electronics Engineering Student
Sakarya Üniversitesi

**Project Duration**: 28/04/2026 - 30/04/2026

---

## 🙏 Acknowledgments

- Jinko Solar for panel specifications
- IEEE 519 standard for THD guidelines
- MathWorks documentation
