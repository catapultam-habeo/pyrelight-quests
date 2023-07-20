sub EVENT_SAY {
   my $response = "";
   my $clientName = $client->GetCleanName();
   my $link_epic = "[".quest::saylink("relic", true, "response_epic")."]";
   my $link_custom = "[".quest::saylink("custom work", true, "response_custom")."]";
   if($text=~/hail/i) {
      if (!$client->GetData("Tawnos")) {
         $response = "Hail, $clientName. I am Tawnos, master artificer and enchanter! I am still setting up my facilities here in the Bazaar, but I can already offer some services. ";
      } else {
         $response = "Welcome back, $clientName. What can I do for you today? ";
      }
      $response = $response . "If you have acquired a $link_epic, I can offer you an corresponding ornament for it. If you are interested in $link_custom, we should talk!";
   }
}

sub EVENT_ITEM {
  plugin::return_items(\%itemcount);
}