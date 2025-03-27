--壱時砲固定式
--Linear Equation Cannon
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_TODECK+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:HasLevel()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
	local ac=Duel.AnnounceNumber(tp,1,2,3,4,5,6)
	e:SetLabel(ac)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	local dc=e:GetLabel()
	local ct=(tc:GetLevel()*dc)+Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct==Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0) then
		local ac=dc
		if ac>1 then
			local tbl={}
			for i=dc,1,-1 do
				if Duel.IsPlayerCanDiscardDeck(tp,i) then table.insert(tbl,i) end
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
			ac=Duel.AnnounceNumber(tp,table.unpack(tbl))
		end
		if Duel.DiscardDeck(tp,ac,REASON_EFFECT)==0 then return end
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)
		if ct==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,ct,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	else
		Duel.SetLP(tp,math.max(Duel.GetLP(tp)-(dc*500),0))
	end
end