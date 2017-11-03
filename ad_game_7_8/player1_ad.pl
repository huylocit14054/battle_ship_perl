#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
#this is client

require "./game_file_ad.pl"; #connect to all the function in game file


# auto-flush on socket
$| = 1;

# create a connecting socket
my $socket = new IO::Socket::INET (
    PeerHost => '127.0.0.1',
    PeerPort => '9999',
    Proto => 'tcp',
);
die "cannot connect to the server $!\n" unless $socket;
print "connected to the server\n";

#receive the map from player2
my $string_map;
$socket->recv($string_map,1024);
#convert the map to array
my @map = mapToArray($string_map);

print "The battle map:\n";
print_map(@map);

my $ship_string ="";
$socket->recv($ship_string,1024);

my @ship = ShipStringConvertToArray($ship_string);

#print Dumper @ship;
#receive the dice result of the server
my $dice;
$socket->recv($dice,1);

my $player1_ship = 5;
my $player2_ship = 5;
#end turn will check if the user is end of turn
my $end_turn;
my($return_map,$play,$to_x,$to_y,$at_x,$at_y,$index_x,$index_y,$isDestroy);

if($dice == 2)
{
        #wait for the player 2 and receive the ship and the end turn
        print "Player2 go first:\nPlease wait for your turn:\n\n";

        $socket->recv($player1_ship,1);
        $socket->recv($player2_ship,1);
        $socket->recv($end_turn,1);

        #receive the new map
        $string_map ="";
        $socket->recv($string_map,1024);
        @map = mapToArray($string_map);


        #receive player 2 's' previous action
        #receive player input x
        $index_x ="";
        $socket->recv($index_x,1);
        #select(undef, undef, undef, 0.25);
        #receive player input y
        $index_y ="";
        $socket->recv($index_y,1);
        #select(undef, undef, undef, 0.25);
        #receive player move position x
        $to_x ="";
        $socket->recv($to_x,1);
        #select(undef, undef, undef, 0.25);
        #receive player move position y
        $to_y ="";
        $socket->recv($to_y,1);
        #select(undef, undef, undef, 0.25);
        #receive player fire position x
        $at_x ="";
        $socket->recv($at_x,1);
        #select(undef, undef, undef, 0.25);
        #receive player fire position y
        $at_y ="";
        $socket->recv($at_y,1);
        #select(undef, undef, undef, 0.25);

        #receive ship String
        $ship_string="";
        $socket->recv($ship_string,1024);
        select(undef, undef, undef, 0.25);

        @ship = ShipStringConvertToArray($ship_string);

        #print Dumper @ship;

        print_map(@map);

        print "Enermy selected ship at location: ".$index_x.$index_y."\n";
        if($to_x ne "f"  && $to_y ne "f"){
            
            print "The enermy ship move to ".$to_x.$to_y."\n";
        }
        else{
            print "The user has not moved any where\n";
        }

        if($at_x ne "f" && $at_y ne "f"){
            
            print "The enermy ship fire at ".$at_x.$at_y."\n";
        }
        else{
            print "The user has not fired any where\n";
        }
        print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
}
else
{
        #First turn play here
        #Player 1 fire first
        
        print "You go first\nChoose your ship";
        my @input = select_ship(1,@map);
        $index_x = $input[0];
        $index_y = $input[1];

        #player turn
        ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$isDestroy,$ship_string) = player_action(1,$index_x,$index_y,@map);
        #if the user select a stuck ship the user have to select again
        while($play==0){
                @input  = select_ship(1,@map);
                $index_x = $input[0];
                $index_y = $input[1];
                ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$isDestroy,$ship_string) = player_action(1,$index_x,$index_y,@map);
        }
        
        @map = @$return_map;

        #reduce the ship of enermy by 
        if($isDestroy==1)
        {
                $player2_ship--;
        }
        print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
        #end the turn
        $end_turn = 2;

        #send ship end_turn to player 2 
        $socket->send($player1_ship);
        $socket->send($player2_ship);
        $socket->send($end_turn);

        #send new map to the player2
        $string_map ="";
        $string_map = mapToString(@map); 
        $socket->send($string_map);
        select(undef, undef, undef, 0.25);

        #send player previous action to player 2
        #send player input x
        $socket->send($index_x);
        select(undef, undef, undef, 0.25);
        #send player input y
        $socket->send($index_y);
        select(undef, undef, undef, 0.25);
        #send player move position x
        $socket->send($to_x);
        select(undef, undef, undef, 0.25);
        #send player move position y
        $socket->send($to_y);
        select(undef, undef, undef, 0.25);
        #send player fire position x
        $socket->send($at_x);
        select(undef, undef, undef, 0.25);
        #send player fire position y
        $socket->send($at_y);
        select(undef, undef, undef, 0.25);

        #send ship string to player 2
        $socket->send($ship_string);
        select(undef, undef, undef, 0.25);
}

    
#run game until one of the player is out of ship
while(end_game($player1_ship,$player2_ship)==0){
    #end_turn = 1 => player 1 turn
    if($end_turn==1){
        print "Your turn\n";
         my @input = select_ship(1,@map);
        $index_x = $input[0];
        $index_y = $input[1];

        #player turn
        ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$isDestroy,$ship_string) = player_action(1,$index_x,$index_y,@map);
        #if the user select a stuck ship the user have to select again
        while($play==0){
                @input  = select_ship(1,@map);
                $index_x = $input[0];
                $index_y = $input[1];
                ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$isDestroy,$ship_string) = player_action(1,$index_x,$index_y,@map);
        }
        
        @map = @$return_map;
        

        #reduce the ship of enermy by 
        if($isDestroy ==1)
        {
                $player2_ship--;
        }
        print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
        #end the turn
        $end_turn = 2;

        #send ship end_turn to player 2 
        $socket->send($player1_ship);
        $socket->send($player2_ship);
        $socket->send($end_turn);

        #send new map to the player2
        $string_map ="";
        $string_map = mapToString(@map); 
        $socket->send($string_map);
        select(undef, undef, undef, 0.25);

        #send player previous action to player 2
        #send player input x
        $socket->send($index_x);
        select(undef, undef, undef, 0.25);
        #send player input y
        $socket->send($index_y);
        select(undef, undef, undef, 0.25);
        #send player move position x
        $socket->send($to_x);
        select(undef, undef, undef, 0.25);
        #send player move position y
        $socket->send($to_y);
        select(undef, undef, undef, 0.25);
        #send player fire position x
        $socket->send($at_x);
        select(undef, undef, undef, 0.25);
        #send player fire position y
        $socket->send($at_y);
        select(undef, undef, undef, 0.25);

        #send ship string to player 2
        $socket->send($ship_string);
        select(undef, undef, undef, 0.25);
    }
    #end_turn = 2 => player 2 turn 
    if($end_turn==2 && $player2_ship!=0){
        print "Player 2 turn\n";
        $socket->recv($player1_ship,1);
        $socket->recv($player2_ship,1);
        $socket->recv($end_turn,1);

        #receive the new map
        $string_map ="";
        $socket->recv($string_map,1024);
        @map = mapToArray($string_map);


        #receive player 2 's' previous action
        #receive player input x
        $index_x ="";
        $socket->recv($index_x,1);
        #select(undef, undef, undef, 0.25);
        #receive player input y
        $index_y ="";
        $socket->recv($index_y,1);
        #select(undef, undef, undef, 0.25);
        #receive player move position x
        $to_x ="";
        $socket->recv($to_x,1);
        #select(undef, undef, undef, 0.25);
        #receive player move position y
        $to_y ="";
        $socket->recv($to_y,1);
        #select(undef, undef, undef, 0.25);
        #receive player fire position x
        $at_x ="";
        $socket->recv($at_x,1);
        #select(undef, undef, undef, 0.25);
        #receive player fire position y
        $at_y ="";
        $socket->recv($at_y,1);
        #select(undef, undef, undef, 0.25);

        #receive ship String
        $ship_string="";
        $socket->recv($ship_string,1024);
        ShipStringConvertToArray($ship_string);

        #print Dumper @ship;
        
        print_map(@map);

        print "Enermy selected ship at location: ".$index_x.$index_y."\n";
        if($to_x ne "f"  && $to_y ne "f"){
            
            print "The enermy ship move to ".$to_x.$to_y."\n";
        }
        else{
            print "The user has not moved any where\n";
        }

        if($at_x ne "f" && $at_y ne "f"){
            
            print "The enermy ship fire at ".$at_x.$at_y."\n";
        }
        else{
            print "The user has not fired any where\n";
        }
         print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
    }

}

my $win = Iswin($player1_ship,$player2_ship);
print "Win: Player ". $win. "\n";
#print the winner
if(Iswin($player1_ship,$player2_ship)==1){
    print "You Win\n";
}
else{
    print "You lose\n";
}

$socket->close();