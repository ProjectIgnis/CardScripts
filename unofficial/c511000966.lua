--Paternal Junk
local s,id=GetID()
function s.initial_effect(c)
	--atk - Maternal
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.valcon1)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--atk - Kid
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.valcon2)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
end
function s.vfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.valcon1(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.vfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,511000965)
end
function s.valcon2(e)
	local c=e:GetHandler()
	return Duel.IsExistingMatchingCard(s.vfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,511000964)
end
