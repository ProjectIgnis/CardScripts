--Aromaseraphy Bergamot
--Scripted by Steelren
function c210777027.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,nil,1,1,aux.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--Update ATK/DEF
	local e1=Effect.CreateEffect(c)	
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_RECOVER)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c210777027.cond)
	e1:SetTarget(c210777027.targ)
	e1:SetOperation(c210777027.oper)
	c:RegisterEffect(e1)
	--pierce damage for plants
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c210777027.pierccon)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	c:RegisterEffect(e2)
	end
function c210777027.cond(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function c210777027.targ(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp and e:GetHandler():IsRelateToEffect(e) end
end
function c210777027.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
function c210777027.atkval(e,c)
	return Duel.GetMatchingGroupCount(c210777027.cfilter,0,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)*500
end
function c210777027.oper(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(c210777027.atkval)
		e1:SetReset(RESET_EVENT+0x1ff0000+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
function c210777027.pierccon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetLP(tp)>Duel.GetLP(1-tp)
end
