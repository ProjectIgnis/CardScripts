--Miracle Rocket Show
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--negate destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_MONSTER))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--damage process
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--end
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.op)
	c:RegisterEffect(e4)
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	return tp==rp
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then c:RegisterFlagEffect(id,RESET_PHASE+PHASE_BATTLE,0,1) end
	local dt=c:GetFlagEffectLabel(id)
	if not dt then dt=0 end
	dt=dt+Duel.GetBattleDamage(1-tp)
	c:SetFlagEffectLabel(id,dt)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	e1:SetValue(0)
	Duel.RegisterEffect(e1,tp)
end
function s.op(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	Duel.Destroy(c,REASON_EFFECT)
	if c:GetFlagEffect(id)~=0 and c:GetFlagEffectLabel(id) then
		Duel.Damage(1-tp,c:GetFlagEffectLabel(id),REASON_EFFECT)
	end
end