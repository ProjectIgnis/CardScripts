--怠慢な壺
--Pot of Procrastination
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Draw cards equal to the number of cards your opponent controls, then if you drew 2 or more, place the same number -1 from your hand on the bottom of the Deck in any order. For the rest of this turn after this card resolves, you cannot activate "Pot of Procrastination"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local draw_count=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if chk==0 then return draw_count>0 and Duel.IsPlayerCanDraw(tp,draw_count) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,draw_count)
	if draw_count>=2 then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,draw_count-1,tp,LOCATION_HAND)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local draw_count=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if draw_count>0 and Duel.Draw(tp,draw_count,REASON_EFFECT)>0 and draw_count>=2 then
		Duel.ShuffleHand(tp)
		local return_count=draw_count-1
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,return_count,return_count,nil)
		if #g>0 then
			Duel.BreakEffect()
			if Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and return_count>=2 then
				Duel.SortDeckbottom(tp,tp,return_count)
			end
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--For the rest of this turn after this card resolves, you cannot activate "Pot of Procrastination"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re) return re:GetHandler():IsCode(id) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end