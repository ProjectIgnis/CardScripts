--一撃必殺！居合いドロー (VG)
--Slash Draw (VG)
--Clean up by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--discard deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={71344451}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return ct>0 and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>ct and Duel.IsPlayerCanDiscardDeck(tp,ct)
		and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if ct>0 and Duel.DiscardDeck(tp,ct,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		if Duel.Draw(tp,1,REASON_EFFECT)>0 then
			local tc=Duel.GetOperatedGroup():GetFirst()
			Duel.ConfirmCards(1-tp,tc)
			if tc:IsCode(71344451) and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
				local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
				Duel.Destroy(sg,REASON_EFFECT)
				local tg=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_GRAVE)
				if #tg>0 then
					local dam=#tg*1000
					Duel.Damage(1-tp,dam,REASON_EFFECT)
				end
			end
		else
			Duel.ShuffleHand(tp)
		end  
	end
end