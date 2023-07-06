--スリーカード召喚
--Three Card Summon
--Made by When
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
function s.spfilter1(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,2,c,c:GetLevel(),e,tp)
end
function s.spfilter2(c,lv,e,tp)
	return c:GetLevel()==lv and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
        and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	    local g1=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
        Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
        local g2=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,2,2,g1:GetFirst(),g1:GetFirst():GetLevel(),e,tp)
	    g1:Merge(g2)
	    Duel.ConfirmCards(1-tp,g1)
	    Duel.ShuffleHand(tp)
		if #g1>0 then
		    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			Duel.SpecialSummon(g1:Select(tp,1,1,nil),0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
