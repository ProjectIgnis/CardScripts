--黒魔導強化
--Dark Magic Expanded
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL}
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_DARK_MAGICIAN,CARD_DARK_MAGICIAN_GIRL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	return ct>0 and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		if ct<=1 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
		return true
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	local ct=#g
	if ct>=1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(g)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(1000)
			tc:RegisterEffect(e1)
		end
	end
	if ct>=2 then
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(s.chainop)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e3:SetTargetRange(LOCATION_ONFIELD,0)
		e3:SetTarget(s.indtg)
		e3:SetValue(s.indval)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		aux.RegisterClientHint(e:GetHandler(),nil,tp,1,1,aux.Stringid(id,1),nil)
	end
	if ct>=3 then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e4=Effect.CreateEffect(e:GetHandler())
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_IMMUNE_EFFECT)
			e4:SetValue(s.efilter)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e4:SetOwnerPlayer(tp)
			tc:RegisterEffect(e4)
		end
	end
end
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and ep==tp then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp
end
function s.indtg(e,c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.indval(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function s.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end
