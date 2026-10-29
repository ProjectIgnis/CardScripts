--ファイナル・ギアス
--Final Geas
local s,id=GetID()
function s.initial_effect(c)
	--If a monster(s) with an original Level of 7 or higher has been sent from each player's field to the GY this turn: Banish as many monsters from the GYs as possible, then you can Special Summon the highest-Level Spellcaster monster among those banished monsters (your choice, if tied)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.HasFlagEffect(0,id) and Duel.HasFlagEffect(1,id)
	end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E|TIMING_TOGRAVE)
	c:RegisterEffect(e1)
	--Keep track of monsters with an original Level of 7 or higher being sent from the field to the GY
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			for ec in eg:Iter() do
				local prev_ctrl=ec:GetPreviousControler()
				if ec:GetOriginalLevel()>=7 and ec:IsPreviousLocation(LOCATION_MZONE)
					and not Duel.HasFlagEffect(prev_ctrl,id) then
					Duel.RegisterFlagEffect(prev_ctrl,id,RESET_PHASE|PHASE_END,0,1)
				end
			end
		end)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_REMOVED)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:HasLevel() and c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToRemove),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if #g>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g:Match(s.spfilter,nil,e,tp)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local sg=g:GetMaxGroup(Card.GetLevel)
		if #sg>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg=sg:Select(tp,1,1,nil)
		end
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end