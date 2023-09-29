--Order of the Queen
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={15951532}
s.listed_series={SET_AMAZONESS}
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	Duel.RegisterEffect(e1,tp)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
	local dc=Duel.GetAttackTarget()
	return ac and dc and ac:IsControler(tp) and ac:IsSetCard(SET_AMAZONESS) and dc:IsStatus(STATUS_BATTLE_DESTROYED) and dc:IsType(TYPE_EFFECT)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,15951532),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local dc=Duel.GetAttackTarget()
	--Negate its effects
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD&~(RESET_LEAVE|RESET_TOGRAVE))
	dc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	dc:RegisterEffect(e2)
end
