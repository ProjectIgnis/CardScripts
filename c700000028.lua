--Scripted by Eerie Code
--Ancient Gear Chaos Giant
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,42878636,511001540,511001544,511001726)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetValue(s.efilter2)
	c:RegisterEffect(e3)
	--attack all
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--actlimit
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
s.material_setcode=0x7
function s.efilter1(e,te)
	return te:IsActiveType(TYPE_TRAP+TYPE_SPELL) and te:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.efilter2(e,re,rp)
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_TRAP+TYPE_SPELL) and re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local e5=Effect.CreateEffect(e:GetHandler())
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DISABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e5,tp)
end
