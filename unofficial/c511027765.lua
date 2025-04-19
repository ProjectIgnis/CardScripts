--スリーカード・サモン
--Three Card Summon
--Made by When
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.spfilter(c,e,tp,g)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsLevel,2,c,c:GetLevel())
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLevel)==1 and sg:IsExists(Card.IsCanBeSpecialSummoned,1,nil,e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsLevelBelow,tp,LOCATION_HAND,0,nil,4)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and #g>=3 and g:IsExists(s.spfilter,1,nil,e,tp,g) end
	local tg=aux.SelectUnselectGroup(g,e,tp,3,3,s.spcheck,1,tp,HINTMSG_CONFIRM)
	Duel.SetTargetCard(tg)
	Duel.ConfirmCards(1-tp,tg)
	Duel.ShuffleHand(tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.GetTargetCards(e):FilterSelect(tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,tp,false,false)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end