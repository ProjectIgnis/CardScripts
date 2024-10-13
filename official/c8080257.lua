--炎の剣舞
--Flame Swordsdance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 monster from your Extra Deck and change the position of a monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.exsptg)
	e1:SetOperation(s.exspop)
	c:RegisterEffect(e1)
	--Special Summon 1 "Flame Swordsman" or 1 monster that mentions it from your Deck or Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_BATTLE_START|TIMING_BATTLE_END)
	e2:SetCondition(function(_,tp) return Duel.IsBattlePhase() and Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(s.deckexspcost)
	e2:SetTarget(s.deckexsptg)
	e2:SetOperation(s.deckexspop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_FLAME_SWORDSMAN}
function s.exspfilter(c,e,tp)
	return c:IsLevelBelow(7) and c:IsType(TYPE_FUSION) and (c:IsCode(CARD_FLAME_SWORDSMAN) or c:ListsCode(CARD_FLAME_SWORDSMAN))
		and Duel.GetLocationCountFromEx(tp,tp,nil,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.exsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_POSITION,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.exspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g==0 or Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local pg=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #pg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local tc=pg:Select(tp,1,1,nil)
		Duel.HintSelection(tc,true)
		Duel.BreakEffect()
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
function s.costfilter(c,e,tp)
	return c:IsPosition(POS_FACEDOWN_DEFENSE)
		and Duel.IsExistingMatchingCard(s.deckexspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.deckexspfilter(c,e,tp,exc)
	if c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,exc)<=0 then return false end
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,exc,c)<=0 then return false end
	return (c:IsCode(CARD_FLAME_SWORDSMAN) or c:ListsCode(CARD_FLAME_SWORDSMAN)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.deckexspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil,e,tp) end
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.deckexsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckexspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.deckexspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.deckexspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if sc then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end