#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);
#this is server

require "./game_file_ad.pl"; #connect to all the function in game file
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
    select(undef, undef, undef, 0.25);

    #get all the ship value of player 2 and send it to player 1
    my @ship = getShipArray();
    my $ship_string = ShipToString(@ship);
    $client_socket->send($ship_string);
    select(undef, undef, undef, 0.25);
    $ship_string="";

    print Dumper @ship;

    #server throw dice and send the result to the client
    my $dice = dice_throw();
    #my $dice = 1;
    #send dice to the server
    #select to wait for the dice throw first then send
    select(undef, undef, undef, 0.25);
    $client_socket->send($dice);

    my $player1_ship = 5;
    my $player2_ship = 5;
    #end turn will check if the user is end of turn (1 is player1 turn to fire,2 is player 2 turn to fire)
    my $end_turn;
    my($return_map,$play,$to_x,$to_y,$at_x,$at_y,$index_x,$index_y);

    if($dice == 1){
        print "Player1 go first\nPlease wait for your turn:\n\n";

        $client_socket->recv($player1_ship,1);
        $client_socket->recv($player2_ship,1);
        $client_socket->recv($end_turn,1);  
        
        #receive the new map
        $string_map ="";
        $client_socket->recv($string_map,1024);
        @map = mapToArray($string_map);
        
        
        #receive player 1 's' previous action
        #receive player input x
        $index_x ="";
        $client_socket->recv($index_x,1);

        #receive player input y
        $index_y ="";
        $client_socket->recv($index_y,1);

        #receive player move position x
        $to_x ="";
        $client_socket->recv($to_x,1);

        #receive player move position y
        $to_y ="";
        $client_socket->recv($to_y,1);

        #receive player fire position x
        $at_x ="";
        $client_socket->recv($at_x,1);

        #receive player fire position y
        $at_y ="";
        $client_socket->recv($at_y,1);

        
        #receive ship String
        $ship_string="";
        $client_socket->recv($ship_string,1024);
        select(undef, undef, undef, 0.25);
        
        #print $ship_string. "\n";

        @ship = ShipStringConvertToArray($ship_string);
        

        #print Dumper @ship;

        print_map(@map);

        print "Enermy selected ship at location: ". $index_x . $index_y."\n";
        if($to_x ne "f"  && $to_y ne "f"){
          
            print "The enermy ship move to ". $to_x . $to_y ."\n";
        }
        else{
            print "The user has not moved any where\n";
        }

        if($at_x ne "f" && $at_y ne "f"){
           
            print "The enermy ship fire at " . $at_x . $at_y ."\n";
        }
        else{
            print "The user has not fired any where\n";
        }
        
        print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
    }
    else
    {
        #Player 2 go first move here
        print "You go first:\n";
        
        #select a ship
        my @input = select_ship(2,@map);
        $index_x = $input[0];
        $index_y = $input[1];

        #player turn
        ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$ship_string) = player_action(2,$index_x,$index_y,@map);
        #if the user select a stuck ship the user have to select again
        while($play==0){
                @input  = select_ship(2,@map);
                $index_x = $input[0];
                $index_y = $input[1];
               ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$ship_string) = player_action(2,$index_x,$index_y,@map);
        }
        
        @map = @$return_map;

         #print $ship_string. "\n";

        #reduce the ship of enermy by 1
        if($at_x ne "f" && $at_y ne "f")
        {
            $player1_ship--;
        }
         print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
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
        select(undef, undef, undef, 0.25);

        #send player previous action to player 2
        #send player input x
        $client_socket->send($index_x);
        select(undef, undef, undef, 0.25);
        #send player input y
        $client_socket->send($index_y);
        select(undef, undef, undef, 0.25);
        #send player move position x
        $client_socket->send($to_x);
        select(undef, undef, undef, 0.25);
        #send player move position y
        $client_socket->send($to_y);
        select(undef, undef, undef, 0.25);
        #send player fire position x
        $client_socket->send($at_x);
        select(undef, undef, undef, 0.25);
        #send player fire position y
        $client_socket->send($at_y);
        select(undef, undef, undef, 0.25);

        #send string ship to player 1
        $client_socket->send($ship_string);
        select(undef, undef, undef, 0.25);
    }

    
    
    #run game until one of the player is out of ship
    while(end_game($player1_ship,$player2_ship)==0){
        #end_turn = 2 => player 2 turn
        if($end_turn==2){
            print "Your turn\n";
            #select a ship
        my @input = select_ship(2,@map);
        $index_x = $input[0];
        $index_y = $input[1];

        #player turn
        ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$ship_string) = player_action(2,$index_x,$index_y,@map);
        #if the user select a stuck ship the user have to select again
        while($play==0){
                @input  = select_ship(2,@map);
                $index_x = $input[0];
                $index_y = $input[1];
               ($return_map,$play,$to_x,$to_y,$at_x,$at_y,$ship_string) = player_action(2,$index_x,$index_y,@map);
        }
        
        @map = @$return_map;

        #reduce the ship of enermy by 1
        if($at_x ne "f" && $at_y ne "f")
        {
            $player1_ship--;
        }
         print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
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
        select(undef, undef, undef, 0.25);

        #send player previous action to player 2
        #send player input x
        $client_socket->send($index_x);
        select(undef, undef, undef, 0.25);
        #send player input y
        $client_socket->send($index_y);
        select(undef, undef, undef, 0.25);
        #send player move position x
        $client_socket->send($to_x);
        select(undef, undef, undef, 0.25);
        #send player move position y
        $client_socket->send($to_y);
        select(undef, undef, undef, 0.25);
        #send player fire position x
        $client_socket->send($at_x);
        select(undef, undef, undef, 0.25);
        #send player fire position y
        $client_socket->send($at_y);
        select(undef, undef, undef, 0.25);

        #send string ship to player 1
        $client_socket->send($ship_string);
        select(undef, undef, undef, 0.25);

        }
        #end_turn = 1 => player 1 turn
        if($end_turn==1 && $player1_ship!=0){
            print "Player 1 turn\n";
            #receive the number of ship and $end_turn
            $client_socket->recv($player1_ship,1);
        $client_socket->recv($player2_ship,1);
        $client_socket->recv($end_turn,1);  
        
        #receive the new map
        $string_map ="";
        $client_socket->recv($string_map,1024);
        @map = mapToArray($string_map);
        
        
        #receive player 1 's' previous action
        #receive player input x
        $index_x ="";
        $client_socket->recv($index_x,1);
        select(undef, undef, undef, 0.25);
        #receive player input y
        $index_y ="";
        $client_socket->recv($index_y,1);
        select(undef, undef, undef, 0.25);
        #receive player move position x
        $to_x ="";
        $client_socket->recv($to_x,1);
        select(undef, undef, undef, 0.25);
        #receive player move position y
        $to_y ="";
        $client_socket->recv($to_y,1);
        select(undef, undef, undef, 0.25);
        #receive player fire position x
        $at_x ="";
        $client_socket->recv($at_x,1);
        select(undef, undef, undef, 0.25);
        #receive player fire position y
        $at_y ="";
        $client_socket->recv($at_y,1);
        select(undef, undef, undef, 0.25);
        
        #receive ship String
        $ship_string="";
        $client_socket->recv($ship_string,1024);
        ShipStringConvertToArray($ship_string);

        print Dumper @ship;


        print_map(@map);

        print "Enermy selected ship at location: ". $index_x . $index_y."\n";
        if($to_x ne "f"  && $to_y ne "f"){
          
            print "The enermy ship move to ". $to_x . $to_y ."\n";
        }
        else{
            print "The user has not moved any where\n";
        }

        if($at_x ne "f" && $at_y ne "f"){
           
            print "The enermy ship fire at " . $at_x . $at_y ."\n";
        }
        else{
            print "The user has not fired any where\n";
        }
        print "Ship player 1:  $player1_ship \n";
        print "Ship player 2:  $player2_ship \n";
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