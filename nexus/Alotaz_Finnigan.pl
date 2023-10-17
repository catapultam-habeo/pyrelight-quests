sub EVENT_SAY {
    my $characterID = $client->CharacterID();
    my $suffix = "-K";

    # Fetch the zone data using our abstracted function
    my $teleport_zones = plugin::get_zone_data_for_character($characterID, $suffix);

    # Add static data
    $teleport_zones->{"The Dreadlands (Great Combine Spires [Default])"} = ["dreadlands", "The Dreadlands (Great Combine Spires [Default])", 9651, 3052, 1048, 489];

    # Iksar
    if ($client->GetRace() == 128) {
        $teleport_zones->{"Cabilis (The Block [Racial])"} = ["cabeast", "Cabilis (The Block [Racial])", 63, 679, -10, 285];
    }

    if ($text =~ /hail/i) {
        plugin::NPCTell("Hail, traveler. I can transport you to the Great Spires of Kunark, or any other location on that continent that you've become attuned to.");
        $client->Message(257, " ------- Select a Destination ------- ");
        
        foreach my $t (sort keys %{$teleport_zones}) {
            $client->Message(257, "-> " . quest::saylink($teleport_zones->{$t}[1], 0, $t));
        }
    } elsif (exists($teleport_zones->{$text})) {
        $client->MovePC(quest::GetZoneID($teleport_zones->{$text}[0]), $teleport_zones->{$text}[2], $teleport_zones->{$text}[3], $teleport_zones->{$text}[4], $teleport_zones->{$text}[5]);
    }
}