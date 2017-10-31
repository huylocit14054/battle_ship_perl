#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
#This is the file for game 


#hash to compare the index
my %column = (0 => "a", 1 => "b", 2 => "c", 3 =>"d", 4 => "e");
my %re_column = ("a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4);
#create map and return the array of the map
sub create_map(){

    #create a map with no ship
    my $player1_ship=5;
    my $player2_ship=5;

    my @map = (
                
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0],
                [0,0,0,0,0]    
    );
    #while loop to put 10 ship of 2 player to the array
    while($player1_ship != 0 || $player2_ship != 0)
    {
        #random 2 number is the position of the ship
        my $index_x = int(rand(5));
        my $index_y = int(rand(5));

        #check if the random position have a ship or not
        #if the position has a ship(!=0) the number will random again
        while($map[$index_x][$index_y] != 0){
            $index_x = int(rand(4));
            $index_y = int(rand(4));
        }
        #check whose ship will be input next 
        #if player 1 ship = player 2 ship 
        # => input 1 to the location
        #else input 2 to the location 
        if($player1_ship >= $player2_ship)
        {
            $map[$index_x][$index_y] = 1;
            $player1_ship--;
        }
        else
        {
            $map[$index_x][$index_y] = 2;
            $player2_ship--;
        }
    }
    @map 
}

#print the map
sub print_map()
{
    my @map = @_;
    print("  a b c d e\n");
    for(my $i=0; $i<5 ;$i++){
        print $i+1;
        print " ";
        for(my $j=0; $j<5 ;$j++){
            print $map[$i][$j];
            print " ";
        }
        print"\n";
    }
}

#convert the map to string in order to send to the client
sub mapToString(){
    my @map = @_;
    my $string_map ="";
    for(my $i=0; $i<5 ;$i++){
        for(my $j=0; $j<5 ;$j++){
            $string_map = $string_map. $map[$i][$j]. ",";
        }
        
        $string_map = $string_map . " ] ";
    }
    $string_map;
}

#convert string map in client to array 
sub mapToArray(){
    #get the string in arg
    my $string = $_[0];
    my @map;
    #slipt the " / " so the $string become array of 5 string
    my @array = split(" ] ", $string);
    
    for(my $i=0 ; $i<5;$i++){
        my @result =  split(",", $array[$i]);
        push @map, \@result;
    }
    @map; 
}

#throwing a die to decide 1st turn
#1,3,5 => player 1 first 
#2,4,6 => player 2 first
sub dice_throw(){
    my $dice = int(rand(6)) + 1;
    my $result;
    if($dice % 2 != 0){
        $result = 1;
        
    }
    else{
        $result = 2;
    }
    return $result;
}

#check if the game is end or not 
# end game return 1
# else return 2
sub end_game(){
    my $player1_ship = $_[0];
    my $player2_ship = $_[1];
    if($player1_ship==0 ||  $player2_ship==0){
        return 1;
    }
    return 0;
}

#fire randomly a ship return the new map after fire 
#the function will find the the ship equal to the number of the params and destroy it
#1 is for user 1 ship 
#2 is for user 2 ship
#return the new map
sub fire_random(){
    #get the ship val(1 or 2)
    my $ship_val = $_[0];
    my @map = splice(@_ , 1);
    my $break=0;
    for(my $i=0; $i<5 ;$i++){
        for(my $j=0; $j<5 ;$j++){
            if($map[$i][$j] eq $ship_val)
            {
                $map[$i][$j] = "x";
                my $row = $i+1;
                print "Ship at location: ".$row.$column{$j} ." had been destroyed\n";
                $break = 1;
                last;                
            }   
        }
        if($break==1){
            last;
        }
    }
    @map;
}

#check the winner
#if the player 1 win return 1
#if the player 2 win return 2
sub Iswin(){
    my $player1_ship = $_[0];
    my $player2_ship = $_[1];
    if($player1_ship==0){
        return 2;
    }
    if($player2_ship==0){
        return 1;
    }
}

#user input the ship location 
#return the array of location 
sub select_ship(){
    my $ship_val = $_[0];
    my @map = splice(@_ , 1);
   
        print "Input a row (1->5):\n";
        my $index_x;
        chomp($index_x=<STDIN>);
        print "Input a column (a->e):\n";
        my $index_y;
         chomp($index_y =<STDIN>);
        
        #check validate of the input
        while(checkValidInput($index_x,$index_y,$ship_val,@map)==0){
            print "Input a row (1->5):\n";
             chomp($index_x=<STDIN>);
            print "Input a column (a->e):\n";
             chomp($index_y=<STDIN>);
        }
        my @input;
        $input[0] = $index_x;
        $input[1] = $index_y;
        return @input;
}

#check if the user input is validate return 0 if the input is not valid
sub checkValidInput(){
    #the 2 params is the index the user input 
    my $index_x = $_[0];
    my $index_y = $_[1];
    #ship value is the value of the ship(player 1 is 1 adn player 2 is 2)
    my $ship_val = $_[2];

    #map of the battle
    my @map = splice(@_ , 3);
    #if the column input dose not exist the function will return
    
    unless(exists($re_column{$index_y})){
        print "There is no column ". $index_y . "\n";
        print "Please input the value again\n";
        return 0;
    }
    else{
        my $i_row =  $index_x-1; 
        my $i_column = $re_column{$index_y};
        #check the row input
        if($i_row<0 || $i_row>4){
            print "There is no row ". $index_x . "\n";
            print "Please input the value again\n";
            return 0;
        }
        #check if the location have a ship or not
        if($map[$i_row][$i_column]==0){
            print "There is no ship at location  ". $index_x.$index_y . "\n";
            print "Please input the value again\n";
            return 0;
        }
        #check if the ship in that location is the ship of the player
        if($map[$i_row][$i_column]!= $ship_val){
            print "The ship at location  ". $index_x.$index_y . " is not belong to you\n";
            print "Please input the value again\n";
            return 0;
        }
    }
  return 1;  
}


