--無視加護
--Insect Neglect
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Negate the attack of an opponent's monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(function(e,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetCost(s.negatkcost)
	e1:SetTarget(s.negatktg)
	e1:SetOperation(function() Duel.NegateAttack() end)
	c:RegisterEffect(e1)
end
function s.negatkcostfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.negatkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.negatkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.negatkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.negatktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ac=Duel.GetAttacker()
		return ac:IsOnField() and ac:IsRelateToBattle()
	end
end