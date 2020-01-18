--コード・ハック
--Code Hack
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x101))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30603688,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetHintTiming(TIMING_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
	--negate
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetHintTiming(TIMING_DAMAGE_STEP+TIMING_DAMAGE_CAL)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetCondition(s.negcon)
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
s.listed_series={0x101}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()~=PHASE_BATTLE_STEP then return false end
	local c=Duel.GetAttackTarget()
	if not c then return false end
	local tc=Duel.GetAttacker()
	if c:IsControler(tp) then c,tc=tc,c end
	e:SetLabelObject(c)
	return tc:IsSetCard(0x101) and tc:IsRelateToBattle() and not c:IsControler(tp) and c:IsRelateToBattle()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToBattle() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		e1:SetValue(0)
		c:RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetValue(1)
	e2:SetTarget(function(e,c) return c:IsRelateToBattle() end)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetOperation(s.damop)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e3,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(tp,0)
	Duel.ChangeBattleDamage(1-tp,0)
end
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE|PHASE_DAMAGE_CAL)==0 or Duel.IsDamageCalculated() then return false end
	local tc=Duel.GetAttacker()
	if not tc:IsControler(tp) then tc=Duel.GetAttackTarget() end
	return tc and tc:IsControler(tp) and tc:IsSetCard(0x101)
		and ep~=tp and Duel.IsChainNegatable(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x101)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) then
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
