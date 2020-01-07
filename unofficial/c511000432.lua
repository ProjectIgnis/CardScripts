--カボチャの馬車 (Anime)
--Pumpkin Carriage (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.datg)
	c:RegisterEffect(e1)
end
s.listed_names={78527720}
function s.datg(e,c)
	return c:IsCode(78527720)
end