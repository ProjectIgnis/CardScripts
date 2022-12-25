
--Pendulum Match
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_START)
	c:RegisterEffect(e1)
	--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.extradeckpendfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.opdeckpendfilter(c,e,tp,sc)
	return c:IsType(TYPE_PENDULUM) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLeftScale()==sc:GetLeftScale()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.extradeckpendfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.extradeckpendfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
		if #g>0 then
			local sg1=g:RandomSelect(tp,1)
			sc=sg1:GetFirst()
		end
		local x=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
			if x>0 then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetRange(LOCATION_MZONE)
				e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
				e1:SetCountLimit(1)
				e1:SetOperation(s.desop)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
				sc:RegisterEffect(e1)
					if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.opdeckpendfilter,1-tp,LOCATION_DECK,0,1,nil,e,1-tp,sc,sc:GetLeftScale()) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
						Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
						local sg=Duel.SelectMatchingCard(1-tp,s.opdeckpendfilter,1-tp,LOCATION_DECK,0,1,1,nil,e,1-tp,sc,sc:GetLeftScale())
							if #sg>0 then
								Duel.BreakEffect()
								if Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP) then
									local sc2=sg:GetFirst()
									local e2=Effect.CreateEffect(e:GetHandler())
									e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
									e2:SetRange(LOCATION_MZONE)
									e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
									e2:SetCountLimit(1)
									e2:SetOperation(s.desop)
									e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
									sc2:RegisterEffect(e2)
								end
							end
					end
			end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end