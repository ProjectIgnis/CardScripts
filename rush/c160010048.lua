--アメガロポリス
--Rainapolis
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcond)
	c:RegisterEffect(e1)
	--Increase ATK of Aqua monsters by 200
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_AQUA))
	e2:SetValue(200)
	c:RegisterEffect(e2)
	--Decrease ATK of non-Aqua monsters by 200
	local e3=e2:Clone()
	e3:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_AQUA)))
	e3:SetValue(-200)
	c:RegisterEffect(e3)
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(aux.FaceupFilter(Card.IsRace,RACE_AQUA),e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)>=2
end