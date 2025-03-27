--ジェムナイト・ジルコニア
--Gem-Knight Zirconia
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GEM_KNIGHT),aux.FilterBoolFunctionEx(Card.IsRace,RACE_ROCK))
end
s.material_setcode={SET_GEM,SET_GEM_KNIGHT}