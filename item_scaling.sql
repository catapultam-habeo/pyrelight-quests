-- Do initial stat seeding

USE peq;

SET @SCALE_FACTOR = 1.5;
SET @MOD2_THRESHOLD = 5;
SET @HEROIC_T = 2;

-- Decrease Aggro Range
UPDATE peq.npc_types, ref.npc_types
   SET peq.npc_types.aggroradius = Floor(ref.npc_types.aggroradius * 0.6),
	    peq.npc_types.assistradius = Floor(ref.npc_types.assistradius * 0.6)
 WHERE peq.npc_types.id = ref.npc_types.id;

-- Apply Augment Schema
UPDATE db_str SET value = "1 (General)" 			      WHERE id = 1  AND type = 16;
UPDATE db_str SET value = "2 (Activated Effect)" 	   WHERE id = 2  AND type = 16;
UPDATE db_str SET value = "3 (Worn Effect)" 		      WHERE id = 3  AND type = 16;
UPDATE db_str SET value = "4 (Combat Effect)"		   WHERE id = 4  AND type = 16;
UPDATE db_str SET value = "20 (Weapon Ornamentation)" WHERE id = 20 AND type = 16;
UPDATE db_str SET value = "21 (Armor Ornamentation)"  WHERE id = 21 AND type = 16;

-- Remove Models from non-ornaments
UPDATE items SET idfile = "IT63" WHERE itemtype = 54 AND NOT augtype & (524288|1048576);

-- Configure Item Slots
-- Remove All Aug Slots

UPDATE items
   SET augslot1type = 0, 
	   augslot2type = 0, 
	   augslot3type = 0, 
	   augslot4type = 0, 
	   augslot5type = 0,
	   augslot6type = 0, 	   
	   augslot1visible = 0,
	   augslot2visible = 0,
	   augslot3visible = 0,
	   augslot4visible = 0,
	   augslot5visible = 0,
	   augslot6visible = 0
	WHERE items.id > 0;

-- Type 21 on Vis Slots
UPDATE items
   SET augslot6type = 21,
       augslot6visible = 1
 WHERE itemtype != 54
   AND slots & 923268 > 0
   AND races > 0;
   
-- Type 20 on Primary\Secondary\Ranged slots
UPDATE items
   SET augslot6type = 20,
       augslot6visible = 1
 WHERE itemtype != 54
   AND slots & 26624 > 0
   AND races > 0;   

-- All Items
UPDATE items
   SET augslot1type = 1, -- Type 1
	   augslot2type = 2, -- Type 2
	   augslot3type = 3, -- Type 3
	   augslot1visible = 1,
	   augslot2visible = 1,
	   augslot3visible = 1
 WHERE itemtype != 54
   AND slots > 0
   AND races > 0
   AND slots != 4194304;
   
-- Pri\Sec\Ranged Weapons
UPDATE items
   SET augslot4type = 4,
       augslot5type = 4,
	   augslot4visible = 1,
	   augslot5visible = 1
 WHERE itemtype != 54
   AND slots & (8192|16384|2048) 
   AND races > 0
   AND ( itemtype <= 5 OR itemtype = 35 OR itemtype = 45 ); 

   
-- Remove Type 2 from items with Click effects
UPDATE items
   SET augslot2type = 0,
       augslot2visible = 1
 WHERE itemtype != 54
   AND clickeffect > 0;
   
-- Remove First Type 3 from items with Focus or Worn effects
UPDATE items
   SET augslot3type = 0,
       augslot3visible = 1
 WHERE itemtype != 54
   AND ( focuseffect > 0
    OR   worneffect  > 0 );

-- Remove first type 4 from items with proc effects
UPDATE items
   SET augslot4type = 0,
       augslot4visible = 1
 WHERE itemtype != 54
   AND proceffect > 0;
   
