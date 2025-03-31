--オリファンの角笛
--Horn of Olifant
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--remove and destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.rmvtg)
	e1:SetOperation(s.rvmop)
	c:RegisterEffect(e1)
	--Activate2
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE|TIMINGS_CHECK_MONSTER)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ROLAND}
function s.filter(c)
	return c:IsSpell() and c:IsType(TYPE_EQUIP) and c:IsAbleToRemove()
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_ONFIELD)
end
function s.rvmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,1,nil)
	if #g and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tc=dg:Select(tp,1,1,nil)
			Duel.HintSelection(tc)
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
function s.desfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(SET_ROLAND) and c:IsDestructable(e)
end
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,0,1,nil,e)
		and g:CheckWithSumEqual(Card.GetLevel,9,1,ct) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e)
		if #g and Duel.Destroy(g,REASON_EFFECT)>0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft==0 then return end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if #g>0 then
			if ft>3 then ft=3 end
			if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
			if g:CheckWithSumEqual(Card.GetLevel,9,1,ft) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:SelectWithSumEqual(tp,Card.GetLevel,9,1,ft)
				local tc=sg:GetFirst()
					for tc in aux.Next(sg) do
						if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
							local e1=Effect.CreateEffect(e:GetHandler())
							e1:SetType(EFFECT_TYPE_SINGLE)
							e1:SetCode(EFFECT_DISABLE)
							e1:SetReset(RESET_EVENT|RESETS_STANDARD)
							tc:RegisterEffect(e1,true)
							local e2=Effect.CreateEffect(e:GetHandler())
							e2:SetType(EFFECT_TYPE_SINGLE)
							e2:SetCode(EFFECT_DISABLE_EFFECT)
							e2:SetReset(RESET_EVENT|RESETS_STANDARD)
							tc:RegisterEffect(e2,true)
						end
					end
				Duel.SpecialSummonComplete()
			end
		end
	end
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e0:SetDescription(aux.Stringid(id,3))
	e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	if Duel.IsTurnPlayer(tp) then
		e0:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN,2)
	else
		e0:SetReset(RESET_PHASE|PHASE_END|RESET_SELF_TURN)
	end
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.splimit)
	Duel.RegisterEffect(e0,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsRace(RACE_WARRIOR)
end