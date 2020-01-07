--機塊リサイクル
--Appliancer Recycling
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id)--+EFFECT_COUNT_CODE_OATH
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={0x57a}
function s.cfilter(c,tp)
	return c:IsPreviousControler(1-tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.rmfilter(c,e,tp,fp)
	return c:IsType(TYPE_LINK) and c:IsLink(1) and c:IsAbleToRemove() and aux.SpElimFilter(c)
		and (not fp or Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,c,e,tp))
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x57a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local fp=0
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,e,tp,fp)
		and Duel.IsExistingTarget(s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp)
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,0,LOCATION_REMOVED,1,nil,e,tp)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,e,tp,fp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectTarget(tp,s.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,e,tp)
	g1:Merge(g2)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ex,g=Duel.GetOperationInfo(0,CATEGORY_REMOVE)
	if not (g:GetFirst():IsRelateToEffect(e) or g:GetNext():IsRelateToEffect(e)) then return end
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			if #g1>0 then
				Duel.BreakEffect()
				if Duel.SpecialSummonStep(g1:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
					--cannot be destroyed by battle this turn
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
					e1:SetValue(1)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
					g1:GetFirst():RegisterEffect(e1)
					if Duel.SpecialSummonComplete()>0 and Duel.IsExistingMatchingCard(s.spfilter2,tp,0,LOCATION_REMOVED,1,nil,e,tp) then
						Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
						local g2=Duel.SelectMatchingCard(1-tp,s.spfilter2,tp,0,LOCATION_REMOVED,1,1,nil,e,tp)
						if #g2>0 then
							Duel.SpecialSummonStep(g2:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEUP)
							local e2=Effect.CreateEffect(e:GetHandler())
							e2:SetType(EFFECT_TYPE_SINGLE)
							e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
							e2:SetValue(1)
							e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
							g2:GetFirst():RegisterEffect(e2)
							Duel.SpecialSummonComplete()
						end
					end
				end
			end
		end
	end
end