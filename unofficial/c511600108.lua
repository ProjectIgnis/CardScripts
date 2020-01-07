--暗黒の魔再生 (Manga)
--Dark Spell Regeneration (Manga)
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x95}
function s.filter(c,e,tp,eg,ep,ev,re,r,rp,b)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local te=c:CheckActivateEffect(false,false,false)
	if ((b and ft>1) or (not b and ft>0)) and c:IsType(TYPE_SPELL)
		and not c:IsType(TYPE_FIELD) and te then
		if c:IsSetCard(0x95) then
			local tg=te:GetTarget()
			return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return true
		end
	end
	if c:IsType(TYPE_FIELD) and Duel.CheckLocation(tp,LOCATION_SZONE,5) and te then return true end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.filter),tp,0,LOCATION_GRAVE,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp,e:GetHandler():IsLocation(LOCATION_HAND)) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local b=e:GetHandler():IsLocation(LOCATION_HAND)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp,b):GetFirst()
	if not tc then return end
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	if tpe&(TYPE_FIELD|TYPE_CONTINUOUS|TYPE_EQUIP)==0 and not tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		tc:CancelToGrave(false)
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
	if g then
		for etc in aux.Next(g) do
			etc:CreateEffectRelation(te)
		end
	end
	if op then 
		if tc:IsSetCard(0x95) then
			op(e,tp,eg,ep,ev,re,r,rp)
		else
			op(te,tp,eg,ep,ev,re,r,rp)
		end
	end
	tc:ReleaseEffectRelation(te)
	if g then
		for etc in aux.Next(g) do
			etc:ReleaseEffectRelation(te)
		end
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.rtcon)
	e1:SetOperation(s.rtop)
	Duel.RegisterEffect(e1,tp)
end
function s.rtcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return not (tc:IsControler(1-tp) and tc:IsLocation(LOCATION_GRAVE)) and not tc:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function s.rtop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsLocation(LOCATION_GRAVE) then
		Duel.SendtoDeck(tc,nil,-2,REASON_EFFECT)
	end
	Duel.SendtoGrave(tc,REASON_EFFECT,1-tp)
end
