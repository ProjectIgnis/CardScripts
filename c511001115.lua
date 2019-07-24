--Advanced Crystal Beast Amethyst Cat
local s,id=GetID()
function s.initial_effect(c)
	--Treated as "Crystal Beast Amethyst Cat"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_ADD_CODE)
	e1:SetValue(32933942)
	c:RegisterEffect(e1)
	--Direct Attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
	--Turn into Crystal
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(32933942,0))
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.crystaltg)
	e3:SetOperation(s.crystalop)
	c:RegisterEffect(e3)
	--damage reduce
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetCondition(s.rdcon)
	e4:SetOperation(s.rdop)
	c:RegisterEffect(e4)
	--selfdes
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_SELF_DESTROY)
	e5:SetRange(LOCATION_ONFIELD)
	e5:SetCondition(s.descon)
	c:RegisterEffect(e5)
end
s.listed_names={12644061}
function s.descon(e)
	local c=e:GetHandler()
	return not Duel.IsEnvironment(12644061) and (c:IsLocation(LOCATION_MZONE) or c:GetType()&TYPE_CONTINUOUS+TYPE_SPELL==TYPE_CONTINUOUS+TYPE_SPELL)
end
function s.crystaltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetDestination()==LOCATION_GRAVE and c:IsReason(REASON_DESTROY) end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return false end
	return Duel.SelectEffectYesNo(tp,c)
end
function s.crystalop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	c:RegisterEffect(e1)
	Duel.RaiseEvent(c,47408488,e,0,tp,0,0)
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end
