--聖邪のステンドグラス
--Stained Glass of the Valiant
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK+CATEGORY_HANDES+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsRace(RACE_FAIRY+RACE_FIEND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 
		and ((g:IsExists(Card.IsRace,1,nil,RACE_FAIRY) and Duel.IsPlayerCanDraw(tp,3)) 
		or (g:IsExists(Card.IsRace,1,nil,RACE_FIEND) and Duel.IsPlayerCanDraw(1-tp,1))) end
	if g:IsExists(Card.IsRace,1,nil,RACE_FAIRY) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_HAND)
	end
	if g:IsExists(Card.IsRace,1,nil,RACE_FIEND) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local fg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if fg:IsExists(Card.IsRace,1,nil,RACE_FAIRY) and Duel.Draw(tp,3,REASON_EFFECT)==3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			Duel.SortDeckbottom(tp,tp,2)
		end
	end
	if fg:IsExists(Card.IsRace,1,nil,RACE_FIEND) then
		Duel.BreakEffect()
		if Duel.Draw(1-tp,1,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local dg=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):RandomSelect(1-tp,1)
			if Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)>0 and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT+REASON_DISCARD,nil)
			end
		end
	end
end