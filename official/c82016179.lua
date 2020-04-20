--森羅の施し
--Sylvan Charity
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x90}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)==3 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,p,LOCATION_HAND,0,nil)
		if #g>1 and g:IsExists(Card.IsSetCard,1,nil,0x90) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			local sg1=g:FilterSelect(p,Card.IsSetCard,1,1,nil,0x90)
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			local sg2=g:Select(p,1,1,sg1:GetFirst())
			sg1:Merge(sg2)
			Duel.ConfirmCards(1-p,sg1)
			Duel.SendtoDeck(sg1,nil,SEQ_DECKTOP,REASON_EFFECT)
			Duel.SortDecktop(p,p,2)
		else
			local hg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
			Duel.ConfirmCards(1-p,hg)
			local ct=Duel.SendtoDeck(hg,nil,SEQ_DECKTOP,REASON_EFFECT)
			Duel.SortDecktop(p,p,ct)
		end
	end
end
