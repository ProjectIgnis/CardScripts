--JP name
--Cerynemesia, Mystical Beast of the Forest
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If this card is Normal or Special Summoned: You can banish (face-up) 1 Beast monster from your hand or face-up field until the End Phase; Special Summon 1 EARTH Beast monster from your Deck or GY, with an equal or lower Level than that monster's original Level, then your opponent can Special Summon 1 monster from their hand
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1a:SetProperty(EFFECT_FLAG_DELAY)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetCountLimit(1,id)
	e1a:SetCost(s.spcost)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--Your opponent's monsters that can attack must attack the monster you control with the highest ATK (their choice, if tied)
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_MUST_ATTACK)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_MUST_ATTACK_MONSTER)
	e2b:SetValue(function(e,c) return Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil):GetMaxGroup(Card.GetAttack):IsContains(c) end)
	c:RegisterEffect(e2b)
end
function s.spcostfilter(c,e,tp)
	return c:IsRace(RACE_BEAST) and c:HasLevel() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalLevel())
end
function s.spfilter(c,e,tp,lv)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_BEAST) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
	e:GetChainData().lv=sc:GetOriginalLevel()
	local return_op_function=sc:IsLocation(LOCATION_MZONE) and aux.DefaultFieldReturnOp
		or function(ag)
			Duel.SendtoHand(ag,nil,REASON_EFFECT)
		end
	--Banish (face-up) 1 Beast monster from your hand or face-up field until the End Phase
	aux.RemoveUntil(sc,POS_FACEUP,REASON_COST,PHASE_END,id,e,tp,return_op_function)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetChainData().lv
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local opp=1-tp
		Duel.ShuffleDeck(tp)
		if Duel.GetLocationCount(opp,LOCATION_MZONE,opp)>0 and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,opp,LOCATION_HAND,0,1,nil,e,0,opp,false,false)
			and Duel.SelectYesNo(opp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,opp,HINTMSG_SPSUMMON)
			local og=Duel.SelectMatchingCard(opp,Card.IsCanBeSpecialSummoned,opp,LOCATION_HAND,0,1,1,nil,e,0,opp,false,false)
			if #og>0 then
				Duel.BreakEffect()
				Duel.SpecialSummon(og,0,opp,opp,false,false,POS_FACEUP)
			end
		end
	end
end