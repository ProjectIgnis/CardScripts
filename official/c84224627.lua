--キャット・シャーク
--Cat Shark
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 2 monsters
	Xyz.AddProcedure(c,nil,2,2)
	--Cannot be destroyed by battle while it has a material attached that was originally WATER
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Double the ATK/DEF of 1 Rank 4 or lower Xyz Monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCondition(aux.StatChangeDamageStepCondition)
	e2:SetCost(Cost.Detach(1))
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.indcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRankBelow(4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local tc=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,tc,1,tp,tc:GetBaseAttack()*2)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,tc,1,tp,tc:GetBaseDefense()*2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		e1:SetValue(tc:GetBaseAttack()*2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(tc:GetBaseDefense()*2)
		tc:RegisterEffect(e2)
	end
end