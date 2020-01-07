--Shinato, King of a Higher Plane (DM)
--Scripted by edo9300
Duel.LoadScript("c300.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--gain on damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_PZONE+LOCATION_MZONE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(s.effcon)
	e2:SetOperation(s.revop)
	c:RegisterEffect(e2)
	--halve
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(s.hvcon)
	e3:SetOperation(s.hvop)
	c:RegisterEffect(e3)
	--Return
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(s.rtg)
	e4:SetOperation(s.rop)
	c:RegisterEffect(e4)
	--splimit
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_PZONE)
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e7:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetTargetRange(1,0)
	e7:SetTarget(s.splimit)
	c:RegisterEffect(e7)
	--Immune
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_IMMUNE_EFFECT)
	e8:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e8:SetRange(LOCATION_PZONE)
	e8:SetValue(1)
	c:RegisterEffect(e8)
end
s.dm=true
s.dm_no_spsummon=true
s.dm_no_activable=true
s.dm_replace_original=true
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetFlagEffect(300)>0
end
function s.revop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,ev,REASON_EFFECT)
end
function s.hvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle() and e:GetHandler():GetFlagEffect(300)>0
end
function s.hvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(1-tp,math.ceil(Duel.GetLP(1-tp)/2))
end
function s.cfil(c,seq)
	local seq1=c:GetSequence()
	return seq==seq
end
function s.rtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc1=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_SZONE,6)
	local tc2=Duel.GetFieldCard(e:GetHandlerPlayer(),LOCATION_SZONE,7)
	--Activate
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetReset(RESET_CHAIN)
	e:GetHandler():RegisterEffect(e2)
	if chk==0 then return e:GetHandler():CheckActivateEffect(false,false,false)~=nil and (not tc1 or not tc2) 
		and not e:GetHandler():IsStatus(STATUS_CHAINING) and e:GetHandler():GetFlagEffect(300)>0 end
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	local tpe=c:GetType()
	local te=c:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	Duel.Hint(HINT_CARD,0,c:GetOriginalCode())
	c:CreateEffectRelation(te)
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
	Duel.BreakEffect()
	if op then op(te,tp,eg,ep,ev,re,r,rp) end
	c:ReleaseEffectRelation(te)
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end