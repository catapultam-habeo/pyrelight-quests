
function ZMSB_Spawn(e)
  eq.set_next_hp_event(90);
end

function ZMSB_Combat(e)
  if (e.joined == true) then
    e.self:Say("Come you fools! Show me your strongest warrior and I will show you my first victim.");
    eq.set_timer("rage", 35 * 1000);
    
  else
    -- Wipe Mechanics
	eq.stop_timer("check");
    eq.stop_timer("rage");
	-- door should only unlock when he reaches 100%
    eq.get_entity_list():FindDoor(8):SetLockPick(0);
    eq.spawn2(298018, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()); -- NPC: Zun`Muram_Shaldn_Boc
    eq.depop();
  end
end

function ZMSB_Timer(e)
  if (e.timer == "rage_stop") then
    eq.stop_timer("rage_stop");
    eq.set_timer("rage", 35 * 1000);
    eq.zone_emote(15,"Zun`Muram Shaldn Boc looks weakened as the rage ends.");
    e.self:ModifyNPCStat("min_hit", "1470");
    e.self:ModifyNPCStat("max_hit", "4700");
  --attack delay to 1.9s
    e.self:ModifyNPCStat("attack_delay","19");
  
  elseif (e.timer == "rage") then
    eq.stop_timer("rage");
    eq.set_timer("rage_stop", 50 * 1000);
    eq.zone_emote(15,"Zun`Muram Shaldn Boc starts to foam at the mouth as he enters a blind rage.");
    if (e.self:GetHPRatio() >= 90) then
        --need to parse 100% rage
	e.self:ModifyNPCStat("min_hit", "1520");
        e.self:ModifyNPCStat("max_hit", "4850");
        e.self:ModifyNPCStat("attack_delay","16");
    elseif (e.self:GetHPRatio() < 90 and e.self:GetHPRatio() >= 80) then
	e.self:ModifyNPCStat("min_hit", "1558");
        e.self:ModifyNPCStat("max_hit", "4978");
        e.self:ModifyNPCStat("attack_delay","15");
    elseif (e.self:GetHPRatio() < 80 and e.self:GetHPRatio() >= 70) then
	e.self:ModifyNPCStat("min_hit", "1612");
        e.self:ModifyNPCStat("max_hit", "5127");
        e.self:ModifyNPCStat("attack_delay","14");
    elseif (e.self:GetHPRatio() < 70 and e.self:GetHPRatio() >= 60) then
	e.self:ModifyNPCStat("min_hit", "1666");
        e.self:ModifyNPCStat("max_hit", "5276");
        e.self:ModifyNPCStat("attack_delay","13");
    elseif (e.self:GetHPRatio() < 60 and e.self:GetHPRatio() >= 50) then
	e.self:ModifyNPCStat("min_hit", "1721");
        e.self:ModifyNPCStat("max_hit", "5426");
        e.self:ModifyNPCStat("attack_delay","12");
    elseif (e.self:GetHPRatio() < 50 and e.self:GetHPRatio() >= 40) then
	e.self:ModifyNPCStat("min_hit", "1775");
        e.self:ModifyNPCStat("max_hit", "5575");
        e.self:ModifyNPCStat("attack_delay","12");
    elseif (e.self:GetHPRatio() < 40 and e.self:GetHPRatio() >= 30) then
	e.self:ModifyNPCStat("min_hit", "1829");
        e.self:ModifyNPCStat("max_hit", "5724");
        e.self:ModifyNPCStat("attack_delay","11");
    elseif (e.self:GetHPRatio() < 30 and e.self:GetHPRatio() >= 20) then
	e.self:ModifyNPCStat("min_hit", "1883");
        e.self:ModifyNPCStat("max_hit", "5873");
        e.self:ModifyNPCStat("attack_delay","10");
    elseif (e.self:GetHPRatio() < 20 and e.self:GetHPRatio() >= 10) then
	e.self:ModifyNPCStat("min_hit", "1938");
        e.self:ModifyNPCStat("max_hit", "6023");
        e.self:ModifyNPCStat("attack_delay","9");
    elseif (e.self:GetHPRatio() < 10) then
	e.self:ModifyNPCStat("min_hit", "1992");
        e.self:ModifyNPCStat("max_hit", "6172");
        e.self:ModifyNPCStat("attack_delay","8");
	end
elseif (e.timer == "check") then
		
		local instance_id = eq.get_zone_instance_id();
		e.self:ForeachHateList(
		  function(ent, hate, damage, frenzy)
			if(ent:IsClient() and ent:GetX() < 293 or ent:GetX() > 448 or ent:GetY() < 270) then
			  local currclient=ent:CastToClient();
				--e.self:Shout("You will not evade me " .. currclient:GetName())
				currclient:MovePCInstance(298,instance_id, e.self:GetX(),e.self:GetY(),e.self:GetZ(),0); -- Zone: tacvi
				currclient:Message(5,"Zun`Muram Shaldn Boc says, 'You cannot run from your fate, you must accept it.");
			end
		  end
		);
  end
end

function ZMSB_Hp(e)

  if (e.hp_event == 90) then
    eq.get_entity_list():FindDoor(8):SetLockPick(-1);
    -- he should start checking for players on hate list outside room here
	eq.set_timer("check", 1 * 1000);
  end
end

function ZMSB_Death(e)
  eq.signal(298223, 298018); -- NPC: zone_status
  eq.get_entity_list():FindDoor(8):SetLockPick(0);

  e.other:Message(12,"The creature's two heads face each other just before it falls to the floor, shaking the very foundation of the temple. Now there is nothing that stands between you and the being in charge of this invading army. ");
end

function event_encounter_load(e)
  eq.register_npc_event('zmsb', Event.spawn,          298018, ZMSB_Spawn);
  eq.register_npc_event('zmsb', Event.combat,         298018, ZMSB_Combat);
  eq.register_npc_event('zmsb', Event.timer,          298018, ZMSB_Timer);
  eq.register_npc_event('zmsb', Event.hp,             298018, ZMSB_Hp);
  eq.register_npc_event('zmsb', Event.death_complete, 298018, ZMSB_Death);
end
