--Fury of Thunder
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(s.tdcon)
	e2:SetOperation(s.tdop)
	Duel.RegisterEffect(e2,tp)
end
s.listed_names={10000020}
--effect 1
function s.drfilter(c)
	return c:IsCode(10000020) and c:IsFaceup()
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	local ct=Duel.GetLocationCount(tp,LOCATION_HAND)
	return aux.CanActivateSkill(tp) and ct<4 and Duel.IsPlayerCanDraw(tp,4-ct)
		and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local ct=4-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ct>0 and Duel.IsExistingMatchingCard(s.drfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,ct) then
		Duel.Draw(tp,ct,REASON_EFFECT)
	end
end
function s.tdfilter(c,tp)
	return c:IsCode(10000020) and c:IsAbleToDeck() and c:IsControler(tp)
end
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)--opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return false end
	return eg:IsExists(s.tdfilter,1,nil,tp)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	local ec=eg:Filter(s.tdfilter,nil,tp)
	if ec then
		Duel.SendtoDeck(ec,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