-- Pri\Sec Caster-Only Items
UPDATE items
   SET augslot4type = 3,
       augslot5type = 3,
	   augslot4visible = 1,
	   augslot5visible = 1
 WHERE itemtype != 54
   AND slots & 24576 > 0 
   AND races > 0
   AND ( classes & (2|32|512|1024|2048|4096|8192) AND NOT classes & (1|4|8|16|64|128|256|16384|32768) );
   
-- All Augments Become Type 1
UPDATE items
   SET augtype = 1
 WHERE itemtype = 54 AND NOT augtype & (524288|1048576);
 
-- Augments with Procs Become Type 4
UPDATE items
   SET augtype = 8
 WHERE itemtype = 54
   AND proceffect > 0;

-- Augments with a Focus or a Worn Effect becomes a Type 3
UPDATE items
   SET augtype = 4
 WHERE itemtype = 54
   AND ( worneffect > 0 OR focuseffect > 0 );
   
-- Augments with activated effects become type 2
UPDATE items
   SET augtype = 2
 WHERE itemtype = 54
   AND clickeffect > 0;
   
-- Dump all stats from Augs other than Type 1
UPDATE items
   SET ac = 0, hp = 0, mana = 0, endur = 0, spelldmg = 0, healamt = 0,
       astr = 0, adex = 0, aagi = 0, asta = 0, aint = 0, awis = 0, acha = 0,
	   regen = 0, manaregen = 0, enduranceregen = 0,
	   fr = 0, cr = 0, mr = 0, dr = 0, pr = 0,
	   heroic_str = 0, heroic_sta = 0, heroic_dex = 0, heroic_agi = 0, heroic_int = 0, heroic_wis = 0, heroic_cha = 0,
	   heroic_fr = 0, heroic_cr = 0, heroic_mr = 0, heroic_dr = 0, heroic_pr = 0,
	   shielding = 0, spellshield = 0, dotshielding = 0, stunresist = 0, strikethrough = 0, attack = 0, accuracy = 0, avoidance = 0,
	   damageshield = 0, dsmitigation = 0, haste = 0, clairvoyance = 0, damage = 0
 WHERE itemtype = 54
   AND augtype & 1 = 0;

-- Reset primary stats
UPDATE peq.items, ref.items
   SET peq.items.astr = ref.items.astr, peq.items.asta = ref.items.asta, peq.items.adex = ref.items.adex, peq.items.aagi = ref.items.aagi,
       peq.items.aint = ref.items.aint, peq.items.awis = ref.items.awis, peq.items.acha = ref.items.acha
 WHERE peq.items.id = ref.items.id; 
 
-- Increase AC on visible-slot items
UPDATE peq.items, ref.items
   SET peq.items.ac = Abs(Ceil(ref.items.ac * 2))
 WHERE peq.items.id = ref.items.id
   AND ref.items.ac > 0
   AND ref.items.slots & (4|128|512|1024|4096|131072|262144|524288);

-- Increase AC on non-visible-slot items
UPDATE peq.items, ref.items
   SET peq.items.ac = Abs(Ceil(ref.items.ac * @SCALE_FACTOR))
 WHERE peq.items.id = ref.items.id
   AND ref.items.ac > 0
   AND ref.items.slots & (1|2|8|16|32|64|256|2048|8192|16384|32768|1048576);
   
-- Increase Weapon Damage
UPDATE peq.items, ref.items
   SET peq.items.damage = Ceil(ref.items.damage * @SCALE_FACTOR)
 WHERE peq.items.id = ref.items.id
   AND ref.items.damage > 0
   AND (ref.items.itemtype = 0 OR ref.items.itemtype = 2 OR ref.items.itemtype = 3 OR ref.items.itemtype = 45);
   
-- Increase 2H Weapon\Aug Damage
UPDATE peq.items, ref.items
   SET peq.items.damage = Ceil(ref.items.damage * 2)
 WHERE peq.items.id = ref.items.id
   AND ref.items.damage > 0
   AND (ref.items.itemtype = 1 OR ref.items.itemtype = 4 OR ref.items.itemtype = 35 OR ref.items.itemtype = 54);

