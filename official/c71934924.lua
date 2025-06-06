--疾風！凶殺陣
--Swift Samurai Storm!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage cal
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(s.atop)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetOperation(s.upop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_SIX_SAMURAI}
function s.check(c,tp)
	return c and c:IsSetCard(SET_SIX_SAMURAI) and c:IsControler(tp)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	if s.check(Duel.GetAttacker(),tp) or s.check(Duel.GetAttackTarget(),tp) then
		e:GetHandler():RegisterFlagEffect(id,RESET_PHASE|PHASE_DAMAGE,0,1)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(SET_SIX_SAMURAI) and c:GetFlagEffect(id)==0
end
function s.upop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		--Activate
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end