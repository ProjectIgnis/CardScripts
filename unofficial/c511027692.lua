--白しろの鉄壁
--White Barrier
--Made by Beetron-1 Beetletop
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_BECOME_QUICK)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--You take no effect or battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.damcon)
	e2:SetValue(s.damval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e3)
end
s.listed_series={0x55d}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsWhite),tp,LOCATION_MZONE,0,1,nil) and ep==tp
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttackTarget()
	return ac and ac:IsWhite() and ac:IsFaceup() and ac:IsControler(e:GetHandlerPlayer())
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsWhite),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,ac)
end
function s.damval(e,re,val,r,rp,rc)
	if r&(REASON_BATTLE|REASON_EFFECT)>0 then return 0 end
	return val
end