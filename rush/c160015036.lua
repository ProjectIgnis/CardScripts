--ダークネス・ギャラクティカ・オブリビオン
--Darkness Galactica Oblivion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160015003,160009002)
	--Reduce ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.filter(c)
	if c:IsMaximumModeSide() then return false end
	local atk=c:GetBaseAttack()
	if c:IsMaximumMode() then atk=c:GetMaximumAttack() end
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and atk>=100 and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		local tc=g:GetFirst()
		local atk=tc:GetBaseAttack()
		if tc:IsMaximumMode() then
			atk=tc:GetMaximumAttack()
		end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
		--Negate Continuous Effect
		if tc:HasContinuousRushEffect() and not tc:HasFlagEffect(FLAG_NEGATE_CONTINUOUS_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			tc:NegateContinuousRushEffects(RESETS_STANDARD_PHASE_END)
		end
	end
end