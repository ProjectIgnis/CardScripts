--サイレント・ラーニング
--Silent Learning
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 1 set card in opponent's S/T zones
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsLevelAbove,tp,LOCATION_GRAVE,0,nil,5)
	return g:GetClassCount(Card.GetRace)>=3
end
function s.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_SZONE,1,e:GetHandler()) and Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.tdfilter(c)
	return c:IsLevelAbove(5) and c:IsAbleToDeck()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.ConfirmCards(tp,g)
	if g:GetFirst():IsTrap() then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if Duel.SendtoDeck(g2,nil,1,REASON_COST)>0 then
			local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
end