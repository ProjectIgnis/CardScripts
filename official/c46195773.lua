--ターボ・ウォリアー
--Turbo Warrior
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,s.tfilter,1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--atk down
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--cannot be target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
s.material={67270095}
s.listed_names={67270095}
s.material_setcode=SET_SYNCHRON
function s.tfilter(c,scard,sumtype,tp)
	return c:IsSummonCode(scard,sumtype,tp,67270095) or c:IsHasEffect(20932152)
end
function s.efilter(e,re,rp)
	return re:GetHandler():IsLevelBelow(6)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and d:IsFaceup() and d:GetLevel()>=6 and d:IsType(TYPE_SYNCHRO) end
	d:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,d,1,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local d=Duel.GetAttackTarget()
	if d:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(d:GetAttack()/2)
		e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
		d:RegisterEffect(e1)
	end
end