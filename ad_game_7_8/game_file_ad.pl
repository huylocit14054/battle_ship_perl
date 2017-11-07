#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
use Term::ANSIColor;
#This is the file for game 


#hash to compare the index
my %column = (0 => "a", 1 => "b", 2 => "c", 3 =>"d", 4 => "e");
my %re_column = ("a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4);

#array store all the infomation of the ship such as 
# belongs_to (1 for user 1 and 2 for user 2)
# location_x and location_y keep and update the location of the ship
# HP keep the health of the ship
# dame keep the dame of the ship
#from 0..4 is ship belongs to user 1
#from 5..9 is ship belongs to user 2
#isSpecial is used to check which kind of ship 
# => 0 is normal
# => 1 is more dame => dame = 100
# => 2 is more shield => HP = 200
my @ship = ({'belong_to' => 1, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 1, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 1, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 1, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 100 , 'isSpecial' => 1},
            {'belong_to' => 1, 'location_x' => 0, 'location_y' => 0, 'HP' => 200 , 'dame' => 50 , 'isSpecial' => 2},
            {'belong_to' => 2, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 2, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 2, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 100 , 'isSpecial' => 1},
            {'belong_to' => 2, 'location_x' => 0, 'location_y' => 0, 'HP' => 200 , 'dame' => 50 , 'isSpecial' => 2},
            {'belong_to' => 2, 'location_x' => 0, 'location_y' => 0, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0}
            );
            


#create map and return the array of the map
sub create_map(){

    #create a map with no ship
    my $player1_ship=5;
    my $player2_ship=5;

    #count to know the position of the ship array in order to update location
    my $i = 0;
    my $j = 5;

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

            if($i <5){
                #update location in the ship array[i]
                $ship[$i]{'location_x'} = $index_x;
                $ship[$i]{'location_y'} = $index_y;       
            }
            
            #increase i to 1 
            $i++;

            $player1_ship--;
        }
        else
        {

            $map[$index_x][$index_y] = 2;
            
            if($j <10){
                #update location in the ship array[i]
                $ship[$j]{'location_x'} = $index_x;
                $ship[$j]{'location_y'} = $index_y;       
            }
            $j++;
            $player2_ship--;
        }
    }

    @map 
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

#get ship array
sub getShipArray(){
    return @ship;
}

