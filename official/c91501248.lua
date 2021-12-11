--禁忌の壺
--Pot of The Forbidden
local s,id=GetID()
function s.initial_effect(c)
	--FLIP: Activate one of the forbidden effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,2)
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	local b3=Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
	local b4=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil)
	if chk==0 then return b1 or b2 or b3 or b4 end
	local op=aux.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{b3,aux.Stringid(id,2)},
		{b4,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(2)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_DESTROY)
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	else
		e:SetCategory(CATEGORY_TODECK)
		Duel.SetTargetPlayer(tp)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	elseif op==2 then
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	elseif op==3 then
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(g,REASON_EFFECT)
	else
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local g=Duel.GetFieldGroup(p,0,LOCATION_HAND)
		if #g>0 then
			Duel.ConfirmCards(p,g)
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)
			local sg=g:FilterSelect(p,Card.IsAbleToDeck,1,1,nil)
			Duel.SendtoDeck(sg,nil,2,REASON_EFFECT)
			Duel.ShuffleHand(1-p)
		end
	end
end
