--clear Wall (Anime)
--scripted by GameMaster + Shad3
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--selfdes if no clearworld
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
	--battle indestructable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(function(e) return e:GetHandler():IsAttackPos() end) 
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--change damage 
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetCondition(s.con)
	e5:SetOperation(s.activate)
	c:RegisterEffect(e5)
	--change damage 
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e6:SetCondition(s.con2)
	e6:SetOperation(s.activate2)
	c:RegisterEffect(e6)
end
s.listed_names={33900648}

function s.con2(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetBattleDamage(tp)>1000 and ( (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsSetCard(0x306)) or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsSetCard(0x306)) )
end

function s.activate2(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
	Duel.ChangeBattleDamage(tp,0) 
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
else
	local dam=Duel.GetBattleDamage(tp)
	return dam
end
end

function s.sdcon(e)
	return not Duel.IsEnvironment(33900648)
end
function s.indtg(e,c)
	return c:IsSetCard(0x306) and c:IsAttackPos()
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)<=1000
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
end