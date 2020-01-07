--Battlefield Tragedy
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--send
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(s.ddtg)
	e3:SetOperation(s.ddop)
	c:RegisterEffect(e3)
end
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=PLAYER_NONE
	if Duel.GetActivityCount(tp,ACTIVITY_ATTACK)>0 and Duel.GetActivityCount(1-tp,ACTIVITY_ATTACK)>0 then
		p=PLAYER_ALL
	elseif Duel.GetActivityCount(tp,ACTIVITY_ATTACK)>0 then
		p=tp
	elseif Duel.GetActivityCount(1-tp,ACTIVITY_ATTACK)>0 then
		p=1-tp
	end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,p,5)
end
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local p=PLAYER_NONE
	if Duel.GetActivityCount(tp,ACTIVITY_ATTACK)>0 and Duel.GetActivityCount(1-tp,ACTIVITY_ATTACK)>0 then
		p=PLAYER_ALL
	elseif Duel.GetActivityCount(tp,ACTIVITY_ATTACK)>0 then
		p=tp
	elseif Duel.GetActivityCount(1-tp,ACTIVITY_ATTACK)>0 then
		p=1-tp
	end
	if p~=PLAYER_NONE then
		if p==PLAYER_ALL then
			Duel.DiscardDeck(tp,5,REASON_EFFECT)
			Duel.DiscardDeck(1-tp,5,REASON_EFFECT)
		else
			Duel.DiscardDeck(p,5,REASON_EFFECT)
		end
	end
end
