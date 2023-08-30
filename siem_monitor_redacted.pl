#!/usr/bin/perl

use strict;
#use warnings;
#use diagnostics;
use Term::ANSIColor;

#~~ Global Variables ~~#

my $clear_screen = `clear`;
my $server1 = "127.0.0.1";

#~~ End Global Variables ~~#

#~~ Customer Hashes ~~#

my %AAA = (
		FW1 => {
			IP => '127.0.0.1',
			COUNTER => 0,
				},
        IDS1 => {
        	IP => 'AAA',
        	COUNTER => 0,
        	},
		);
		my $AAA  = \%AAA;
		
my %BBB = (
        IDS1 => {
        	IP => '127.0.0.1',
        	COUNTER => 0,
        	},
		);
		my $BBB  = \%BBB;
		
my %CCC = (
		FW1 => {
			IP => '127.0.0.1',
			COUNTER => 0,
				},
        IDS1 => {
        	IP => 'CCC',
        	COUNTER => 0,
        	},
		);
		my $CCC  = \%CCC;
		
my %DDD = (
		FW1 => {
			IP => ' 127.0.0.1 ',
			COUNTER => 0,
				},
		FW2 => {
			IP => ' 127.0.0.1 ',
			COUNTER => 0,
				},
        IDS1 => {
        	IP => 'DDD',
        	COUNTER => 0,
        	},
		);
		my $DDD  = \%DDD;
		
my %EEE = (
		FW1 => {
			IP => ' 127.0.0.1 ',
			COUNTER => 0,
				},
        IDS1 => {
        	IP => 'EEE',
        	COUNTER => 0,
        	},
		);
		my $EEE  = \%EEE;
		
my %FFFF = (
		FW1 => {
			IP => '127.0.0.1',
			COUNTER => 0,
				},
        IDS1 => {
        	IP => 'FFFF',
        	COUNTER => 0,
        	},
		);
		my $FFFF  = \%FFFF;	
        
#~~ End Customer Hashes ~~#

#~~ Subroutines ~~#

sub firewall_access_check 
{
		my @firewall_keywords = ("action=login", "subtype=config", "sys_msgs=installed", "subtype=admin pri=alert", "subtype=admin pri=notice", "system-warning-00519", "Operation=Modify Object", "Operation=Install Policy", "logged in for", "enable_15");
		my $exceptions = "Disk log|ntp_daemon";
    	print color 'bold yellow';
  		print "\n","="x5," Checking for recent firewall change/login events ","="x5,"\n\n";
  		print color 'reset';  		
			foreach (@firewall_keywords) {
				my $firewall_search_result = `grep -h '$_' server | egrep -v "$exceptions"  2>&1`;
				print "$firewall_search_result";
			}
}

sub device_check 
{
  my $customer = shift;
  my $customer_ref = shift;
  my %customer_deref = %{$customer_ref};

  foreach my $device ( sort keys %customer_deref ) {
  	    print color 'bold blue';
    	print "\n=========== Checking: ", $customer,"-",$device, " : \"", $customer_deref{$device}{IP},"\" ===========\n";
    	print color 'reset';
		my $device_check_result = `grep -h '$customer_deref{$device}{IP}' $ $.1 | grep -v server | tail -n3 2>&1`;
		chomp ($device_check_result);
		if( length $device_check_result ) {
		     	print "\n$device_check_result\n";
	   			}
      	else{
      		 	print color 'bold red';
      		 	print "\nNot receiving events from ", $customer,"-",$device, " : \"", $customer_deref{$device}{IP},"\"\n";
      		 	print color 'reset';    		 	
	      	 }
  }
}

sub failed_devices
{
  my @failed_devices;
  print color 'bold cyan';
  print "\n","="x10, " Failed Devices ", "="x10, "\n\n";
  print color 'reset';	
  my @customer_list = ("AAA", "FFFF", "BBB", "CCC", "DDD", "EEE");
  		foreach my $customer (@customer_list) {
  				my $customer_ref = eval "\$$customer";
  				my %customer_deref = %{$customer_ref};
  				foreach my $device ( sort keys %customer_deref ) {
  	    				my $device_check_result = `grep -h '$customer_deref{$device}{IP}' $ $.1 | grep -v server | tail -n3 2>&1`;
						chomp ($device_check_result);
					if( length $device_check_result ) {
		     			$customer_deref{$device}{COUNTER} = 0;
	   					}
      				else{
      		 			$customer_deref{$device}{COUNTER} += 1;
      		 			if ( "$customer_deref{$device}{COUNTER}" > 10)
      		 				{
      		 					push(@failed_devices, "$customer-$device \($customer_deref{$device}{COUNTER}\) <<== ALERT");
      		 				}
      		 					else{
      		 						push(@failed_devices, "$customer-$device \($customer_deref{$device}{COUNTER}\)");
      		 					}
      				}
  				}
  			}
  		foreach(@failed_devices){
    	print ":"x10," $_\r\n";
  	}
}