-- Increase Elemental Damage
UPDATE peq.items, ref.items
   SET peq.items.elemdmgamt = Ceil(ref.items.elemdmgamt * 5)
 WHERE peq.items.id = ref.items.id
   AND ref.items.elemdmgamt > 0;

-- Increase Bane Damage
UPDATE peq.items, ref.items
   SET peq.items.elemdmgamt = Ceil(ref.items.banedmgamt * 5)
 WHERE peq.items.id = ref.items.id
   AND ref.items.banedmgamt > 0;
   
-- Increase Backstab Damage
UPDATE peq.items, ref.items
   SET peq.items.backstabdmg = Ceil(ref.items.backstabdmg * 2)
 WHERE peq.items.id = ref.items.id
   AND ref.items.backstabdmg > 0;
   
-- Add HP to items based on pre-existing primary stats
UPDATE peq.items, ref.items
   SET peq.items.hp = (ref.items.hp * @SCALE_FACTOR) + Abs(ref.items.astr + ref.items.asta + ref.items.adex + ref.items.aagi + ref.items.aint + ref.items.awis + ref.items.acha)
 WHERE peq.items.id = ref.items.id
   AND ( ref.items.astr > 0 OR
		 ref.items.asta > 0 OR
		 ref.items.adex > 0 OR
		 ref.items.aagi > 0 OR
		 ref.items.aint > 0 OR
	 	 ref.items.awis > 0 ); 
 
-- Add Int\Wis based on pre-existing Mana
UPDATE peq.items, ref.items
   SET peq.items.aint = ref.items.aint + Ceil(ref.items.mana / 10)
 WHERE peq.items.id = ref.items.id AND ref.items.mana > 0
   AND ref.items.aint >= ref.items.awis
   AND ref.items.aint <= (ref.items.mana / 10);
		 
UPDATE peq.items, ref.items
   SET peq.items.awis = ref.items.awis + Ceil(ref.items.mana / 10)
 WHERE peq.items.id = ref.items.id AND ref.items.mana > 0
   AND ref.items.aint <= ref.items.awis
   AND ref.items.awis <= (ref.items.mana / 10);   
 
-- Add HP Regen based on pre-existing STA
UPDATE peq.items, ref.items
   SET peq.items.regen = ref.items.regen + Floor(ref.items.asta / @MOD2_THRESHOLD)
 WHERE peq.items.id = ref.items.id
   AND ref.items.asta >= @MOD2_THRESHOLD;
   
-- Add Heroic STR based on pre-existing STR
UPDATE peq.items, ref.items
   SET peq.items.heroic_str = Least(99,ref.items.heroic_str + Floor(peq.items.astr / @HEROIC_T)),
       peq.items.astr = peq.items.astr - Floor(peq.items.heroic_str)
 WHERE peq.items.id = ref.items.id
   AND ref.items.astr >= @HEROIC_T;
   
-- Add Heroic STA based on pre-existing STA
UPDATE peq.items, ref.items
   SET peq.items.heroic_sta = Least(99,ref.items.heroic_sta + Floor(peq.items.asta / @HEROIC_T)),
       peq.items.asta = peq.items.asta - Floor(peq.items.heroic_sta)
 WHERE peq.items.id = ref.items.id
   AND ref.items.asta >= @HEROIC_T;
   
-- Add Heroic DEX based on pre-existing DEX
UPDATE peq.items, ref.items
   SET peq.items.heroic_dex = Least(99,ref.items.heroic_dex + Floor(peq.items.adex / @HEROIC_T)),
       peq.items.adex = peq.items.adex - Floor(peq.items.heroic_dex)
 WHERE peq.items.id = ref.items.id
   AND ref.items.adex >= @HEROIC_T;
   
