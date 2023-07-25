 sub EVENT_SAY {
  my $charKey = $client->CharacterID() . "-MAO-Progress";
  my $progress = quest::get_data($charKey);
  if ($text=~/hail/i && !$client->GetGM()) {
    POPUP_DISPLAY();
  } elsif ($client->GetGM()) {
    my $dbh = plugin::LoadMysql();
    my $query = $dbh->prepare('SELECT * FROM items WHERE items.id < 999999;');
    $query->execute();

    quest::debug("Executed Query...");

    my $column_names = $query->{NAME};
    my @rows;

    while (my $row = $query->fetchrow_hashref()) {
        my %new_row = %$row;
        
        # Here you can add the code to modify %new_row, for example:
        # $new_row{'id'} = new_id_function($new_row{'id'}); 

        $new_row{'id'} = $new_row{'id'} + 1000000;
        $new_row{'Name'} = $new_row{'Name'} . ' +1';

        quest::debug("Trying to generate new ID: $new_row{'id'}");

        push @rows, \%new_row;
    }

    $query->finish();

    foreach my $row (@rows) {
        my @columns = keys %$row;
        my @values = values %$row;
        my $placeholders = join ", ", map { $dbh->quote($_) } @values;
        my $column_list = join ", ", @columns;
        my $sql = "REPLACE INTO items ($column_list) VALUES ($placeholders)";
        $dbh->do($sql);
    }

    $dbh->disconnect();
  }
 }

sub POPUP_DISPLAY {

  my $yellow = plugin::PWColor("Yellow");
  my $green = plugin::PWColor("Green"); 

  my $discord = "Server Discord: " . plugin::PWHyperLink("https://discord.com/invite/5cFCA7TVgA","5cFCA7TVgA") . "<br><br>";
  my $header = $yellow . plugin::PWAutoCenter("Welcome to Pyrelight!") . "</c><br><br>";

  my $desc = "Pyrelight is a solo-balanced server, meant to offer a challenging experience for veteran players and an alternative take on the 'solo progression' mold.<br><br>
              For more information, please join the server discord and read the " . $green . "#server-info</c> channel.";

  my $text = $header .
             $discord .
             $desc;  
  quest::popup('', $text);
}