--ＶＳ 裏螺旋流雪風
--Vanquish Soul Snow Devil
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Reveal up to 3 monsters and apply effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VANQUISH_SOUL}
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK|ATTRIBUTE_EARTH|ATTRIBUTE_FIRE) and not c:IsPublic()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local rvg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #rvg>0 end
	local g=aux.SelectUnselectGroup(rvg,e,tp,1,3,aux.dpcheck(Card.GetAttribute),1,tp,HINTMSG_CONFIRM)
	e:SetLabel(#g)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res=e:GetLabel()~=0
		e:SetLabel(0)
		return res
	end
	local ct=e:GetLabel()
	local dam=400
	if ct>=1 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
	if ct>=2 then dam=dam+600 end
	if ct==3 then
		dam=dam+800
		local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,dg,#dg,0,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_VANQUISH_SOUL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local break_eff=false
	if ct>=1 and Duel.Damage(1-tp,400,REASON_EFFECT)>0 then
		break_eff=true
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if ct>=2 then
		if break_eff then Duel.BreakEffect() end
		Duel.Damage(1-tp,600,REASON_EFFECT)
		local c=e:GetHandler()
		--"Vanquish Soul" monsters cannot be destroyed by effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsSetCard(SET_VANQUISH_SOUL) end)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,2))
		break_eff=true
	end
	if ct==3 then
		if break_eff then Duel.BreakEffect() end
		if Duel.Damage(1-tp,800,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			local dg=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
			Duel.BreakEffect()
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
end