--闇霊術－「欲」
--Dark Spirit Art - Greed
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsAttribute,1,false,nil,nil,ATTRIBUTE_DARK) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsAttribute,1,1,false,nil,nil,ATTRIBUTE_DARK)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.cfilter(c)
	return not c:IsPublic() and c:IsSpell()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.IsChainDisablable(0) then
		local g=Duel.GetMatchingGroup(s.cfilter,p,0,LOCATION_HAND,nil)
		if #g>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_CONFIRM)
			local sg=g:Select(1-p,1,1,nil)
			Duel.ConfirmCards(p,sg)
			Duel.ShuffleHand(1-p)
			Duel.NegateEffect(0)
			return
		end
	end
	Duel.Draw(p,d,REASON_EFFECT)
end