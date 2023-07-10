-- 死の罪宝－ルシエラ
-- Tainted Treasure of Doom - Luciela
-- Scripted by Satellaa
local s,id=GetID()
function s.initial_effect(c)
	-- Apply effects 
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOGRAVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER_E+TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function() return Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local c=e:GetHandler()
		-- Unaffected by other monsters' effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3101)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(function(_e,te) return te:IsMonsterEffect() and te:GetOwner()~=_e:GetHandler() end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
		local resetcount=Duel.GetCurrentPhase()<=PHASE_STANDBY and 2 or 1
		local prevturn=Duel.GetTurnCount()
		-- Send it to the GY during the Standby Phase of the next turn
		aux.DelayedOperation(tc,PHASE_STANDBY,id,e,tp,function(ag) Duel.SendtoGrave(ag,REASON_EFFECT) end,function() return Duel.GetTurnCount()~=prevturn end,nil,resetcount,aux.Stringid(id,1))
		local tc_atk=tc:GetAttack()
		if tc_atk==0 then return end
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		Duel.BreakEffect()
		local dg=Group.CreateGroup()
		for oc in g:Iter() do
			local preatk=oc:GetAttack()
			-- Decrease ATK
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-tc_atk)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			oc:RegisterEffect(e1)
			if preatk~=0 and oc:GetAttack()==0 then dg:AddCard(oc) end
		end
		if #dg==0 then return end
		Duel.BreakEffect()
		Duel.Destroy(dg,REASON_EFFECT)
	end
end