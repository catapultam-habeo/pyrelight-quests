
#These Must Be Defined
my $expedition_name = "Feat of Strength: Permafrost Keep";
my $dz_zone         = "permafrost";
my $explain_message = "This is the lair of the White Dragon, Vox. The Master requires three of her scales for his purposes. Proceed, slay the dragon and her minions, and be rewarded.";
my @target_list     = ( #Array of npc_type IDs that we need to kill. Add multiple times for quantity.
                        73057, #Lady Vox
                        73058
                      );

#These are Optional
my $reward          = 3;
my $key_required    = 0; #ID of key item                
my $target_level    = 52;

sub EVENT_SAY {
    quest::debug("wtf?");
    plugin::ProcessInstanceDialog(
        
    ); 
}