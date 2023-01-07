--Go-D/D World
--Made by Beetron-1 Beetletop
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_SETCODE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetCondition(s.changecon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaf))
	e2:SetValue(0x20af)
	c:RegisterEffect(e2)
end
s.listed_series={0xaf,0x20af}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(0,1)
	Duel.RegisterEffect(e1,tp)
end
function s.changefilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
function s.changecon(e)
	return Duel.IsExistingMatchingCard(s.changefilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,5,nil)
end