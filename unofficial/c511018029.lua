--Bachibachibachi (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--get effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_XMATERIAL)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)	
end