-- Add Heroic AGI based on pre-existing AGI
UPDATE peq.items, ref.items
   SET peq.items.heroic_agi = Least(99,ref.items.heroic_agi + Floor(peq.items.aagi / @HEROIC_T)),
       peq.items.aagi = peq.items.aagi - Floor(peq.items.heroic_agi)
 WHERE peq.items.id = ref.items.id
   AND ref.items.aagi >= @HEROIC_T;
   
-- Add Heroic INT based on pre-existing INT
UPDATE peq.items, ref.items
   SET peq.items.heroic_int = Least(99,ref.items.heroic_int + Floor(peq.items.aint / @HEROIC_T)),
       peq.items.aint = peq.items.aint - Floor(peq.items.heroic_int)
 WHERE peq.items.id = ref.items.id
   AND ref.items.aint >= @HEROIC_T;

-- Add Heroic WIS based on pre-existing WIS
UPDATE peq.items, ref.items
   SET peq.items.heroic_wis = Least(99,ref.items.heroic_wis + Floor(peq.items.awis / @HEROIC_T)),
       peq.items.awis = peq.items.awis - Floor(peq.items.heroic_wis)
 WHERE peq.items.id = ref.items.id
   AND ref.items.awis >= @HEROIC_T; 
   
-- Add extra Heal Amount to non-augs for wis-casters
UPDATE peq.items, ref.items
   SET peq.items.spelldmg = Floor(peq.items.spelldmg * @SCALE_FACTOR)
 WHERE peq.items.id = ref.items.id
   AND peq.items.itemtype != 54
   AND peq.items.classes & (2|32|512);

-- Scale up primary stats by SCALE_FACTOR
UPDATE peq.items
   SET astr = Ceil(astr * @SCALE_FACTOR), asta = Ceil(asta * @SCALE_FACTOR), adex = Ceil(adex * @SCALE_FACTOR),
	   aagi = Ceil(aagi * @SCALE_FACTOR), aint = Ceil(aint * @SCALE_FACTOR), awis = Ceil(awis * @SCALE_FACTOR),
	   acha = Ceil(acha * @SCALE_FACTOR)
 WHERE slots > 0 AND classes > 0 AND races > 0;

-- Round up HP
UPDATE peq.items
   SET peq.items.hp = Ceil(peq.items.hp / 5) * 5
 WHERE peq.items.hp > 0;
-- Round up Mana
 
UPDATE peq.items
   SET peq.items.mana = Ceil(peq.items.mana / 5) * 5
 WHERE peq.items.mana > 0;
 
-- Add Spell Damage to non-augs
UPDATE peq.items, ref.items
   SET peq.items.spelldmg = ref.items.spelldmg + Floor(Greatest(peq.items.aint, peq.items.awis, peq.items.astr, peq.items.adex) / 3) + Floor(peq.items.hp / 25),
       peq.items.healamt = ref.items.healamt + Floor(Greatest(peq.items.acha, peq.items.awis, peq.items.aagi, peq.items.asta) / 3) + Floor(peq.items.hp / 25)
 WHERE peq.items.id = ref.items.id
   AND peq.items.itemtype != 54;
   
-- Add extra Spell Damage to non-augs for casters
UPDATE peq.items, ref.items
   SET peq.items.spelldmg = Floor(peq.items.spelldmg * 1.25)
 WHERE peq.items.id = ref.items.id
   AND peq.items.itemtype != 54
   AND peq.items.classes & (1024|2048|4096|8192|2|32|512);
   
-- Add extra Spell Damage \ Heal Amount to 2HB for casters
UPDATE peq.items, ref.items
   SET peq.items.spelldmg = Floor(peq.items.spelldmg * 2), peq.items.healamt = Floor(peq.items.healamt * 2)
 WHERE peq.items.id = ref.items.id
   AND peq.items.itemtype = 4
   AND peq.items.classes & (1024|2048|4096|8192|2|32|512);
 
 