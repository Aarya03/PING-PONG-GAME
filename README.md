# PING-PONG-GAME
<p>
Ping Pong Game in 8086 Assembly Language</br>
<b>The PONG Game</b>
<p align="center">
  <img src="Screenshot.png" width="650" title="The Game">
</p>
<b>Prerequisites:</b></br>
Install DOSBox 0.74 in your system</br>
Create a folder named 8086(or any other name) in your C drive

<b>Running the game</b></br>
-> open DOSBox 0.74.exe</br>
Run the followig commands:</br>
-> mount c C:\8086
-> masm PONG; Press enter 3 times</br>
-> link PONG; Press enter 3 times</br>
-> PONG</br>
</br>
<b>Playing the Game:</b></br>
● Controlling the left paddle : Press 'w' or 'W' to move UP and 's' or 'S' to move DOWN.</br>
● Controlling the right paddle : Press 'o' or 'O' to move UP and 'l' or 'L' to move DOWN.</br>
● The ball will bounce back after colliding with any paddle or the top and bottom walls of the screen.</br>
● If the ball strikes the left or right wall of the screen it will start from the center of the screen.</br>
● It can be played by two people or only one person.</br>
Quitting the Game:</br>
● Press 'Esc' key to exit the game and go back to DOS.</br>

<b>Important functions and Interrupts used in the game:</b></br>
Clearing the screen:</br>
● Interrupt used - INT 10H</br>
● INT 10h and AH = 00h - Set Video Mode</br>
● AL = 13h 320x200 256 color graphics (MCGA,VGA) - THIS IS THE VIDEO MODE USED</br>
</br>
Drawing a Pixel:</br>
● Interrupt used - INT 10H</br>
● AH = 0Ch - set the configuration to writing the pixel</br>
● AL = 0Fh - choose white as color of the pixel</br></br>
Checking Input from Keyboard:</br>
● Interrupt used INT 16H - Keyboard BIOS Services</br>
● AH = 01h - check if any key is being pressed (if not check the other paddle)</br>
● AH = 00h - check which key is being pressed (AL = ASCII Character)</br></br>
Moving the Paddles and Balls:</br>
● The velocities are added to the current positions of the paddles and the balls</br>
● the screen is cleared after the above operation for avoiding the formation of trails</br>
</p>
