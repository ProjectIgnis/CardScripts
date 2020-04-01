--Terror from the Deep!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
end
function s.flipconfilter(c)
	return c:IsFaceup() and c:IsCode(76634149)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--"cost" check
	if not (Duel.IsExistingMatchingCard(s.flipconfilter,tp,LOCATION_ONFIELD,0,1,nil)) then return false end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(ep,id)==0
end
function s.ffilter(c,tp)
	return c:IsCode(CARD_UMI) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ffilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,0,1,nil,76634149) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
	end
	--trap immune
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.etarget)
	e1:SetValue(s.efilter)
	Duel.RegisterEffect(e1,tp)
	--draw+reset
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetLabel(e1)
	e2:SetCondition(s.leavecon)
	e2:SetOperation(s.leaveop)
	Duel.RegisterEffect(e2,tp)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
end
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
function s.etarget(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER) 
end
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsCode(76634149) and c:GetPreviousControler()==tp
end
function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp)
end
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
	Duel.Draw(tp,2,REASON_EFFECT)
	e:Reset()
	Duel.ResetFlagEffect(tp,id)
end
