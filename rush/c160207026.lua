--Ｂ・Ｂ・Ｂ
--B.B.B. - Beast Brave Brandish
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Shuffle 2 monsters into the deck to draw 1
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsType(TYPE_MAXIMUM) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,2,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.piercingfilter(c)
	return c:IsMaximumModeCenter() and c:IsFaceup() and not c:HasFlagEffect(id)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	--Requirement
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.HintSelection(g,true)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)~=2 then return end
	Duel.ShuffleDeck(tp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsAbleToEnterBP() and Duel.IsExistingMatchingCard(s.piercingfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local sc=Duel.SelectMatchingCard(tp,s.piercingfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if not sc then return end
		Duel.HintSelection(sc,true)
		sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
		--Piercing
		sc:AddPiercing(RESET_EVENT|RESETS_STANDARD,e:GetHandler())
	end
end
