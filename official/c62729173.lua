--インヴェルズ万能態
--Steelswarm Genome
local s,id=GetID()
function s.initial_effect(c)
	--double tribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DOUBLE_TRIBUTE)
	e1:SetValue(s.condition)
	c:RegisterEffect(e1)
end
s.listed_series={SET_STEELSWARM}
function s.condition(e,c)
	return c:IsSetCard(SET_STEELSWARM)
end