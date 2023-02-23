sub EVENT_DAMAGE_GIVEN {
    if ($npc->IsPet()) {
        $entity_list->GetMobByID($entity_id)->AddToHateList($npc->GetOwner());
    }        
}

sub EVENT_SPAWN
{
    if ($npc->IsPet()) {  
        EVAL_PET($npc);
    }
}

sub EVENT_ENTER
{
    if ($npc->IsPet()) {
        quest::debug("I'm a pet, I zoned: " . $npc->GetCleanName());
    }  
}

sub EVAL_PET
{
        my $pet = shift;
        if ($pet->GetOwnerID()) {
                my $owner = $entity_list->GetClientByID($pet->GetOwnerID());
                
                my $owner_spelldmg = ($owner->GetSpellDamage() / 100);
                my $owner_healamt = ($owner->GetHealAmount() / 100);

                $pet->ModifyNPCStat("spellscale",$owner->GetSpellDamage());
                $pet->ModifyNPCStat("healscale",$owner->GetHealAmount());

                $pet->ModifyNPCStat("max_hp", $pet->GetMaxHP() * ($owner_spelldmg + 1));

                $pet->SetMaxHP();
        }
}