--コンバート・コンタクト
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x1f}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.filter(c)
	return c:IsSetCard(0x1f) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil)
	local g2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g1>0 and #g2>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg1=g1:Select(tp,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		if Duel.SendtoGrave(sg1,REASON_EFFECT)==2 then
			local g=Duel.GetOperatedGroup()
			if g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<2 then return end
			Duel.ShuffleDeck(tp)
			Duel.BreakEffect()
			Duel.Draw(tp,2,REASON_EFFECT)
		end
	end
end
