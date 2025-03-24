--スネーク・チョーク
--Serpent Suppression
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Battle indestructable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(aux.TargetBoolFunction(Card.IsSetCard,SET_REPTILIANNE))
	c:RegisterEffect(e2)
end
s.listed_series={SET_REPTILIANNE}
function s.indtg(e,c)
	return c:GetAttack()==0 and c:IsAttackPos()
end