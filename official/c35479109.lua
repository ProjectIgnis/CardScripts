--砂塵の大ハリケーン
--Double Dust Tornado Twins
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Return itself and Set Spell/Traps to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_SSET|TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToHand() and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_SZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_SZONE,0,1,5,nil)
	g:AddCard(c)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local rg=tg:Filter(aux.AND(Card.IsAbleToHand,Card.IsFacedown),nil)
	if #rg==0 then return end
	c:CancelToGrave()
	if not c:IsAbleToHand() then
		c:CancelToGrave(false)
		return
	end
	if Duel.SendtoHand(rg:AddCard(c),nil,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_HAND):Match(Card.IsControler,nil,tp)
		local rt_ct=#og
		if rt_ct==0 then return end
		local setg=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		if #setg==0 or #setg<rt_ct then return end
		if aux.SelectUnselectGroup(setg,e,tp,rt_ct,rt_ct,s.rescon,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			local sg=aux.SelectUnselectGroup(setg,e,tp,rt_ct,rt_ct,s.rescon,1,tp,HINTMSG_SET)
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsSSetable,nil)==#sg
		and sg:FilterCount(aux.NOT(Card.IsType),nil,TYPE_FIELD)<=Duel.GetLocationCount(tp,LOCATION_SZONE)
		and sg:FilterCount(Card.IsType,nil,TYPE_FIELD)<=1
end