--フレイム・ゴースト
--Flame Ghost
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Fusion summon procedure
	Fusion.AddProcMix(c,true,true,CARD_SKULL_SERVANT,40826495)
end
s.listed_names={CARD_SKULL_SERVANT}