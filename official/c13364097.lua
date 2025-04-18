--電脳堺門－朱雀
--Virtual World Gate - Chuche
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Shuffle 2 of your banished "Virtual World" cards with different names from each other into the Deck and destroy 1 face-up card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_EQUIP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	--Increase or decrease the Level/Rank of 1 "Virtual World" monster you control by 3 until the end of this turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp) end)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.lvrnktg)
	e2:SetOperation(s.lvrnkop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VIRTUAL_WORLD}
function s.tdfilter(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local exc=not c:IsStatus(STATUS_EFFECT_ENABLED) and c or nil
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() and (not exc or chkc~=exc) end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc)
		and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if #g<2 then return end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg~=2 then return end
	Duel.HintSelection(sg)
	if Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=2 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
function s.lvrnkfilter(c)
	return c:IsSetCard(SET_VIRTUAL_WORLD) and c:IsFaceup() and (c:HasLevel() or c:HasRank())
end
function s.lvrnktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvrnkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvrnkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.lvrnkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvrnkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and (tc:HasLevel() or tc:HasRank()) then
		local lvrnk=tc:HasLevel() and tc:GetLevel() or tc:GetRank()
		local b2=lvrnk>3
		local op=nil
		if b2 then
			op=Duel.SelectEffect(tp,
				{true,aux.Stringid(id,2)},
				{b2,aux.Stringid(id,3)})
		else
			op=1
		end
		local c=e:GetHandler()
		local val=op==1 and 3 or -3
		if tc:HasLevel() then
			--Increase or decrease its Level by 3
			tc:UpdateLevel(val,RESETS_STANDARD_PHASE_END,c)
		elseif tc:HasRank() then
			--Increase or decrease its Rank by 3
			tc:UpdateRank(val,RESETS_STANDARD_PHASE_END,c)
		end
	end
end