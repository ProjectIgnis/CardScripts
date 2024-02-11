--ＪＡＭ：Ｐセット！
--JAM:P Set!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_PSYCHIC) and c:IsLevelBelow(2) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
end
function s.rtdfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsAbleToDeck() and not c:IsMaximumModeSide()
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtdfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g1==0 then return end
	Duel.HintSelection(g1,true)
	if Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_COST)==0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectMatchingCard(tp,s.rtdfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g2>0 then
		g2=g2:AddMaximumCheck()
		Duel.HintSelection(g2,true)
		if Duel.SendtoDeck(g2,nil,SEQ_DECKTOP,REASON_EFFECT)==0 then return end
		if #g2>1 then Duel.SortDecktop(tp,1-tp,#g2) end
		if g1:GetFirst():IsCode(CARD_CAN_D) and Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g3=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_GRAVE,1,2,nil)
			Duel.HintSelection(g3,true)
			Duel.BreakEffect()
			Duel.SendtoDeck(g3,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
