--ＣＮｏ．３２ 海咬龍シャーク・ドレイク・バイス
--Number C32: Shark Drake Veiss
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 4 Level 4 WATER monsters OR 1 "Number 32: Shark Drake" you control
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),4,4,s.ovfilter,aux.Stringid(id,0))
	--Make the ATK/DEF of 1 face-up monster on the field become 0 until the end of your turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(function(e,tp) return Duel.GetLP(tp)<=1000 and aux.StatChangeDamageStepCondition() end)
	e1:SetCost(Cost.AND(s.atkdefcost,Cost.DetachFromSelf(1)))
	e1:SetTarget(s.atkdeftg)
	e1:SetOperation(s.atkdefop)
	c:RegisterEffect(e1)
end
s.xyz_number=32
s.listed_names={65676461} --"Number 32: Shark Drake"
function s.ovfilter(c,tp,lc)
	return c:IsSummonCode(lc,SUMMON_TYPE_XYZ,tp,65676461) and c:IsFaceup()
end
function s.atkdefcostfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c) 
		and Duel.IsExistingTarget(aux.OR(Card.HasNonZeroAttack,Card.HasNonZeroDefense),0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.atkdefcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atkdefcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.atkdefcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.atkdeftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and (chkc:HasNonZeroAttack() or chkc:HasNonZeroDefense()) end
	if chk==0 then return Duel.IsExistingTarget(aux.OR(Card.HasNonZeroAttack,Card.HasNonZeroDefense),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	Duel.SelectTarget(tp,aux.OR(Card.HasNonZeroAttack,Card.HasNonZeroDefense),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
function s.atkdefop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local ct=Duel.IsTurnPlayer(1-tp) and 2 or 1
		--Its ATK/DEF become 0 until the end of your turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESETS_STANDARD_PHASE_END,ct)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e2)
	end
end
