--Toon Summoned Skull
local s,id=GetID()
function s.initial_effect(c)
	--no type/attribute/level
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetValue(0)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	c:RegisterEffect(e2)
	c:SetStatus(STATUS_NO_LEVEL,true)
	--direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetCondition(s.dircon)
	c:RegisterEffect(e3)
end
s.listed_names={id+1}
s.mark=0
function s.dirfilter(c)
	return c:IsFaceup() and c:IsCode(id+1)
end
function s.dircon(e)
	return Duel.IsExistingMatchingCard(s.dirfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
