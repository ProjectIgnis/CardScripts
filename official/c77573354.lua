--蕾禍ノ曝藤
--Ragnaraika Wisteria of Woe
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card as a Normal Monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E|TIMING_MAIN_END)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Shuffle 2 Insect, Plant, and/or Reptile monsters into the Deck and Set this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.IsPhase(PHASE_END) end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_RAGNARAIKA}
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_RAGNARAIKA,TYPE_MONSTER|TYPE_NORMAL,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
function s.ragnaraikafilter(c)
	return c:IsSetCard(SET_RAGNARAIKA) and c:IsLinkMonster() and c:IsFaceup()
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_RAGNARAIKA,TYPE_MONSTER|TYPE_NORMAL,1600,0,4,RACE_PLANT,ATTRIBUTE_DARK)) then return end
	c:AddMonsterAttribute(TYPE_NORMAL|TYPE_TRAP)
	Duel.SpecialSummonStep(c,1,tp,tp,true,false,POS_FACEUP)
	c:AddMonsterAttributeComplete()
	if Duel.SpecialSummonComplete()==0 then return end
	if Duel.IsExistingMatchingCard(s.ragnaraikafilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,2,nil)
		if #g==0 then return end
		Duel.BreakEffect()
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.tdfilter(c)
	return c:IsRace(RACE_INSECT|RACE_PLANT|RACE_REPTILE) and c:IsAbleToDeck() and c:IsFaceup()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,2,2,nil)
	if #g~=2 then return end
	Duel.HintSelection(g)
	local c=e:GetHandler()
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK|LOCATION_EXTRA)
		and c:IsRelateToEffect(e) and c:IsSSetable() then
		Duel.SSet(tp,c)
	end
end