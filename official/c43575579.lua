--アフター・グロー
--Afterglow
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.cfilter(c)
	return c:IsCode(id) and c:IsAbleToRemove() and (not c:IsLocation(LOCATION_ONFIELD) or c:IsFaceup())
end
function s.tdfilter(c)
	return c:IsCode(id) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_DECK|LOCATION_ONFIELD|LOCATION_HAND|LOCATION_GRAVE,0,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		if Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_REMOVED,0,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local td=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
			Duel.SendtoDeck(td,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetProperty(EFFECT_FLAG_DELAY)
			e1:SetCode(EVENT_DRAW)
			e1:SetCountLimit(1)
			e1:SetCondition(s.con)
			e1:SetOperation(s.op)
			if Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_DRAW) then
				e1:SetLabel(Duel.GetTurnCount())
				e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,2)
			else
				e1:SetLabel(0)
				e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN)
			end
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and (r&REASON_RULE)~=0 and Duel.IsTurnPlayer(tp) and Duel.GetTurnCount()~=e:GetLabel() 
		and Duel.IsPhase(PHASE_DRAW) and #eg>0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if #eg<1 then return end
	Duel.ConfirmCards(1-tp,eg)
	local g=eg:Filter(Card.IsCode,nil,id)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Damage(1-tp,4000,REASON_EFFECT)
	end
	Duel.ShuffleHand(tp)
end