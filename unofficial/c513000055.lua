--二重魔法
local s,id=GetID()
function s.initial_effect(c)
	--copy spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp,eg,ep,ev,re,r,rp,tid)
	local te=c:CheckActivateEffect(false,false,false)
	if c:GetTurnID()~=tid-1 or not c:IsPreviousPosition(POS_FACEUP) then return false end
	if c:IsType(TYPE_SPELL) and te then
		if c:IsSetCard(0x95) then
			local tg=te:GetTarget()
			return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tid=Duel.GetTurnCount()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp)  and s.filter(chkc,e,tp,eg,ep,ev,re,r,rp,tid) end
	if chk==0 then
		local b=e:GetHandler():IsLocation(LOCATION_HAND)
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if (b and ft>1) or (not b and ft>0) then
			return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp,tid)
		else
			return false
		end
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_GRAVE,1,ft,nil,e,tp,eg,ep,ev,re,r,rp,tid)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tgg=Duel.GetTargetCards(e)
	local tc=tgg:GetFirst()
	while tc and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 do
		local tpe=tc:GetType()
		local te=tc:GetActivateEffect()
		local tg=te:GetTarget()
		local co=te:GetCost()
		local op=te:GetOperation()
		e:SetCategory(te:GetCategory())
		e:SetProperty(te:GetProperty())
		Duel.ClearTargetCard()
		if (tpe&TYPE_FIELD)~=0 then
			local of=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
			if of then Duel.Destroy(of,REASON_RULE) end
			of=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
			if of and Duel.Destroy(of,REASON_RULE)==0 then Duel.SendtoGrave(tc,REASON_RULE) end
		end
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		Duel.Hint(HINT_CARD,0,tc:GetCode())
		tc:CreateEffectRelation(te)
		if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS+TYPE_FIELD)==0 then
			tc:CancelToGrave(false)
		end
		if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
		if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g then
			local etc=g:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
				etc=g:GetNext()
			end
		end
		if op then op(te,tp,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		if etc then	
			etc=g:GetFirst()
			while etc do
				etc:ReleaseEffectRelation(te)
				etc=g:GetNext()
			end
		end
		tc=tgg:GetNext()
	end
end
