--ドラゴンズ・オーブ
--Dragon's Orb
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return not Duel.HasFlagEffect(tp,id) end)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.HasFlagEffect(tp,id) then return end
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	local c=e:GetHandler()
	--Dragon monsters you control cannot have their effects negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DISABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_DRAGON))
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--The activated effects of Dragon monsters you control cannot be negated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISEFFECT)
	e2:SetValue(s.cannotdisfilter)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,1))
end
function s.cannotdisfilter(e,ct)
	local trig_e=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT)
	if not trig_e:IsMonsterEffect() then return false end
	local trig_c=trig_e:GetHandler()
	return trig_c:IsControler(e:GetHandlerPlayer()) and trig_c:IsLocation(LOCATION_MZONE) and trig_c:IsRace(RACE_DRAGON) and trig_c:IsFaceup()
end