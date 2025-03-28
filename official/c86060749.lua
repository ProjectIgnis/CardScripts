--ストールターン
--Stall Turn
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) or not (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE)) then return false end
	if re:IsHasCategory(CATEGORY_DISABLE_SUMMON) then return true end
	local ex,tg,ct=Duel.GetOperationInfo(ev,CATEGORY_NEGATE)
	if not ex then return false end
	if ct>1 then
		for i=1,ev-1 do
			local ce=Duel.GetChainInfo(ev-i,CHAININFO_TRIGGERING_EFFECT)
			if ce and ce:IsSpellTrapEffect() and ce:IsHasType(EFFECT_TYPE_ACTIVATE) then
				return true
			end
		end
	elseif ct==1 then
		local ce=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
		return ce and ce:IsSpellTrapEffect() and ce:IsHasType(EFFECT_TYPE_ACTIVATE)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3 end
	Duel.DisableShuffleCheck()
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToDeck() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_TODECK,eg,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end