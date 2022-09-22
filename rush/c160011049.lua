--花牙分身
--Shadow Flower Duplication
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Special Summon up to 3 Level 4 or lower WATER monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.spfilter(c,e,tp,lvl)
	return c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL) and c:IsLevelBelow(lvl) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel())
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,chk)
	--Requirement
	local td=Duel.SelectMatchingCard(tp,Card.IsAbleToDeckOrExtraAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoDeck(td,nil,SEQ_DECKBOTTOM,REASON_COST)~0 then
		--Effect
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<1 then return end
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
		local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp):GetFirst()
		if tc then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,math.min(ft,2),nil,e,tp,tc:GetLevel())
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
				local sg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
				if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevel,5),tp,LOCATION_MZONE,0,1,nil) 
					and #sg>0 
					and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
					Duel.BreakEffect()
					Duel.Destroy(sg,REASON_EFFECT)
				end
			end
		end
	end
end