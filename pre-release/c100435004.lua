--Ｔｈｅ Ｌｅｇｅｎｄ ｏｆ Ｔｉｃｋｅｔｓ
--The Legend of Tickets
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--Place it on top of the Deck during the End Phase of this turn
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(cc) Duel.HintSelection(cc,true) Duel.SendtoDeck(cc,nil,SEQ_DECKTOP,REASON_EFFECT) end)
	end
	local turn_ct=Duel.GetTurnCount()
	local ct=(Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_DRAW)) and 2 or 1
	--Draw 2 cards instead of 1 for your normal draw during your next Draw Phase
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_DRAW_COUNT)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function() return Duel.GetTurnCount()~=turn_ct end)
	e1:SetValue(2)
	e1:SetReset(RESET_PHASE|PHASE_DRAW|RESET_SELF_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end