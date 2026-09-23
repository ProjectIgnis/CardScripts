--おろかな墓荒らし
--Foolish Graverobber
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 card that mentions "Dark Time Wizard" from your Deck to the GY, except "Foolish Graverobber", then you can Special Summon 1 monster from either GY to your field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; Set to your field, 1 Spell/Trap that mentions "Dark Time Wizard" from your GY, except "Foolish Graverobber", or 1 Spell/Trap from your opponent's GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	e2:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_DARK_TIME_WIZARD,id}
function s.tgfilter(c)
	return c:ListsCode(CARD_DARK_TIME_WIZARD) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local sc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,0,tp,false,false)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanBeSpecialSummoned),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,0,tp,false,false)
		if #g>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.setfilter(c,opp)
	return c:IsSpellTrap() and c:IsSSetable() and ((c:ListsCode(CARD_DARK_TIME_WIZARD) and not c:IsCode(id)) or c:IsControler(opp))
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,PLAYER_EITHER,LOCATION_GRAVE)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,1-tp)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SSet(tp,g)
	end
end