--ヤミー☆サプライズ
--Yummy☆Surprise
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
s.listed_series={SET_YUMMY}
function s.monoppthfilter(c,e,tp)
	return ((c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_BEAST) and c:IsControler(tp)) or c:IsControler(1-tp))
		and c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsControler,nil,tp)==2
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_YUMMY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.fieldspellthfilter(c)
	return c:IsFieldSpell() and c:IsFaceup() and c:IsAbleToHand()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local g=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,nil,e,tp)
	local b1=not Duel.HasFlagEffect(tp,id) and #g>=4
		and aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,0)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	local b3=not Duel.HasFlagEffect(tp,id+2)
		and Duel.IsExistingMatchingCard(s.fieldspellthfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local cost_skip=e:GetLabel()~=-100
	local g=Duel.GetMatchingGroup(s.monoppthfilter,tp,LOCATION_MZONE,LOCATION_ONFIELD,nil,e,tp)
	local b1=not Duel.HasFlagEffect(tp,id) and #g>=4
		and aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,0)
	local b2=not Duel.HasFlagEffect(tp,id+1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	local b3=not Duel.HasFlagEffect(tp,id+2)
		and Duel.IsExistingMatchingCard(s.fieldspellthfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
	if chk==0 then e:SetLabel(0) return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1) end
		local tg=aux.SelectUnselectGroup(g,e,tp,4,4,s.rescon,1,tp,HINTMSG_RTOHAND)
		Duel.SetTargetCard(tg)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,tg,4,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	elseif op==3 then
		e:SetCategory(CATEGORY_TOHAND)
		e:SetProperty(0)
		if not cost_skip then Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE|PHASE_END,0,1) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE)
	end
end
function s.plfilter(c)
	return c:IsSetCard(SET_YUMMY) and c:IsFieldSpell() and not c:IsForbidden()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Return 2 LIGHT Beast monsters you control and 2 cards your opponent controls to the hand
		local tg=Duel.GetTargetCards(e)
		if #tg>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	elseif op==2 then
		--Special Summon 1 "Yummy" monster from your hand or GY, but it cannot attack directly this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
			--It cannot attack directly this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(3207)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	elseif op==3 then
		--Return 1 Field Spell from your face-up field or GY to the hand, then you can place 1 "Yummy" Field Spell from your hand face-up on your field
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fieldspellthfilter),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if sc and Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sc)
			Duel.ShuffleHand(tp)
			if Duel.IsExistingMatchingCard(s.plfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
				local plc=Duel.SelectMatchingCard(tp,s.plfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
				if plc then
					Duel.BreakEffect()
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						Duel.SendtoGrave(fc,REASON_RULE)
						Duel.BreakEffect()
					end
					Duel.MoveToField(plc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end