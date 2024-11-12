#!/bin/bash  
filesave="savegame.txt"
  
# Funkcja inicjalizująca planszę  
init_board() {  
    board=(" " " " " " " " " " " " " " " " " ")  
}  
  
# Funkcja wyświetlająca planszę  
print_board() {  
    echo " ${board[0]} | ${board[1]} | ${board[2]} "  
    echo "---|---|---"  
    echo " ${board[3]} | ${board[4]} | ${board[5]} "  
    echo "---|---|---"  
    echo " ${board[6]} | ${board[7]} | ${board[8]} "  
}  
  
# Funkcja sprawdzająca, czy ktoś wygrał  
check_winner() { 
    # poziomo 
    for i in 0 3 6; do  
        if [[ ${board[i]} != " " && ${board[i]} == ${board[i+1]} && ${board[i]} == ${board[i+2]} ]]; then  
            #echo "poziomo"
            echo "Winner: ${board[i]}"  
            return
        fi  
    done  
    #pionowo
    for i in 0 1 2; do  
        if [[ ${board[i]} != " " && ${board[i]} == ${board[i+3]} && ${board[i]} == ${board[i+6]} ]]; then  
            #echo "pionowo"
            echo "Winner: ${board[i]}"  
            return 
        fi  
    done  
    #skos w prawo
    if [[ ${board[0]} != " " && ${board[0]} == ${board[4]} && ${board[0]} == ${board[8]} ]]; then  
        #echo "skos w prawo"
        echo "Winner: ${board[0]}"  
        return 
    fi  
    #skos w lewo
    if [[ ${board[2]} != " " && ${board[2]} == ${board[4]} && ${board[2]} == ${board[6]} ]]; then  
        #echo "skos w prawo"
        echo "Winner: ${board[2]}"  
        return 
    fi  
    #gra trwa
    for i in {0..8}; do  
        if [[ ${board[i]} == " " ]]; then  
            echo " "
            return
        fi  
    done  
  
    echo "Draw"  
}  
  
# Funkcja zapisująca stan gry  
save_game() { 
    if [ -f "$filesave" ] ; then
        rm "$filesave"
    fi
    local line1=$(printf "%s," "${board[@]}")
    echo $line1 >> $filesave
    echo "$turn" >> $filesave  
}  
  
# Funkcja wczytująca stan gry  
load_game() {  
    if [[ -f "$filesave" ]]; then  
        IFS=',' 
        read -r -a board < "$filesave"
        read -r turn < <(tail -n 1 "$filesave")  
        echo "after load"
        print_board
    else  
        echo "No saved game found"  
        exit 1  
    fi  
}  
  
# Funkcja ruchu komputera  
computer_move() { 
    local stillempty=()
    for i in {0..8}; do  
        if [[ ${board[i]} == " " ]]; then  
            stillempty+=($i)
        fi  
    done
    printf '%s\n' "${stillempty[@]}"

    # randomowy wybór pustego pola przez komputer
    size=${#stillempty[@]}
    index=$(($RANDOM % $size))
    index_on_board=${stillempty[index]}
    board[index_on_board]="O"
}  
  
# Funkcja główna gry  
play_game() {  
    init_board 
    turn="X"  
    echo $1
    if [[ $1 == "load" ]]; then  
        load_game  
    fi  
    while true; do  
        clear  
        print_board  
        curr_result=$(check_winner)
        if [[ ${curr_result} != " " ]]; then  
            echo "Koniec gry"
            echo ${curr_result}
            break  
        fi  
  
        if [[ $turn == "X" ]]; then  
            echo "Player X, enter your move (0-8) or 's' to save: "  
            read -r move  
            if [[ $move == "s" ]]; then  
                save_game  
                echo "Game saved."  
                exit  
            elif [[ ${board[move]} == " " ]]; then  
                board[move]="X"  
                turn="O"  
            else  
                echo "Invalid move - Player X"
            fi
        elif [[ $1 == "computer_mode" ]]; then  
            computer_move
            turn="X"
        else
            echo "Player O, enter your move (0-8) or 's' to save: "  
            read -r move  
            if [[ $move == "s" ]]; then  
                save_game  
                echo "Game saved."  
                exit  
            elif [[ ${board[move]} == " " ]]; then  
                board[move]="O"  
                turn="X"  
            else  
                echo "Invalid move - Player O"
            fi
        fi
    done
}
# $1 load / computer_mode
play_game $1