sub SYSTEM_ALERT_events
{
# SYSTEM Events
		my $exceptions = "127.0.0.1";
    	print color 'bold blue';
  		print "\n","="x5," Checking for recent SYSTEM events (5 events) ","="x5,"\n\n";
  		print color 'reset'; 
		my $SYSTEM_search_result = `grep -h 'SYSTEM' $ $.1 | egrep -v "$exceptions" | grep 'from' | tail -n 5 | sort -u  2>&1`;
	    print "$SYSTEM_search_result";

# ALERT Events
	    print color 'bold blue';
	    print "\n","="x5," Checking for recent ALERT events (5 events) ","="x5,"\n\n";
		my $ALERT_search_result = `grep -h 'ALERT' $ $.1 | egrep -v "$exceptions" | grep 'from' | tail -n 5 | sort -u  2>&1`;
	    print color 'bold red';
	    print "$ALERT_search_result";
	    print color 'reset';
}

sub known_scanners
{	
		my %known_scanners = (
    		M**** => [ '127.0.0.1/27', '127.0.0.1/26', '127.0.0.1/26', '127.0.0.1/28', '127.0.0.1/26', '127.0.0.1/27', '127.0.0.1/26' ],
    		Q**** => [ '127.0.0.1/20', '127.0.0.1/25', '127.0.0.1/26' ],
    		T**** => ['127.0.0.1/28'],
    		H**** => ['127.0.0.1/25'],
    		S**** => ['127.0.0.1/24'],
    		R**** => ['127.0.0.1/29'],
    		G**** => ['127.0.0.1'],
	    );
	    print color 'bold magenta';
	    print "\n","="x5," Checking for recent \"Known Scanners\" events (10 events per CIDR block) ","="x5,"\n\n";
	    print color 'reset';
	    foreach my $scanner (sort keys %known_scanners) {
    		print "Searching for $scanner activity => \n\n";
    		foreach (@{$known_scanners{$scanner}}) {
        		my $known_scanner_search_result = `/usr/bin/grep '$_' $ $.1 $.2 | tail -n10 | sort -u`;
        		if (length $known_scanner_search_result){
        		print "$known_scanner_search_result\n";
        		}
    		}
	    }

}

sub special_events
{	
		my $exceptions = "TEST";
		my %special_events = (
    		Web_URL => [ 'nessus', 'passwd', '/etc/passwd', 'SELECT FROM', 'JOIN', 'UNION', 'php.exe', 'win.ini', 'boot.ini' ]
   	    );
	    print color 'bold magenta';
	    print "\n","="x5," Checking for recent \ server Special Events\" ","="x5,"\n\n";
	    print color 'reset';
	    foreach my $event (sort keys %special_events) {
    		print "Searching for $event activity => \n\n";
    		foreach (@{$special_events{$event}}) {
        		my $special_events_search_result = `grep -h '$_' $ $.1 $.2 | tail -n10 | sort -u | egrep -v "$exceptions"`;
        		if (length $special_events_search_result){
        		print "$special_events_search_result\n";
        		}
    		}
	    }
}

sub menu
{
	    my $menu_option_ref = shift;
        my @m = @{$menu_option_ref};
	    unshift @m, 'Please select:';
	    chomp(@m);
	    my $choice;
	    while (1)
	    {
	      print $clear_screen;
	      print color 'bold green';
	      print "\n","="x5," Welcome to SIEM Script","="x5,"\n";
	      print color 'reset';
	      print "\n$m[0]\n\n";
	      print map { "\t$_. \t$m[$_]\n" } (1..$#m);
	      print "\nEnter your number selection: (1-$#m)> ";
	      chomp ($choice = <STDIN>);
	      last if ( ($choice > 0) && ($choice <= $#m ));
	      print "\nYou chose '$choice'.  That is not a valid option.\n\n";
	      sleep 2;
	    }
	    return "$m[$choice]";
}

sub auto_run
{
	while (1) {
		print $clear_screen;
		firewall_access_check;
		failed_devices;
		SYSTEM_ALERT_events;
		known_scanners;
		special_events;
		sleep 5;
	}
}

#~~ End Subroutines ~~#

#~~ Subroutine Calls ~~#

while (1) {
	my @menu_list = ("AAA", "BBB", "CCC", "DDD", "EEE", "FFFF", "Firewall Change/Logins", "Known Scanners", "Special Events", "Automatic Run");
	my $menu_choice = menu(\@menu_list);
	print $clear_screen;
	
	if ("$menu_choice" eq "Firewall Change/Logins"){
		firewall_access_check;
		}
	elsif("$menu_choice" eq "Automatic Run"){
		auto_run();
		}
	elsif("$menu_choice" eq "Known Scanners"){
		known_scanners();
		}
	elsif("$menu_choice" eq "Special Events"){
		special_events();
		}
	else{
		my $choice_ref = eval "\$$menu_choice";
		device_check("$menu_choice", $choice_ref);
		}
	
	print "\n\nPress ENTER key to return to main menu..";
	my $userinput =  <STDIN>;
}

#~~ End Subroutine Calls ~~#