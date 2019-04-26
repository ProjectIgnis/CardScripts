--The Istrakan Hunter’s Distraction Tactics
function c210001509.initial_effect(c)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210001509.target)
	e1:SetOperation(c210001509.operation)
	c:RegisterEffect(e1)
end
function c210001509.filter1(c)
	local cg=c:GetEquipGroup()
	return c:IsFaceup() and c:IsSetCard(0x1f69) and cg and cg:IsExists(Card.IsSetCard,1,nil,0xf70)
end
function c210001509.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c210001509.filter1,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	local tg1=Duel.SelectTarget(tp,c210001509.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(tg1:GetFirst())
	local tg2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	tg1:Merge(tg2)
	Duel.SetTargetCard(tg1)
end
function c210001509.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1,tc2=g:GetFirst(),g:GetNext()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	if tc1 and tc1:IsRelateToEffect(e) then
		local cg=tc1:GetEquipGroup()
		local cgc=cg:FilterSelect(tp,Card.IsSetCard,1,1,nil,0xf70):GetFirst()
		if cgc and Duel.Destroy(cgc,REASON_EFFECT)>0 and tc2 and tc2:IsRelateToEffect(e) then
			Duel.Destroy(tc2,REASON_EFFECT)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetOperation(c210001509.athop)
			e1:SetCountLimit(1)
			e1:SetLabel(cgc:GetCode())
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function c210001509.filter2(c,code)
	return c:IsSetCard(0xf70) and (c:IsCode(code) or aux.IsCodeListed(c,code))
end
function c210001509.athop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	local g=Duel.SelectMatchingCard(tp,c210001509.filter2,tp,LOCATION_DECK,0,1,1,nil,code)
	if g and #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end