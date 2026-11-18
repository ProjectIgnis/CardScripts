--希望の鼓動
--Utopian Hope
--Scripted by urielkama
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_UTOPIC}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_UTOPIC),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	--This turn, "Utopic" monsters on the field cannot be targeted by your opponent's Spell, Trap, or monster effects.
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_UTOPIC))
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--If a "Utopic" monster on the field is currently targeted by an opponent's card effect(s), negate those effects, and if you do, destroy those cards.
	local g=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_ONFIELD,nil)
	g:ForEach(function(tc) tc:NegateEffects(c,RESET_EVENT|RESETS_STANDARD,true) end)
	Duel.BreakEffect()
	Duel.Destroy(g,REASON_EFFECT)
end
function s.disfilter(c)
	return c:IsFaceup() and c:IsNegatable() and c:GetCardTarget() and c:GetCardTarget():GetCount()>0 and c:GetCardTarget():IsExists(aux.FaceupFilter(Card.IsSetCard,SET_UTOPIC),1,nil)
end
