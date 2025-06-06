--深すぎた墓穴
--The Deep Grave
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster during your next Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp)
	if c:IsHasEffect(EFFECT_SPSUMMON_CONDITION) then
		local sc = c:IsHasEffect(EFFECT_SPSUMMON_CONDITION)
		local v = sc:GetValue()
		if type(v) == 'function' and not v(sc,e,tp,SUMMON_TYPE_SPECIAL) then
			return false
		elseif v == 0 then
			return false
		end
	end
	return c:IsMonster() and (not c:IsHasEffect(EFFECT_REVIVE_LIMIT) or c:IsStatus(STATUS_PROC_COMPLETE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,1,tp,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local res=(Duel.IsPhase(PHASE_STANDBY) and Duel.IsTurnPlayer(tp)) and 2 or 1
	local turn_asc=(Duel.GetCurrentPhase()<PHASE_STANDBY and Duel.IsTurnPlayer(tp)) and 0 or (Duel.IsTurnPlayer(tp)) and 2 or 1
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetLabel(turn_asc+Duel.GetTurnCount())
	e1:SetLabelObject(tc)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,res)
	Duel.RegisterEffect(e1,tp)
	tc:CreateEffectRelation(e1)
end
function s.spcon(e,tp)
	return Duel.GetTurnCount()==e:GetLabel() and Duel.IsTurnPlayer(tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc and tc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end