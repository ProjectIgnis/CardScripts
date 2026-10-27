--パージ・レイ
--Purge Ray
local s,id=GetID()
function s.initial_effect(c)
	--Tribute 1 Xyz Monster; during the End Phase, Special Summon from your Extra Deck, 1 "Number" monster with the same Type, but 1 Rank lower, as the Tributed monster had when it was on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
function s.costfilter(c,e,tp)
	return c:IsXyzMonster() and c:IsRankAbove(2)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp) end
	local sc=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp):GetFirst()
	local chain_data=e:GetChainData()
	chain_data.cost_type=sc:GetRace()
	chain_data.cost_rank=sc:GetRank()
	Duel.Release(sc,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_chk=e:GetLabel()==100
		e:SetLabel(0)
		return cost_chk
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chain_data=e:GetChainData()
	local sp_race=chain_data.cost_type
	local sp_rank=chain_data.cost_rank-1
	--During the End Phase, Special Summon from your Extra Deck, 1 "Number" monster with the same Type, but 1 Rank lower, as the Tributed monster had when it was on the field
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_CARD,0,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,sp_race,sp_rank)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.spfilter(c,e,tp,race,rank)
	return c:IsSetCard(SET_NUMBER) and c:IsRace(race) and c:IsRank(rank) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end