--第１９層『襲来干渉！漆黒の超量士！！』
--Layer 19: "Preventing the Invasion! The Pitch-Black Super Quantum!!"
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
s.listed_series={SET_SUPER_QUANT}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SUPER_QUANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsOriginalAttribute,c:GetOriginalAttribute()),tp,LOCATION_MZONE,0,1,nil)
end
function s.setfilter(c)
	return c:IsSetCard(SET_SUPER_QUANT) and c:IsTrap() and c:IsSSetable()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingTarget(aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=not Duel.HasFlagEffect(tp,id+100) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SUPER_QUANT),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b3=not Duel.HasFlagEffect(tp,id+200)
		and (e:GetHandler():IsLocation(LOCATION_SZONE) or Duel.GetLocationCount(tp,LOCATION_SZONE)>=2)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==1 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAttackPos() and chkc:IsCanChangePosition() end
	local cost_skip=e:GetLabel()~=-100
	local b1=(cost_skip or not Duel.HasFlagEffect(tp,id))
		and Duel.IsExistingTarget(aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=(cost_skip or (not Duel.HasFlagEffect(tp,id+100)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_SUPER_QUANT),tp,LOCATION_MZONE,0,1,nil)))
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b3=(cost_skip or not Duel.HasFlagEffect(tp,id+200))
		and (not e:IsHasType(EFFECT_TYPE_ACTIVATE) or e:GetHandler():IsLocation(LOCATION_SZONE) or Duel.GetLocationCount(tp,LOCATION_SZONE)>=2)
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then e:SetLabel(0) return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local g=Duel.SelectTarget(tp,aux.AND(Card.IsAttackPos,Card.IsCanChangePosition),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==3 then
		e:SetCategory(0)
		e:SetProperty(0)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE|PHASE_END,0,1) end
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Change 1 Attack Position monster on the field to Defense Position
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	elseif op==2 then
		--Special Summon 1 "Super Quant" monster from your Deck in Defense Position, with a different original Attribute from the monsters you control
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif op==3 then
		--Set 1 "Super Quant" Trap from your Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if sc and Duel.SSet(tp,sc)>0 then
			--It can be activated this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,4))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			sc:RegisterEffect(e1)
		end
	end
end