#ship convert to String



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
    
    my $play = 1;
    my @map = splice(@_ , 3);

    #check with action the user has already done (equal 0 is done)
    my $isMove = 1;
    my $isFire = 1;
    
    my ($return_map,$to_x,$to_y,$at_x,$at_y,$isDestroy)="";
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
            $play = 0; 
            last;
        }
        
        print "Please input the code for your action\n";
        if($isMove == 1 && $can_move==1){
            print "\t1. Move The Ship\n";
        }
        if($isFire == 1 && $can_fire==1){
            print "\t2. Fire a Ship\n";
        }
             print "\t3. End turn\n";
       
        #input the code action 
        chomp(my $action_code =<STDIN>);
        if($action_code eq "1" && $isMove==1){
            print "You are moving\n";
            ($return_map,$to_x,$to_y) = moveShip($ship_value,$i_row,$i_column,@map); 
            @map = @$return_map;
            $i_row = $to_x-1;
            $i_column = $re_column{$to_y};

            print_map(@map);
            $isMove=0;
        }
        elsif($action_code eq "2" && $can_fire==1 && $isFire==1){
            print "You are firing\n";
            ($return_map,$at_x,$at_y,$isDestroy) = fireShip($ship_value,$i_row,$i_column,@map); 
            @map = @$return_map;

            print_map(@map);
            $isFire =0;
        }
        elsif($action_code eq "3"){
            last;
        }
        else{
            print "Error action\n";
        }
    }
    if(! defined($to_x)){
        $to_x = "f";
    }
    if(! defined($to_y)){
        $to_y = "f";
    }
    if(! defined($at_x)){
        $at_x = "f";
    }
    if(! defined($at_y)){
        $at_y = "f";
    }
    
    my $ship_string = ShipToString(@ship);
   
    return (\@map,$play,$to_x,$to_y,$at_x,$at_y,$isDestroy,$ship_string);

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

    # print "l: $mleft\n";
    # print "r: $mright\n";
    # print "d: $mdown\n";
    # print "u: $mup\n"; 
    if($mleft==2 || $mright==2 || $mdown==2 || $mup==2){
        return 1;
    }
    else{
        return 0;
    }

}
#move the ship to the position user want
#return the new position if the ship
#return the new map
sub moveShip()
{
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    my $mleft = checkLeft($ship_value,$i_row,$i_column,@map);
    my $mright = checkRight($ship_value,$i_row,$i_column,@map);
    my $mdown = checkDown($ship_value,$i_row,$i_column,@map);
    my $mup = checkUp($ship_value,$i_row,$i_column,@map);

    my $from_x;
    my $from_y;
    my $to_x;
    my $to_y;

    print "Enter the position you want to move ship to\n";

    #can move left
    if($mleft==2){
        print "1. Move Left\n";
    }
    #can move right
    if($mright==2){
        print "2. Move Right\n";
    }
    #can move down
    if($mdown==2){
        print "3. Move Down\n";
    }
    #can move up 
     if($mup==2){
         print "4. Move Up\n";
     }

    #if the input is error input again
    my $error = 1;
     while($error==1){

         chomp(my $input = <STDIN>);
         if($input eq "1" && $mleft==2){
             $map[$i_row][$i_column] = '0';
             $map[$i_row][$i_column-1] = "$ship_value";
             $from_x = $i_row +1;
             $from_y = $column{$i_column};
             $to_x = $i_row +1;
             $to_y = $column{$i_column-1};
             print "Move left from " . $from_x.$from_y ." to ".$to_x.$to_y. "\n";
             
             #update the ship location to the array ship
             updatePosition($ship_value,$i_row,$i_column,$i_row,$i_column-1);
             $error = 0;
            
            
         }
         elsif($input eq "2" && $mright==2){
             $map[$i_row][$i_column] = '0';
             $map[$i_row][$i_column+1] = "$ship_value";

             $from_x = $i_row +1;
             $from_y = $column{$i_column};
             $to_x = $i_row +1;
             $to_y = $column{$i_column+1};
             print "Move right from " . $from_x.$from_y ." to ".$to_x.$to_y. "\n";
             
             #update the ship location to the array ship
             updatePosition($ship_value,$i_row,$i_column,$i_row,$i_column+1);
             $error = 0;
         }
         elsif($input eq "3" && $mdown==2){
             $map[$i_row][$i_column] = '0';
             $map[$i_row+1][$i_column] = "$ship_value";

             $from_x = $i_row +1;
             $from_y = $column{$i_column};
             $to_x = $i_row +1 +1;
             $to_y = $column{$i_column};
             print "Move down from " . $from_x.$from_y ." to ".$to_x.$to_y. "\n";
             
             #update the ship location to the array ship
             updatePosition($ship_value,$i_row,$i_column,$i_row+1,$i_column);
             $error = 0;
         }
         elsif($input eq "4" && $mup==2){
             $map[$i_row][$i_column] = '0';
             $map[$i_row-1][$i_column] = "$ship_value";

             $from_x = $i_row +1;
             $from_y = $column{$i_column};
             $to_x = $i_row;
             $to_y = $column{$i_column};
             print "Move up from " . $from_x.$from_y ." to ".$to_x.$to_y. "\n";

             #update the ship location to the array ship
             updatePosition($ship_value,$i_row,$i_column,$i_row-1,$i_column);
             $error = 0;
         }
         else{
             print "Error cannot move here. Please input again\n";
         }
     }

     return (\@map,$to_x,$to_y);
     
}

