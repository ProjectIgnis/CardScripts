--古の扉
--Ancient Gate
local s,id=GetID()
function s.initial_effect(c)
	--Can only be played by "Ancient Key"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SSET)
	c:RegisterEffect(e1)
end
s.listed_names={511000124} --"Ancient Key"
