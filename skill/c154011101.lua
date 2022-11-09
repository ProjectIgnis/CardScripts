--Destiny Board (Skill)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={31829185}
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.GetLP(tp)<=2000 and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31829185)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	--Destiny Board Turns
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(s.wincon)
	e1:SetOperation(s.winop)
	e1:SetReset(RESET_PHASE+PHASE_END,11)
	Duel.RegisterEffect(e1,tp)
	--Invalidate Skill
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
	e2:SetRange(0x5f)
	e2:SetCondition(s.negcon)
	e2:SetOperation(s.negop)
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_DECK)
	Duel.RegisterEffect(e3,tp)
	local e4=e2:Clone()
	e4:SetCode(EVENT_TO_HAND)
	Duel.RegisterEffect(e4,tp)
	local e5=e2:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	Duel.RegisterEffect(e5,tp)
	local e6=e2:Clone()
	e6:SetCode(EVENT_BE_MATERIAL)
	Duel.RegisterEffect(e6,tp)
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp and e:GetHandler():GetFlagEffect(id)==0
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==5 then
		Duel.Win(tp,aux.Stringid(id,0))
	end
end
function s.gfilter(c,tp)
	return c:IsCode(31829185) and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsControler(tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.gfilter,1,nil,tp)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,0,0,0)
	Duel.Hint(HINT_CARD,0,id)
	Debug.ShowHint(aux.Stringid(id,1))
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32))
end