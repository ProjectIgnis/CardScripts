--竜宮の白タウナギ
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MAT_RESTRICTION)
	e1:SetValue(aux.TargetBoolFunction(Card.IsRace,RACE_FISH))
	c:RegisterEffect(e1)
end