#fire the ship next to the user
sub fireShip(){
    my $ship_value = $_[0];
    my $i_row = $_[1];
    my $i_column = $_[2];
    my @map = splice(@_ , 3);

    my $mleft = checkLeft($ship_value,$i_row,$i_column,@map);
    my $mright = checkRight($ship_value,$i_row,$i_column,@map);
    my $mdown = checkDown($ship_value,$i_row,$i_column,@map);
    my $mup = checkUp($ship_value,$i_row,$i_column,@map);

    my $at_x;
    my $at_y;
    print "Enter the position you want to fire\n";

    #can move left
    if($mleft==1){
        print "1. Fire Left\n";
    }
    #can move right
    if($mright==1){
        print "2. Fire Right\n";
    }
    #can move down
    if($mdown==1){
        print "3. Fire Down\n";
    }
    #can move up 
     if($mup==1){
         print "4. Fire Up\n";
     }

    #if the input is error input again
    my $error = 1;
    my $isDestroy =0; 
     while($error==1){
           
         chomp(my $input = <STDIN>);
         if($input eq "1" && $mleft==1){
            
            #update for left 
            $isDestroy = updateHealth($i_row,$i_column,$i_row,$i_column-1); 
            
            #if the ship is destroy update the map
            if($isDestroy==1){
                $map[$i_row][$i_column-1] = "0";
            }
             
            $at_x = $i_row+1;
            $at_y = $column{$i_column-1};
            print "Fire left at " .$at_x.$at_y. "\n";

            $error = 0;
            
            
         }
         elsif($input eq "2" && $mright==1){
            
            #update the right
            $isDestroy = updateHealth($i_row,$i_column,$i_row,$i_column+1); 
            #update the map if the ship is destroy
            if($isDestroy==1){
                $map[$i_row][$i_column+1] = "0";
            }
            $at_x = $i_row+1;
            $at_y = $column{$i_column+1};
            print "Fire right at " .$at_x.$at_y . "\n";

            $error = 0;
         }
         elsif($input eq "3" && $mdown==1){

            #update the down
            $isDestroy = updateHealth($i_row,$i_column,$i_row+1,$i_column); 

            #update the map
            if($isDestroy==1){
                $map[$i_row+1][$i_column] = "0";
            }
            $at_x = $i_row+1+1;
            $at_y = $column{$i_column};
            print "Fire down at " .$at_x.$at_y . "\n";

             $error = 0;
         }
         elsif($input eq "4" && $mup==1){
            #update the down
            $isDestroy = updateHealth($i_row,$i_column,$i_row-1,$i_column); 
            if($isDestroy==1){
                $map[$i_row-1][$i_column] = "0";
            }
            $at_x = $i_row;
            $at_y = $column{$i_column};
            print "Fire down at " .$at_x.$at_y . "\n";
            
             $error = 0;
         }
         else{
             print "Error cannot Fire here. Please input again\n";
         }
     }
     return (\@map,$at_x,$at_y,$isDestroy);

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

#print the map with no UI
sub print_map1()
{
    my @map = @_;
    print color('bold blue');
    print "  a b c d e\n";
    print color('reset');
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
#print UI map
sub print_map(){
    my @map = @_;
    print color('bold blue');
    print "       a          b          c          d          e\n\n";
    print color('reset');
    for(my $i=0; $i<5 ;$i++){
        print color('bold blue');
        print $i+1;
        print " ";
        print color('reset');
        for(my $j=0; $j<5 ;$j++){
            if($map[$i][$j]==0){
                print color('MAGENTA');
                print " ~~~~~~~~~ ";
                print color('reset');
            }
            else{
               my %s = getShipByPosition($i,$j);
               if($s{'belong_to'} ==1){
                print color('GREEN');
                print " ".$s{'belong_to'}."[HP:".$s{'HP'}."] ";
                print color('reset');
               }
               if($s{'belong_to'} ==2){
                print color('YELLOW');
                print " ".$s{'belong_to'}."[HP:".$s{'HP'}."] ";
                print color('reset');
               }
            }
        }
        print"\n\n";
    }
}

#print ship for user 
sub print_ship(){
    my $ship_value = $_[0];
    
    print "Your ship status:\n";
    #run the ship array and get the info of the ship
    for(my $i=0 ; $i<10 ; $i++){
        if($ship[$i]{'belong_to'} eq $ship_value){
            my $location_x = $ship[$i]{'location_x'} + 1; 
            if($ship[$i]{'HP'}==0){
                print color('RED');
                print "Ship{HP: " . $ship[$i]{'HP'}.", Dame: ".$ship[$i]{'dame'}. ", Location: ". $location_x .$column{$ship[$i]{'location_y'}} ."}\n";
                print color('reset');
            }
            else{
                print "Ship{HP: " . $ship[$i]{'HP'}.", Dame: ".$ship[$i]{'dame'}. ", Location: ".  $location_x .$column{$ship[$i]{'location_y'}} . "}\n";
            }
        }
    }
}

#update the position of the ship
sub updatePosition(){
    my($ship_value,$old_x,$old_y,$new_x,$new_y) = (@_);
    #get the ship 
    for(my $i=0;$i<10;$i++){
        if($ship[$i]{'belong_to'} == $ship_value && $ship[$i]{'location_x'} == $old_x && $ship[$i]{'location_y'} == $old_y)
        {
            $ship[$i]{'location_x'} = $new_x;
            $ship[$i]{'location_y'} = $new_y;
        }
    } 


}

sub ShipToString(){
    my @s = @_;
    my $string_ship = "";
    for(my $i=0;$i<10;$i++){
        $string_ship = $string_ship . $s[$i]{'belong_to'} . ",". $s[$i]{'location_x'} . "," . $s[$i]{'location_y'} . "," . $s[$i]{'HP'}. "," . $s[$i]{'dame'} . "," . $s[$i]{'isSpecial'}. "]"; 
    }
    return $string_ship;
}

#conver ship string to array and update it in game file
sub ShipStringConvertToArray(){
    my $ship_string = $_[0];

    #cut "]" 
    my @array = split("]" , $ship_string);
    for(my $i =0 ; $i<10 ;$i++){
        my @result =  split(",", $array[$i]);
        $ship[$i]{'belong_to'} = $result[0];
        $ship[$i]{'location_x'} = $result[1];
        $ship[$i]{'location_y'} = $result[2];
        $ship[$i]{'HP'} = $result[3];
        $ship[$i]{'dame'} = $result[4];
        $ship[$i]{'isSpecial'} = $result[5];
    }

    return @ship;
}

#update the HP after fire
sub updateHealth(){
    my($fire_x,$fire_y,$dame_x,$dame_y) = (@_);

    #fire ship is the ship which is fired
    my %fire_ship = getShipByPosition($fire_x,$fire_y);
    
    #dame ship is the ship which is taking dame
    #update the HP of the dame ship
    #return 1 => ship has been destroy
    #return 0 => ship haven't been destroy
    for(my $i=0;$i<10;$i++)
    {
        if($ship[$i]{'location_x'} == $dame_x && $ship[$i]{'location_y'} == $dame_y)
        {
            my $new_HP = $ship[$i]{'HP'} - $fire_ship{'dame'};
            
            #the ship has been destroy
            if($new_HP <=0){
                $ship[$i]{'location_x'} = -1;
                $ship[$i]{'location_y'} = -1;
                $ship[$i]{'HP'} = 0;
                return 1;
            }
            else{
                $ship[$i]{'HP'} = $new_HP;
                return 0;
            }
        }
    } 
}

sub getShipByPosition(){
    
    my($location_x,$location_y)=(@_);

    for(my $i=0;$i<10;$i++){
        if($ship[$i]{'location_x'} == $location_x && $ship[$i]{'location_y'} == $location_y)
        {
            return %{$ship[$i]};
        }
    } 
}
1 #have to return 1 