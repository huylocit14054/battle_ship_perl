#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
#this is client

require "./game_file.pl"; #connect to all the function in game file


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

#receive the dice result of the server
my $dice;
$socket->recv($dice,1);
print "result:" . $dice . "\n";

my $player1_ship = 5;
my $player2_ship = 5;
#end turn will check if the user is end of turn
my $end_turn;
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
        print "Your ship had been destroyed\n";
        print_map(@map);

}
else
{
        #First turn play here
        #Player 1 fire first
        print "You go first\n";
        #Player fire a random enermy ship
        @map = fire_random(2,@map);
        print_map(@map);
        #reduce the ship of enermy by 1
        $player2_ship--;
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
}

    
#run game until one of the player is out of ship
while(end_game($player1_ship,$player2_ship)==0){
    #end_turn = 1 => player 1 turn
    if($end_turn==1){
        print "Your turn\n";
        #fire random enermy ship
        @map = fire_random(2,@map);
        print_map(@map);
        #reduce the enermy ship
        $player2_ship--;
        #end the turn
        $end_turn=2;

        #Send the infomation to the player 2
        $socket->send($player1_ship);
        $socket->send($player2_ship);
        $socket->send($end_turn);

        #send new map to the player2
        $string_map ="";
        $string_map = mapToString(@map); 
        $socket->send($string_map);
    }
    #end_turn = 2 => player 2 turn 
    if($end_turn==2 && $player2_ship!=0){
        print "Player 2 turn\n";
        #receive the number of ship and $end_turn 
        $socket->recv($player1_ship,1);
        $socket->recv($player2_ship,1);
        $socket->recv($end_turn,1);

        #receive the new map
        $string_map ="";
        $socket->recv($string_map,1024);
        @map = mapToArray($string_map);
        print "Your ship had been destroyed\n";
        print_map(@map);
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