sub EVENT_SPELL_EFFECT_CLIENT {
    if ($client->IsClient()) {
        my $tclass = 11; #Necromancer
        my $mclass = $client->GetClass();
        if ($mclass==$tclass) {
            $client->Message(13, "Ability Failed. You are already a ". quest::getclassname($tclass));
        } else {        
            quest::permaclass($tclass);
        }
    }
}