--Mobius Glacier
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	--Pos Change
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINGEDBEAST+RACE_PLANT+RACE_DINOSAUR+RACE_INSECT))
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(POS_FACEUP_ATTACK)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e4)
end
s.listed_names={4929256}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(4929256)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
