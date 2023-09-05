--神速召喚
--Thunderspeed Summon
--Scripted by fiftyfour
local s,id=GetID()
function s.initial_effect(c)
	--Normal Summon 1 Level 10 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMING_BATTLE_START)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function() return Duel.IsMainPhase() or Duel.IsBattlePhase() end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={id,CARD_JACK_KNIGHT,CARD_KING_KNIGHT,CARD_QUEEN_KNIGHT}
function s.thfilter(c)
	return c:IsMonster() and c:GetTextAttack()==-2 and c:IsLevel(10)
		and c:IsAttributeExcept(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.mfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.sfilter(c)
	return c:IsSummonable(true,nil) and c:IsLevel(10)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
	local b=Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,CARD_JACK_KNIGHT)
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,CARD_KING_KNIGHT)
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,CARD_QUEEN_KNIGHT)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return a or b end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil)
	local b=Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,CARD_JACK_KNIGHT)
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,CARD_KING_KNIGHT)
		and Duel.IsExistingMatchingCard(s.mfilter,tp,LOCATION_MZONE,0,1,nil,CARD_QUEEN_KNIGHT)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	if not (a or b) then return end
	if (not a and b) or (b and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,g)
			if Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_HAND,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				Duel.BreakEffect()
				Duel.ShuffleHand(tp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
				local g2=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
				local tc=g2:GetFirst()
				if tc then
					Duel.Summon(tp,tc,true,nil)
				end
			end
		end
	elseif a then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local g=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			Duel.Summon(tp,tc,true,nil)
		end
	end
end