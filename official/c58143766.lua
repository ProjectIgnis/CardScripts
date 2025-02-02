--ヴォルカニック・エミッション
--Volcanic Emission
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VOLCANIC}
function s.thspfilter(c,e,tp,ft)
	return c:IsSetCard(SET_VOLCANIC) and c:IsMonster() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,true,false)))
end
function s.damfilter(c)
	return c:IsRace(RACE_PYRO) and c:IsFaceup() and c:GetBaseAttack()>0
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingTarget(s.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.damfilter(chkc) end
	local cost_skip=e:GetLabel()~=-100
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Duel.IsExistingMatchingCard(s.thspfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
	local b2=(cost_skip or not Duel.HasFlagEffect(tp,id+1))
		and Duel.IsExistingTarget(s.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then e:SetLabel(0) return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_DAMAGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
		local tc=Duel.SelectTarget(tp,s.damfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
		local dam=tc:GetBaseAttack()
		local ctrl=tc:GetControler()
		if ctrl==tp then dam=dam//2 end
		Duel.SetTargetParam(ctrl)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Search or Special Summon 1 "Volcanic" monster from your Deck
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=Duel.SelectMatchingCard(tp,s.thspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
		if not sc then return end
		aux.ToHandOrElse(sc,tp,
			function(c)
				return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,true,false)
			end,
			function(c)
				if Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
					--Return it to the hand during the End Phase
					aux.DelayedOperation(sc,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,5))
				end
				Duel.SpecialSummonComplete()
			end,
			aux.Stringid(id,4)
		)
	elseif op==2 then
		--Inflict damage to your opponent equal to that monster's original ATK
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			local dam=tc:GetBaseAttack()
			local ctrl=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
			if ctrl==tp then dam=dam//2 end
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end