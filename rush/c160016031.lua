--アニマジカ・ウィッチ
--Animagica Witch
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW|CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_EFFECT) and c:IsLevel(7,8) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local ft=2
	if not Duel.IsPlayerCanDraw(tp,2) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,ft,nil)
	if #g>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		--Effect
		local drawn=Duel.Draw(tp,#g,REASON_EFFECT)
		if drawn>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local dg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,drawn,drawn,nil)
			Duel.SendtoDeck(dg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end