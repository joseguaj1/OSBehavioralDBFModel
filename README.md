Refer to the related paper: https://arxiv.org/pdf/2501.07584

# Model Overview, Variable Names, and Definitions

## Model Overview
The proposed behavioral model simulates an end-to-end digital beamforming communication system. Each user independently transmits a random QAM signal over an ideal free-space line-of-sight channel. The M-element base station receives the signals in the far-field at each antenna element, quantizes each channel independently, and performs beamforming in the digital domain. The beamforming operation, being fully digital, outputs a stream of data for each user.

Each of the output data streams is independently processed by the measurement sub-block to determine **BER**, **EVM**, and **ENOB**. These measurements are then used to estimate **ENOB**, **$SIR_{min}$**, and the **Array Gain**.
<img width="1029" alt="ChModeling1_SimpleBlockDiagramMeasurement" src="https://github.com/user-attachments/assets/ed275d58-db14-4255-ada3-f80dce79488b" />
Figure 1: Overview of the Digital Beamforming Behavioral Model Implemented in MATLAB

## Tunable Model Variables (Sweep Variables)
- **M**: Number of receive (base station) elements.
- **K**: Number of transmitters (users or interferers), each modeled as a single element. In a system with an interferer, there are \(K-1\) users of interest and one interferer.
- **B**: Analog-to-digital converter (ADC) resolution.
- **$SNR_{therm}$**: Signal-to-thermal-noise ratio (in dB), defined at the output of the LNA.
- **SIR**: Signal-to-interferer ratio (in dB). In a system with K users, there are \(K-1\) users transmitting at a nominal power level and one interfering user transmitting at a power level commensurate with the SIR.
- **Angle**: Blocker or user angle sweep (in degrees). Dependent on the boolean variables SweepUserAngle and SweepBlockerAngle.

## Boolean Model Variables
- **LogScaleX, LogScaleY, LogScaleZ**: Determines the plot axes scale. If false, axes default to a linear scale.
- **EnableBlocker**: If true, one out of the K transmitting elements transmits at higher power depending on SIR. Must be enabled to sweep the interferer angle.
- **SweepUserAngle, SweepBlockerAngle**: Determines whether the desired angle sweep will sweep the user angle spacing or the interferer angle. If both are selected, the model will sweep the interferer angle only.
- **$ZF_{on}$**: If true, implements zero-forcing beamforming. If false, implements conjugate beamforming. Note: Zero-forcing requires $M \geq K$ and sufficient user separation. A rule of thumb is that the user angular spacing must be greater than $\frac{\pi}{M}$ radians.
- **addThermNoise**: If false, thermal noise is not added at the receiver.

## Model Outputs for Plotting
- **BER**: Bit-error-rate. Defined as the ratio of the number of bits received incorrectly to the total number of bits transmitted during a specific period.
- **EVM**: Error-vector magnitude. A measure of the difference between the ideal and actual received signal constellation points, expressed as an RMS percentage.
- **SNDR**: Signal-to-noise-and-distortion ratio (in dB). Measures the quality of a signal in the presence of both noise and distortion.
- **ENOB**: Effective number of bits. Represents the number of bits an ADC uses to quantize the signal of interest, excluding noise and distortion, and can be directly calculated from an SNDR measurement.
- **$SIR_{min}$**: Minimum signal-to-interferer ratio (in dB) that a particular beamforming system can handle. Above this minimum, the strength of the interferer degrades system performance.
- **Array Gain**: The ratio between the measured SNDR at the array output and the individual array channel. In an ideal phased array, the array gain is $10 \cdot \log_{10}(M)$.


# Usage Instructions and Software Requirements

## GUI & Usage Instructions
<img width="945" alt="ChModeling3_GUI" src="https://github.com/user-attachments/assets/62448cd8-6976-4465-8e8c-71a3f7703d70" />  
Figure 2: GUI to Interact with Behavioral Model  


Fig. 2 shows the GUI. There are several key parts of the GUI to note.  
<img width="747" alt="ChModeling3_GUI_Dropdowns" src="https://github.com/user-attachments/assets/5ca7963a-8fc5-47a1-b6e7-71a9c2966948" />  

Figure 3: GUI Dropdown Menus for a) Presets b) Outputs c) Sweepable variables  
### Presets and Outputs


The presets dropdown menu is shown in Fig. 3a) and can be used to replicate any of the results presented in the paper. Additionally, the plot output dropdown menu can be used to select the output of interest, as shown in Fig. 3b). 

### Sweepable Variables

Fig. 3c) shows the dropdown menu listing the variables that can be swept. Note that up to three variables can be swept and the output plot will match the necessary number of dimensions. Note that the 'Multiple Curves' checkboxes may be used to determine whether a second or third sweep variable will appear as a plot axis or as a set of curves. Additionally, when a sweep variable is selected, the user will be able to input the start, end and step values for that variable. If the variable is not being swept, it takes the default value from the box labeled 'Value'. 
    
### Boolean Variables

There are two sets of boolean variables that can be changed with the GUI. Firstly, the LogScale variables found on the left side of the GUI can be enabled in order to plot certain axes with a logarithmic scale. This is useful, for example, when plotting bit-error rates. There is a second set of boolean variables, labeled System Parameters, on the right side of the GUI that can also be enabled or disabled as needed.

### Additional Variables

The last few variables are QAMNumSymbols, UserAngleSpacing and BlockerAngle. When neither SweepUserAngle nor SweepBlockerAngle (on the top right side of the GUI) are selected, UserAngleSpacing and BlockerAngle will take their default values from the input text boxes. However, when one of SweepUserAngle or SweepBlockerAngle are enabled, the corresponding angle will be swept according to the Angle start, step and stop values. QAMNumSymbols is the number of QAM symbols. Note that the only supported modulation scheme is 16-QAM. 

### User Placement
Most of the tunable parameters are straightforward. However, there are two tuning parameters that must be tuned carefully:

- BlockerAngle
- UserAngleSpacing

BlockerAngle and UserAngleSpacing must be chosen carefully to ensure that the users are placed as desired. Fig. 4 shows how the model places users depending on BlockerAngle and UserAngleSpacing. For the user placements shown in Fig. 4, **BlockerAngle = 78.5°** and **UserAngleSpacing = 22.5°**. We note that users are always placed around but not at zero degrees (broadside). Fig. 4a) shows that for a single user, **θ₁ = -UserAngleSpacing/2**. As the number of users increases, each one is placed an angular distance of UserAngleSpacing apart from the first user. Note the order in which users are placed in the figure. Fig. 4b) shows the arrangement when **K = 8**. Lastly, Fig. 4c) shows the arrangement when **K = 4** and the interferer, shown in red, is enabled. The interferer, when enabled, is always placed at the angle corresponding to BlockerAngle.

<img width="674" alt="ChModeling3_UserPlacement" src="https://github.com/user-attachments/assets/8ee48eae-11a5-4403-9073-79dd64620432" />  

Figure 4: User Placement when $BlockerAngle = 78.5^{\circ}$ and $UserAngleSpacing = 22.5^{\circ}$ for: a) $M = 1$  b) $M = 8$ c) $M = 4$ with Blocker Enabled  


## Software Requirements - MATLAB Toolboxes:
As of writing, the model is used on MATLAB version R2024b. The model requires the following MATLAB Toolboxes to be installed:

- MATLAB R2024b
- Signal Processing Toolbox
- Communications Toolbox
- Curve Fitting Toolbox



