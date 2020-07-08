--電脳堺門－朱雀
--Datascape Gate - Zhuque
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Shuffle into the Deck and destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--Increase/Decrease target's level/rank by 3
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+100)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(s.lvrkcon)
	e3:SetTarget(s.lvrktg)
	e3:SetOperation(s.lvrkop)
	c:RegisterEffect(e3)
end
s.listed_series={0x248}
function s.tdfilter(c)
	return c:IsSetCard(0x248) and c:IsFaceup() and c:IsAbleToDeck()
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsFaceup() end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,0) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local tg=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,0,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_REMOVED,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_TODECK)
	if #sg==2 and Duel.SendtoDeck(sg,nil,0,REASON_EFFECT)==2 then
		local og=Duel.GetOperatedGroup()
		if og:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==2 and tc and tc:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
function s.lvrkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsMainPhase() and Duel.IsTurnPlayer(tp)
end
function s.lvrkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x248) and (c:HasLevel() or c:IsType(TYPE_XYZ))
end
function s.lvrktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.lvrkfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.lvrkfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.lvrkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.lvrkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local value=0
		if tc:IsType(TYPE_XYZ) then value=tc:GetRank() else value=tc:GetLevel() end
		local op=0
		if value>3 then
			op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
		else
			op=Duel.SelectOption(tp,aux.Stringid(id,2))
		end
		if tc:IsType(TYPE_XYZ) then
			if op==0 then
				tc:UpdateRank(-3,RESET_PHASE+PHASE_END,e:GetHandler())
			elseif op==1 then
				tc:UpdateRank(3,RESET_PHASE+PHASE_END,e:GetHandler())
			end
		else
			if op==0 then
				tc:UpdateLevel(-3,RESET_PHASE+PHASE_END,e:GetHandler())
			elseif op==1 then
				tc:UpdateLevel(3,RESET_PHASE+PHASE_END,e:GetHandler())
			end
		end
	end
end
