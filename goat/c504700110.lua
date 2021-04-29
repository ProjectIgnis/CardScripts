--カウンターマシンガンパンチ
--Continuous Destruction Punch (GOAT)
--The monster is considered as having the destroyed status starting
--when they would normally be considered as such
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.descon2)
	e3:SetOperation(s.desop2)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabelObject(nil)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and a:IsControler(1-tp) and a:IsRelateToBattle()
		and at:IsDefensePos() and at:IsRelateToBattle() and a:GetAttack()<at:GetDefense()
		and not a:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.GetAttacker():SetStatus(STATUS_BATTLE_DESTROYED,true)
	e:SetLabelObject(Duel.GetAttacker())
end
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabelObject()
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	e:GetLabelObject():SetLabelObject(nil)
	tc:SetStatus(STATUS_BATTLE_DESTROYED,true)
	Duel.Destroy(tc,REASON_EFFECT)
end
