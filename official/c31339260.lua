--アンデット・ウォーリアー
--Zombie Warrior
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Fusion summon procedure
	Fusion.AddProcMix(c,true,true,CARD_SKULL_SERVANT,55550921)
end
s.listed_names={CARD_SKULL_SERVANT}