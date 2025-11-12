# Emotion Detection from EEG  
This project compiles a series of steps to follow to achieve the training of a neural network capable of predicting 4 emotions from EEG signals.

------------------------------------------------------------------------
The neural network at issue was trainned using the DEAP EEG dataset (https://www.eecs.qmul.ac.uk/mmv/datasets/deap/index.html), and selecting the corresponding windows for each one of the 32 participants. The original DEAP EEG data is not included in this repo, since redistribution is not allowed. Here I'm only adding my files for future reference/inspo.

------------------------------------------------------------------------
For the trained neural network, follow the next file order:

    1. Step1_Preprocessing.m
    2. Step2_OverlappingWindows.m
    3. Step3_NeuralNetwork.m

Pretty self explainatory, huh?

------------------------------------------------------------------------
Wanna test the neural network? Run EmotionRecognitionEEG.m 

Watch out, you may also need liblsl-Matlab (https://github.com/labstreaminglayer/liblsl-Matlab)

------------------------------------------------------------------------
Additional files included:
- **Aura2eeglab.m:** A custom function to convert a .csv file generated when recording from the Aura software, to the standard EEGLAB EEG struct format.
- **AuraRT_vis.m:** A cool script to showcase how awesome I am by recording EEG data from the LSL stream, fixing it (if its a pre-recorded file), and cleaning it.
- **ReceivingEmotion.py:** A python script to start a TCP/IP server where the emotion label is sent from 'EmotionRecognitionEEG.m'.
- **Steps_(deprecated).m:** Some not so cool files, but useful to check out in case someone wants to write code as cool as mine.
- **clean_recorded.m:** I don't remember what this is.
- **dcaro_aura_fix.m:** A custom function that cleans EEG data using [...] just check it out.
- **dcaro_tcp.m:** Hardest code in this repo btw. That's me testing a tcp server in MATLAB.
- **trainingPartitions.m:** Not my code, found it somewhere I don't remember, but used to split data for training/testing/validation.
- **failed tests/:** More not so cool code but just to throw it out there.
- **metadata/:** Some files needed for 'Step1_Preprocessing.m'. This is actually from the DEAP dataset I hope they don't find out and sue me.
------------------------------------------------------------------------
At some point, any of my codes may use dcaro_stacked.m (https://www.mathworks.com/matlabcentral/fileexchange/180339-dcaro_stacked/?s_tid=mlc_lp_leaf) so there's the link. 

------------------------------------------------------------------------
For any additional query/guidance, feel free to reach out to me at: dgcarolp@hotmail.com or A00833057@exatec.tec.mx

[...]
or if you prefer there's ChatGPT (https://chatgpt.com/) 

------------------------------------------------------------------------
by: Diego Caro López, Mirai Innovation Research Institute, EMFUTECH Fall 2025, Osaka, Japan. 13-Nov-2025.


