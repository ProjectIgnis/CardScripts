--Dice Dungeon
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--selfdes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.sdcon)
	c:RegisterEffect(e2)
	--atk up
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.con)
	e3:SetOperation(s.op)
	c:RegisterEffect(e3)
end
function s.sdcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	return bc
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local bc=Duel.GetAttackTarget()
	if at:IsControler(1-tp) then at,bc=bc,at end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local dice1=Duel.TossDice(tp,1)
		local dice2=Duel.TossDice(1-tp,1)
		if dice1==1 or dice1==5 or dice1==6 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			if dice1==1 then
				e1:SetCode(EFFECT_UPDATE_ATTACK)
			else
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
			end
			e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
			if dice1==1 then
				e1:SetValue(1000)
			elseif dice1==5 then
				e1:SetValue(at:GetBaseAttack()/2)
			else
				e1:SetValue(at:GetBaseAttack()*2)
			end
			at:RegisterEffect(e1)
		end
		if dice2==1 or dice2==5 or dice2==6 then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			if dice2==1 then
				e2:SetCode(EFFECT_UPDATE_ATTACK)
			else
				e2:SetCode(EFFECT_SET_BASE_ATTACK)
			end
			e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
			if dice2==1 then
				e2:SetValue(1000)
			elseif dice2==5 then
				e2:SetValue(bc:GetBaseAttack()/2)
			else
				e2:SetValue(bc:GetBaseAttack()*2)
			end
			bc:RegisterEffect(e2)
		end
	end
end
