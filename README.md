# CRS_2D
Cartilage Roughness Score. Surface roughness analysis tool for histological samples of cartilage.

Used scripts from other sources: 
Einar Ueland (2024). Astar-Algorithm (https://github.com/EinarUeland/Astar-Algorithm), GitHub. Retrieved September 27, 2024.

Douglas Schwarz (2024). uipickfiles: uigetfile on steroids (https://www.mathworks.com/matlabcentral/fileexchange/10867-uipickfiles-uigetfile-on-steroids), MATLAB Central File Exchange. Retrieved September 30, 2024.

- Settings in this example: 
  - moving window size = 28µm (increase to catch larger defects, decrease to catch smaller defects)
  - Pixel size = 0.2515µm/pixel
  
## Healthy Cartilage Sample
![Healthy](https://github.com/user-attachments/assets/77c4e7ec-97e1-4cfe-8bb4-1166365b1439)
*Figure 1: Healthy cartilage surface.*

## Osteoarthritis Cartilage Sample
![Osteoarthritis](https://github.com/user-attachments/assets/a38e09c7-cde9-4398-8f99-4d583eb587fa)
*Figure 2: Osteoarthritis-affected cartilage surface.*

## Video Demonstration
https://github.com/user-attachments/assets/4c24f8ef-3191-40d2-beb0-8b9f20ac222d



## Healthy Cartilage - Result 
![Healthy_result_bin](https://github.com/user-attachments/assets/41cdf6ac-7e47-46e4-8c31-a8863a65ee3b)
*Figure 3: Result of CRS 2D analysis, Mean angle (CRS) of 2.01°.*

## Osteoarthritis Cartilage - Result
![Osteoarthritis_result_bin](https://github.com/user-attachments/assets/2dccd3af-2e28-41e6-9410-500b41dde663)
*Figure 4: Result of CRS 2D analysis, Mean angle (CRS) of 15.40°.*
