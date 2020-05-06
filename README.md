# DOSSnake
Small DOS snake game written with TASM using 80836 instructions

## Screenshots
<img src='https://i.ibb.co/Bzrsk0D/Screenshot-from-2020-05-06-10-40-16.png'>
<img src='https://i.ibb.co/qswnP8H/Screenshot-from-2020-05-06-10-41-34.png'>

## Installation
    cd Tasm # Path to your tasm folder
    git clone https://github.com/4uf04eG/DOSSnake.git
    cp DOSSnake/RUN.BAT .
    
   Then run RUN.BAT at dosbox
## Configuration
It's poorly written and even more poorly optimized, 
so if you want to get at least partially smooth experience, set cpu cycles in dosbox settings to 'max'.

File const.inc contains constant parameters like cell size or snake speed that you are free to change.
