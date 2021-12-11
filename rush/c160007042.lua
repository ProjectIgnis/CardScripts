--超魔基地マグナム・オーバーベース 
-- Super Magibase Magnum Overbase
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcond)
	c:RegisterEffect(e1)
	--Decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.tg)
	e2:SetValue(400)
	c:RegisterEffect(e2)
	--trap indestructable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indesval)
	c:RegisterEffect(e1)
end
function s.actcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
function s.tg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(7) and c:IsFaceup()
end
function s.indtg(e,c)
	return c:IsRace(RACE_MACHINE) and c:IsLevel(10) and c:IsFaceup()
end
function s.indesval(e,re)
	return re:GetHandler():IsType(TYPE_TRAP+TYPE_SPELL)
end