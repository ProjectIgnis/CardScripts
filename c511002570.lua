--Dance of the Guardian
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp)
end
function s.revfilter(c)
	return not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if chk==0 then return (g:IsExists(s.revfilter,1,nil) or g:IsExists(Card.IsType,1,nil,TYPE_MONSTER)) 
		and Duel.IsPlayerCanDraw(tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local tc=g:RandomSelect(tp,1):GetFirst()
	if tc then
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsType(TYPE_MONSTER) then
			if Duel.NegateAttack() and Duel.SendtoGrave(tc,REASON_EFFECT)>0 then
				Duel.BreakEffect()
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		else
			Duel.ShuffleHand(1-tp)
		end
	end
end
