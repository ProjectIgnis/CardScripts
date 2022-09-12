--It's Jinzo!
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop2)
	c:RegisterEffect(e1)
end
function s.setfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--condition
	return aux.CanActivateSkill(tp)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_JINZO),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,0,LOCATION_SZONE,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.GetMatchingGroup(s.setfilter,tp,0,LOCATION_SZONE,nil)
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if not tc then return end
	Duel.ConfirmCards(tp,tc)
	if tc:IsTrap() then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	if Duel.GetFlagEffect(tp,id+1)==0 then
		--immune
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xbc))
		e1:SetValue(s.efilter)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
end
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SKILL)
end
