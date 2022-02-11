# Balda
## Introduction
To date, there are quite a lot of software implementations of the Balda game, including their modifications.
However, the main problem with most applications is either their outdated design or their limited functionality. This is due to the fact that this game is not in great demand among users. And, accordingly, large enterprises involved in the development of gaming applications do not undertake to finalize this game.
But, despite the unpopularity of this game, you can easily find this game in the form of mini-games in the search engine. The significant disadvantages of these mini-games is that when you try to start the game, this application will ask you to log in to continue the game process, and, of course, to have a network connection. And, even if you put up with authorization in the application (in some there is authorization as a 'Guest'), then the application will not be able to work without access to the network, since it needs a response from the server.
However, as long as you have a network connection, you can use this app to play with your friend from different devices, which is definitely a huge advantage over apps that don't need a network connection. But, this problem can also be avoided by implementing the user & user game mode, which will allow you to play the same way together, but on the same device.
Also, no less important criteria are the ability to choose the complexity of the game (in our case, an increase in the playing space), which is not available in every mini-game and the interface, which, in turn, should be simple and intuitive to the user.
The purpose of this course work is to develop the application 'Balda' with the possibility of competition between the user and the computer on the field selected by the user.
## Gameplay
Software tool game "Balda" is designed to implement the gaming process on the user's computer. The interface of the main menu of the program is quite simple and intuitive. The main part of the game is located here. In this window, the process of the game itself takes place.
The main part of the playing space is occupied by the playing field for setting the necessary letter to get the words, as well as the selection of this one takes place here. Also on the window there are buttons “Start the game”, “Back”, “Select word”, “Cancel move”, “Surrender”. To start the game, the user needs to select the game mode, the button of which is located above the playing field and select the difficulty. Next, you need to click the “Start the game” button and the game starts. Next, you need to play according to the rules presented in the picture in the main menu of the program. After the end of the game or if the word is not found, the user can give up, then the application will automatically display a table of results where you can view your previous moves and scores, as well as a diagram of the effectiveness of your moves compared to your opponent.
If you need to play with a computer, you just need to select the “Player + computer” mode at the stage of choosing the game mode. Next, you will be offered the option of choosing the player who makes the move first.
If it is impossible to complete the game, the user has 2 options:
* click on the “Surrender” button – the game process will be completed and the program will display the table of game results;
* click on the “Back” button – in this case, if the playing field is not completely filled, the program will write the current state of the game to a file. And when re-entering the program, the user will be able, by clicking on the “Continue” button on the main menu of the program, to restore the previous gameplay of the game and continue from where it left off.
## Preview
![image](https://user-images.githubusercontent.com/86531927/153619375-bf2e24f4-6525-4c54-b85c-1dcf259c2607.png)
![image](https://user-images.githubusercontent.com/86531927/153619492-09a5ddd7-c5b3-4f45-9dad-bdbe1a23ed03.png)
![image](https://user-images.githubusercontent.com/86531927/153619392-1e3c2e98-5788-46f8-b982-d9beb25c4ee8.png)
![image](https://user-images.githubusercontent.com/86531927/153619408-34132696-e1e7-4f53-a750-903759ce23a2.png)
![image](https://user-images.githubusercontent.com/86531927/153619421-5bb51d3e-0801-4f4d-9857-fa6785271422.png)
![image](https://user-images.githubusercontent.com/86531927/153619434-fbac0ef2-6a4c-4fb9-8d7e-52cb65d67873.png)
![image](https://user-images.githubusercontent.com/86531927/153619444-ed7518d7-d06c-41a5-a487-90dc0fd9fb72.png)
![image](https://user-images.githubusercontent.com/86531927/153619463-47dacce8-cafa-4a57-9c4e-a6dbef2d4f33.png)
![image](https://user-images.githubusercontent.com/86531927/153619476-4b23c80c-d510-43cb-8454-0e294b50eece.png)

## Conclusion
The result of this course work is a software tool created in the Delphi 10.4 integrated development environment. With the help of this software tool, the user will be able to learn the rules and features of the game "Balda", as well as immerse himself in the gameplay of this game.
One of the key tasks set before writing a software tool is to make a convenient and understandable interface. As a result, the software tool can be used by both a professional and an inexperienced user. During the development, a large amount of literature from various sources was studied. Knowledge about forms and modules, components and graphical interface has been improved.
The software product has been tested and meets all the stated requirements.
* When creating a game, use the playing field, the size of which is determined by the level of complexity of the game (5*5, 6*6, etc.);
* Before starting the game, the program should prompt the user for the following parameters:
- the size of the playing field;
* the player making the first move (user or computer).

- The game must continue until all the cells of the word are filled with letters. One cell can remain empty only if it is impossible to form words using this cell;
* To search for words in the dictionary, use the search tree (i.e. the dictionary of words from the file is loaded into the search tree);
* The program should display the playing field, points scored by the user and the computer after each move. At the end of the game, the program issues a message about the results of the game (player 1 wins, player 2 wins, or a draw).
The work done allows us to fully reveal the author's basic knowledge and basic skills in the field of programming. It is possible to further improve the project by connecting it to a network dictionary, for greater improvement of the computer's vocabulary.
# Delphi, Pascal
