--サイコ・リアクター
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.regcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_PSYCHIC),tp,LOCATION_MZONE,0,1,nil)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsRace,RACE_PSYCHIC),tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	g:KeepAlive()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(g)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TURN_END)
	e2:SetCountLimit(1)
	e2:SetLabelObject(g)
	e2:SetOperation(s.reset)
	Duel.RegisterEffect(e2,tp)
end
function s.filter(c,g)
	return c:GetFlagEffect(id)>0 and g:IsContains(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	if chk==0 then return d and g:IsExists(s.filter,1,nil,e:GetLabelObject()) end
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,#rg,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	local g=Group.FromCards(a,d)
	local rg=g:Filter(Card.IsRelateToBattle,nil)
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():DeleteGroup()
	e:Reset()
end
