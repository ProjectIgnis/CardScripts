--穿撃竜バンカー・ストライク
--Thrust Dragon Bunker Strike
local s,id=GetID()
function s.initial_effect(c)
	--Draw and return to the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 and Duel.IsPlayerCanDraw(tp,#g) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,#g)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)>0 then
		--Effect
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			if Duel.Draw(tp,#g,REASON_EFFECT)>0 then
				Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
				local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,#g,#g,nil)
				local opt=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1))
				Duel.SortDecktop(tp,1-tp,3)
				if opt==0 then
					Duel.SendtoDeck(dg,nil,SEQ_DECKTOP,REASON_EFFECT)
					Duel.SortDecktop(tp,tp,#dg)
				elseif opt==1 then
					Duel.SendtoDeck(dg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
					Duel.SortDeckbottom(tp,tp,#dg)
				end
			end
		end
	end
end