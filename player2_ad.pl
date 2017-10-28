#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
#this is server

require "./game_file.pl"; #connect to all the function in game file
# auto-flush on socket
$| = 1;
 
# creating a listening socket
my $socket = new IO::Socket::INET (
    LocalHost => '127.0.0.1',
    LocalPort => '9999',
    Proto => 'tcp',
    Listen => 5,
    Reuse => 1
);die "cannot create socket $!\n" unless $socket;
print "waiting for other player\n";


    # waiting for a new client connection
    my $client_socket = $socket->accept();
 
    # get information about a newly connected client
    my $client_address = $client_socket->peerhost();
    my $client_port = $client_socket->peerport();
    print "Connect to player:\n";
    
    my @map = create_map();
    print_map(@map);

    #conver the map to string and send to client
    my $string_map = mapToString(@map); 
    $client_socket->send($string_map);

    #server throw dice and send the result to the client
    my $dice = dice_throw();
    #send dice to the server
    #select to wait for the dice throw first then send
    select(undef, undef, undef, 0.25);
    $client_socket->send($dice);

    my $player1_ship = 5;
    my $player2_ship = 5;
    #end turn will check if the user is end of turn (1 is player1 turn to fire,2 is player 2 turn to fire)
    my $end_turn;
    if($dice == 1){
        print "Player1 go first\nPlease wait for your turn:\n\n";

        $client_socket->recv($player1_ship,1);
        $client_socket->recv($player2_ship,1);
        $client_socket->recv($end_turn,1);  
        
        #receive the new map
        $string_map ="";
        $client_socket->recv($string_map,1024);
        @map = mapToArray($string_map);
        print "Your ship had been destroyed\n";
        print_map(@map);
    }
    else
    {
        #Player 2 go first move here
        print "You go first:\n";
        #Player fire a random enermy ship
        @map = fire_random(1,@map);
        print_map(@map);
        #reduce the ship of enermy by 1
        $player1_ship--;
        #end the turn
        $end_turn = 1;

        #send ship end_turn to player 1 
        $client_socket->send($player1_ship);
        $client_socket->send($player2_ship);
        $client_socket->send($end_turn);
        #send new map to the player 1
        $string_map ="";
        $string_map = mapToString(@map); 
        $client_socket->send($string_map);
    }

    
    
    #run game until one of the player is out of ship
    while(end_game($player1_ship,$player2_ship)==0){
        #end_turn = 2 => player 2 turn
        if($end_turn==2){
            print "Your turn\n";
            #fire random enermy ship
            @map = fire_random(1,@map);
            print_map(@map);
            #reduce the enermy ship
            $player1_ship--;
            #end the turn
            $end_turn=1;
            #send ship end_turn to player 1 
            $client_socket->send($player1_ship);
            $client_socket->send($player2_ship);
            $client_socket->send($end_turn);
            #send new map to the player 1
            $string_map ="";
            $string_map = mapToString(@map); 
            $client_socket->send($string_map);

        }
        #end_turn = 1 => player 1 turn
        if($end_turn==1 && $player1_ship!=0){
            print "Player 1 turn\n";
            #receive the number of ship and $end_turn
            $client_socket->recv($player1_ship,1);
            $client_socket->recv($player2_ship,1);
            $client_socket->recv($end_turn,1); 
            
            #receive new map
            $string_map ="";
            $client_socket->recv($string_map,1024);
            @map = mapToArray($string_map);
            print "Your ship had been destroyed\n";
            print_map(@map); 
        }

    } 
#print the winner
my $win = Iswin($player1_ship,$player2_ship);
print "Win: Player ". $win. "\n";
if(Iswin($player1_ship,$player2_ship)==2){
    print "You Win\n";
}
else{
    print "You lose\n";
}
    

$socket->close();