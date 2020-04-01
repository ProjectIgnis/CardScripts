--幻奏の音女アリア
local s,id=GetID()
function s.initial_effect(c)
	--cannot be target/battle indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x9b))
	e1:SetCondition(s.tgcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e2)
end
s.listed_series={0x9b}
function s.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
