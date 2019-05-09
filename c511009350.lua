--Predator plant Chimere rafflesia
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_PLANT),2)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return (a:GetControler()==tp and a:IsRelateToBattle() and d:GetAttack()~=d:GetBaseAttack())
		or (d and d:GetControler()==tp and d:IsRelateToBattle() and a:GetAttack()~=a:GetBaseAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local atk=0
	if e:GetHandler()==Duel.GetAttacker() then
	local bc=Duel.GetAttackTarget()	
	
	if(bc:GetBaseAttack()>bc:GetAttack()) then
	atk=bc:GetBaseAttack()-bc:GetAttack()
	else
	atk=bc:GetAttack()>bc:GetBaseAttack()
	end
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(bc:GetBaseAttack())
	bc:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e2:SetValue(atk)
	e:GetHandler():RegisterEffect(e2)
	
	else
	
	local bc=Duel.GetAttacker()	
	
	if(bc:GetBaseAttack()>bc:GetAttack()) then
	atk=bc:GetBaseAttack()-bc:GetAttack()
	else
	atk=bc:GetAttack()>bc:GetBaseAttack()
	end
	
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(bc:GetBaseAttack())
	bc:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e2:SetValue(atk)
	e:GetHandler():RegisterEffect(e2)
	
end
end