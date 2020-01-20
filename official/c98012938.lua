--獣神ヴァルカン
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--return
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return true end
	if Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsAbleToHand),tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g1=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsAbleToHand),tp,LOCATION_ONFIELD,0,1,1,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local g2=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,1,nil)
		g1:Merge(g2)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
	end
end
function s.hfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(s.hfilter,nil,e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			if tc:IsLocation(LOCATION_HAND) then
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetTargetRange(1,0)
				e1:SetValue(s.aclimit)
				e1:SetLabel(tc:GetCode())
				e1:SetReset(RESET_PHASE+PHASE_END)
				Duel.RegisterEffect(e1,tp)
			end
		end
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
