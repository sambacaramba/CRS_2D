# CRS_2D
Cartilage Roughness Score. Surface roughness analysis tool for histological samples of cartilage.

Used scripts from other sources: 
Einar Ueland (2024). Astar-Algorithm (https://github.com/EinarUeland/Astar-Algorithm), GitHub. Retrieved September 27, 2024.

Douglas Schwarz (2024). uipickfiles: uigetfile on steroids (https://www.mathworks.com/matlabcentral/fileexchange/10867-uipickfiles-uigetfile-on-steroids), MATLAB Central File Exchange. Retrieved September 30, 2024.

- Settings in this example: 
  - moving window size = 28µm (increase to catch larger defects, decrease to catch more minor defects)
  - Pixel size = 0.2515µm/pixel
  
## Running the algorithm for several samples: 
    First, fine-tune the Otsu threshold for each sample using SetThresholdsAndArtefactMasks.m.
    Figure 1 shows a typical example.
    Start with the basic Otsu threshold, then adjust the slider until the cartilage surface appears continuous
    and separated from the background. Click "Finalize" to save the threshold and proceed to the next sample.

    If artefacts need masking, check the box labeled "Add artefact mask after threshold." A new window will open,
    allowing you to place rectangles over artefacts using the "Add ROI" button. Click "Done" to continue.
    Masked areas will be excluded from the final analysis.
![exampleusage](https://github.com/user-attachments/assets/18a4f2f9-df63-4bba-bc05-da4e5f6dfa58)
*Figure 1: Example usage of thresholding and artefact masking

## Healthy Cartilage Sample
![Healthy](https://github.com/user-attachments/assets/77c4e7ec-97e1-4cfe-8bb4-1166365b1439)
*Figure 2: Healthy cartilage surface.*

## Osteoarthritis Cartilage Sample
![Osteoarthritis](https://github.com/user-attachments/assets/a38e09c7-cde9-4398-8f99-4d583eb587fa)
*Figure 3: Osteoarthritis-affected cartilage surface.*

## Video Demonstration
https://github.com/user-attachments/assets/4c24f8ef-3191-40d2-beb0-8b9f20ac222d



## Healthy Cartilage - Result 
![Healthy_result_bin](https://github.com/user-attachments/assets/41cdf6ac-7e47-46e4-8c31-a8863a65ee3b)
*Figure 4: Result of CRS 2D analysis, Mean angle (CRS) of 2.01°.*

## Osteoarthritis Cartilage - Result
![Osteoarthritis_result_bin](https://github.com/user-attachments/assets/2dccd3af-2e28-41e6-9410-500b41dde663)
*Figure 5: Result of CRS 2D analysis, Mean angle (CRS) of 15.40°.*
