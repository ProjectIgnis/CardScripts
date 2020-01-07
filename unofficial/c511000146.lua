--Aria from Beyond
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
s.listed_series={0x95}
function s.filter1(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:CheckActivateEffect(false,false,false)
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
function s.filter2(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:CheckActivateEffect(false,false,false)
	if c:IsType(TYPE_SPELL) and not c:IsType(TYPE_EQUIP+TYPE_CONTINUOUS) and te then
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
	if chkc then return false end
	if chk==0 then
		local b=e:GetHandler():IsLocation(LOCATION_HAND)
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if (b and ft>1) or (not b and ft>0) then
			return Duel.IsExistingTarget(s.filter1,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		else
			return Duel.IsExistingTarget(s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SelectTarget(tp,s.filter1,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	else
		Duel.SelectTarget(tp,s.filter2,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	if (tpe&TYPE_EQUIP+TYPE_CONTINUOUS)~=0 or tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	elseif (tpe&TYPE_FIELD)~=0 then
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
	tc:CreateEffectRelation(te)
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then
		if tc:IsSetCard(0x95) then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		else
			tg(te,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	Duel.BreakEffect()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local etc=g:GetFirst()
	while etc do
		etc:CreateEffectRelation(te)
		etc=g:GetNext()
	end
	if op then 
		if tc:IsSetCard(0x95) then
			op(e,tp,eg,ep,ev,re,r,rp)
		else
			op(te,tp,eg,ep,ev,re,r,rp)
		end
	end
	tc:ReleaseEffectRelation(te)
	etc=g:GetFirst()
	while etc do
		etc:ReleaseEffectRelation(te)
		etc=g:GetNext()
	end
end