--女王親衛隊
--Queen's Bodyguard
local s,id=GetID()
function s.initial_effect(c)
	--at limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetTarget(s.atlimit)
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ALLURE_QUEEN}
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(SET_ALLURE_QUEEN)
end