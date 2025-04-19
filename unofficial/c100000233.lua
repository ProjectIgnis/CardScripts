--豪腕特急トロッコロッコ (Anime)
--Express Train Trolley Olley (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(800)
	c:RegisterEffect(e1)
end