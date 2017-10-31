#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
#This is the file for game 


#hash to compare the index
my %column = (0 => "a", 1 => "b", 2 => "c", 3 =>"d", 4 => "e"); 
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


1 #have to return 1 