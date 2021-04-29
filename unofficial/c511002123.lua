--オーバーレイ・ウィーカー
--Weaker Overlay
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return d and a:IsType(TYPE_XYZ) and a:IsFaceup() and d:IsType(TYPE_XYZ) and d:IsFaceup() and a:GetOverlayCount()~=d:GetOverlayCount()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not (d and a:IsRelateToBattle() and d:IsRelateToBattle() and a:IsType(TYPE_XYZ) and a:IsFaceup() and d:IsType(TYPE_XYZ) and d:IsFaceup()) then return end
	local act=a:GetOverlayCount()
	local dct=d:GetOverlayCount()
	if act==dct then return end
	if dct>act then
		a,d=d,a
		dct,act=act,dct
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(600*act)
	d:RegisterEffect(e1)
end
