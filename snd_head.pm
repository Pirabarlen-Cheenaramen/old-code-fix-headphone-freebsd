#!/usr/bin/perl
#------------------------------------------------------------------
# If you find bugs in this, fix it or leave it.
# Script to get your headphones jack to work on freebsd 
# applies only for those having an snd_hda
# c0ded by selven AT hackers . mu / selven pirabarlen cheenaramen 
# just in case someone else is having this issue.
# and yes the obvious: am not responsible if this script fucks up
# bsd licensed
# Old script for a 2010 problem
#------------------------------------------------------------------

use strict;
use warnings;

#---- Main Body ------------
fixHeadphone();

#---- Function List --------
sub fixHeadphone
{

	my( $nid_head, $nid_mic, $lines_to_add);
	my %nidList=getNid();
	$lines_to_add="";
	$nid_head=$nidList{'line_out'}; #hahaha yeah 'nid head'! hahaha
	$nid_mic=$nidList{'mic'};
	if(trim($nid_head) ne "" && trim($nid_mic) ne "")
	{	$lines_to_add= "hint.hdac.0.cad0.nid".$nid_head.".config=\"as=1 seq=15 device=Headphones\"\nhint.hdac.0.cad0.nid".$nid_mic.".config=\"as=4 seq=0\"\n"; }
	elsif(trim($nid_head) ne "" && trim($nid_mic) eq "")
	{	$lines_to_add= "hint.hdac.0.cad0.nid".$nid_head.".config=\"as=1 seq=15 device=Headphones\"";}
	
	if($lines_to_add ne "")
	{	
		if(appendDevHints($lines_to_add)==1)
		{
			print "\n\n device hints have been added\n";
			print " I have made a copy of your original device.hints in /boot/device.hints.head.orig just in case of trouble\n";
			print " Try REBOOTING, cross fingers and hope it works\n";
			print " If it didnt i guess i screwed up somewhere";
			print " sysctl dev.hdac.0.pindump=1 and  post your dmesg and /boot/device.hints on freebsd.org forum \n";
			print " Hope it works out for you :) \n";
			print " selven / pcthegreat A|T gmail\n";
			print "\n Go on reboot, what are you reading?\n\n";
		}
	}
	
	
}

sub appendDevHints
{
	my($snd_hda_lines)= @_;
	`cp /boot/device.hints /boot/device.hints.head.orig`;
	my $device_hints="/boot/device.hints";
	open(DEVICEHINTS,">>$device_hints") || die("Cannot Open Device Hints");
	print DEVICEHINTS $snd_hda_lines;
	close(DEVICEHINTS);
	return 1;
}

sub getNid
{
    my ($line,@hda_lines,$headPhoned, $miked, $nid_head, $nid_mic, $HDALOUT, $HDAHP, $MIC);
	my %nidList=();
	$HDALOUT="Line-out"; 
	$HDAHP="Headphones";
	$MIC="Mic";
    @hda_lines=getHda();
	$headPhoned=0;
	$miked=0;
	

    foreach(@hda_lines)
    {
        $line=$_;
		if(($line=~ /$HDALOUT/ || $line=~/$HDAHP/) && $line=~/loc\s+2/ && !$headPhoned)
		{
           	$line=$_;
			#print $line;
			$nid_head=grepInBetween($line, "nid", "0x");
			$headPhoned=1; #just not to go through the whole lot
       	}

		if($line=~ /$MIC/ && $line=~/loc\s+2/ && !$miked)
        {
            $line=$_;
            #print $line;
            $nid_mic=grepInBetween($line, "nid", "0x");
            $miked=1; #just not to go through the whole lot
        }

    }
	$nidList{'line_out'}=$nid_head;
	$nidList{'mic'}=$nid_mic;

	return %nidList;

}

sub grepInBetween
{
	my($value, $start_boundary, $end_boundary )= @_;
	return trim($1) if $value =~ /\Q$start_boundary\E(.*?)\Q$end_boundary\E/;
}

sub getHda
{
	my (@dmesg_dump, $line,@hda_line, $nid_head, $nid_mic, $HDADEV);
	$HDADEV="hdac0:";
	@dmesg_dump=getDmesg();
	
	foreach(@dmesg_dump)
    {
        #print $_;
		$line=$_;
		if($line=~ /$HDADEV/)
		{
			push(@hda_line, $line);
		}	
    }

	return @hda_line;
}
sub getDmesg
{
	my $result;
	my @dmesg_dump;
	`sysctl dev.hdac.0.pindump=1`;
	$result = `dmesg 2>&1`;
	@dmesg_dump=split("\n", $result);
	
	return @dmesg_dump;

}

sub trim
{
  my($string)= @_;
  $string =~ s/^\s+//;
  $string =~ s/\s+$//;
  return $string;
}
