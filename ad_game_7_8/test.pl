#!/usr/bin/perl
use strict;
use warnings;
use IO::Socket::INET;
use Scalar::Util qw(looks_like_number);
use Data::Dumper qw(Dumper);


my @ship = ({'belong_to' => 1, 'location_x' => 1, 'location_y' => 2, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 1, 'location_x' => 3, 'location_y' => 4, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 1, 'location_x' => 5, 'location_y' => 6, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 1, 'location_x' => 7, 'location_y' => 8, 'HP' => 100 , 'dame' => 100 , 'isSpecial' => 1},
            {'belong_to' => 1, 'location_x' => 7, 'location_y' => 9, 'HP' => 200 , 'dame' => 50 , 'isSpecial' => 2},
            {'belong_to' => 2, 'location_x' => 10, 'location_y' => 11, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 2, 'location_x' => 12, 'location_y' => 13, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0},
            {'belong_to' => 2, 'location_x' => 12, 'location_y' => 14, 'HP' => 100 , 'dame' => 100 , 'isSpecial' => 1},
            {'belong_to' => 2, 'location_x' => 21, 'location_y' => 15, 'HP' => 200 , 'dame' => 50 , 'isSpecial' => 2},
            {'belong_to' => 2, 'location_x' => 3, 'location_y' => 16, 'HP' => 100 , 'dame' => 50 , 'isSpecial' => 0}
            );

$ship[0]{'belong_to'} = 3;
        
my $string = ShipToString(@ship);

print $string ."\n";

@ship = ShipStringConvertToArray($string);

print Dumper @ship;
# sub getShipByPosition(){
    
#     my($ship_value,$location_x,$location_y)=(@_);

#     for(my $i=0;$i<10;$i++){
#         if($ship[$i]{'belong_to'} == $ship_value && $ship[$i]{'location_x'} == $location_x && $ship[$i]{'location_y'} == $location_y)
#         {
#             return %{$ship[$i]};
#         }
#     } 
# }

sub ShipToString(){
    my @s = @_;
    my $ship_string = "";
    for(my $i=0;$i<10;$i++){
        $ship_string = $ship_string . $s[$i]{'belong_to'} . ",". $s[$i]{'location_x'} . "," . $s[$i]{'location_y'} . "," . $s[$i]{'HP'}. "," . $s[$i]{'dame'} . "," . $s[$i]{'isSpecial'}. "]"; 
    }
    return $ship_string;
}

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