#player will choose the action to do 
#the action will only be <= 2 at each turn 
sub player_action(){
    my $ship_value = $_[0];
    my $index_x = $_[1];
    my $index_y = $_[2];
    my $i_row =  $index_x-1; 
    my $i_column = $re_column{$index_y};
    
    my @map = splice(@_ , 3);

    #check with action the user has already done (equal 0 is done)
    my $isMove = 1;
    my $isFire = 1;
    
   
   
    #loop and get the input of user
    while($isMove == 1 ||  $isFire == 1)
    {
        my $can_fire = canFire($ship_value,$i_row,$i_column,@map);
        my $can_move = canMove($ship_value,$i_row,$i_column,@map);
        
        #if the user have already moved the ship to a position.
        #However it cannot fire anything so it will break
        if($isMove == 0 && $can_fire==0){
            last;
        }

        #if the user have already fired the ship .
        #However it cannot move any where so it will break
        if($isFire == 0 && $can_move==0){
            last;
        }
        #if the user select a ship which canot move the user have to reinput another ship
        if($can_move==0 && $can_fire==0){
            print "This ship cannot move or fire\n";
            return 0;
        }
        
        print "Please input the code for your action\n";
        if($isMove == 1 && $can_move==1){
            print "\t1. Move The Ship\n";
        }
        if($isFire == 1 && $can_fire==1){
            print "\t2. Fire a Ship\n";
        }

       
        #input the code action 
        chomp(my $action_code =<STDIN>);
        if($action_code eq "1" && $isMove==1){
            print "This is Moving part\n";
            $isMove=0;
        }
        elsif($action_code eq "2" && $can_fire==1 && $isFire==1){
            print "This is Fire part\n";
            $isFire =0;
        }
        else{
            print "Error action\n";
        }
    }
    return 1;
}

#check the suround of the ship can be fire or not 
#return 1 if it can fire 
#return 0 if it cannot fire
sub canFire(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    my $cleft = checkLeft($ship_value,$i_row,$i_column,@map);
    my $cright = checkRight($ship_value,$i_row,$i_column,@map);
    my $cdown = checkDown($ship_value,$i_row,$i_column,@map);
    my $cup = checkUp($ship_value,$i_row,$i_column,@map);
    if($cleft==1 || $cright==1 || $cdown==1 || $cup==1){
        return 1;
    }
    else{
        return 0;
    }

}

#check if the ship can move or not 
sub canMove(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    my $mleft = checkLeft($ship_value,$i_row,$i_column,@map);
    my $mright = checkRight($ship_value,$i_row,$i_column,@map);
    my $mdown = checkDown($ship_value,$i_row,$i_column,@map);
    my $mup = checkUp($ship_value,$i_row,$i_column,@map);

    print "l: $mleft\n";
    print "r: $mright\n";
    print "d: $mdown\n";
    print "u: $mup\n"; 
    if($mleft==2 || $mright==2 || $mdown==2 || $mup==2){
        return 1;
    }
    else{
        return 0;
    }

}

#check left 
#return 1 if it has an enermy ship 
#return 0 if it doesn't have an enermy ship or out of the map or friendly ship
#retunr 2 if it is a empty space can move 
sub checkLeft(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    #check if the left position still in the map
    if($i_column-1 < 0)
    {
        return 0;
    }
    #get the left value of the ship
    my $left = $map[$i_row][$i_column-1];

    #the left is a friendly ship
    if($left == $ship_value){
        return 0;
    }
    #the left has nothing 
    elsif($left == 0){
        return 2;
    }
    #the left have enermy ship
    else{
        return 1;
    }
}
#check right
#return 1 if it has an enermy ship 
#return 0 if it doesn't have an enermy ship or out of the map or friendly ship
#retunr 2 if it is a empty space can move 
sub checkRight(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    #check if the right position still in the map
    if( $i_column+1 >=5)
    {
        return 0;
    }
    #get the right value of the ship
    my $right = $map[$i_row][$i_column+1];


    #the right is a friendly ship
    if($right == $ship_value){
        return 0;
    }
    #the right has nothing 
    elsif($right == 0){
        return 2;
    }
    #the right have enermy ship
    else{
        return 1;
    }
}
#check down 
#return 1 if it has an enermy ship 
#return 0 if it doesn't have an enermy ship or out of the map or friendly ship
#retunr 2 if it is a empty space can move 
sub checkDown(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    #check if the down position still in the map
    if( $i_row+1 >=5)
    {
        return 0;
    }
    #get the down value of the ship
    my $down = $map[$i_row+1][$i_column];

    #the down is a friendly ship
    if($down == $ship_value){
        return 0;
    }
    #the down has nothing 
    elsif($down == 0){
        return 2;
    }
    #the down have enermy ship
    else{
        return 1;
    }
}
#check up 
#return 1 if it has an enermy ship 
#return 0 if it doesn't have an enermy ship or out of the map or friendly ship
#retunr 2 if it is a empty space can move 
sub checkUp(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    #check if the up position still in the map
    if( $i_row-1 < 0)
    {
        return 0;
    }
    #get the up value of the ship
    my $up = $map[$i_row-1][$i_column];

    #the up is a friendly ship
    if($up == $ship_value){
        return 0;
    }
    #the up has nothing 
    elsif($up == 0){
        return 2;
    }
    #the up have enermy ship
    else{
        return 1;
    }
}
1 #have to return 1 