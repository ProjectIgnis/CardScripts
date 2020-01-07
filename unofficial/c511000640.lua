--Leading Question
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_CALCULATING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.atkup)
	c:RegisterEffect(e2)
end
function s.atkup(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not (d~=nil and a:GetControler()==tp and a:IsType(TYPE_FUSION) and a:GetLevel()<=4 and a:IsRelateToBattle())
		and not (d~=nil and d:GetControler()==tp and d:IsFaceup() and d:IsType(TYPE_FUSION) and d:GetLevel()<=4 and d:IsRelateToBattle()) then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	if a:GetControler()==tp then
		e1:SetValue(800)
		a:RegisterEffect(e1)
	else
		e1:SetValue(800)
		d:RegisterEffect(e1)
	end
end
