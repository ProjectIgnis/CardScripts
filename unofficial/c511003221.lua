--ダーク・アーキタイプ (Anime)
--Dark Archetype (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil)
end
function s.spfilter(c,e,tp,dam,rg)
	if not c:HasLevel() or not c:IsAttackBelow(dam) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return false end
	if rg:IsContains(c) then
		rg:RemoveCard(c)
		result=rg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
		rg:AddCard(c)
	else
		result=rg:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,99)
	end
	return result
end
function s.tgfilter(c)
	return c:HasLevel() and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local dam=Duel.GetBattleDamage(tp)
	if chkc then return false end
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND,0,nil)
		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,dam,rg)
	end
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,dam,rg)
	Duel.SetTargetCard(g:GetFirst())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local dam=Duel.GetBattleDamage(tp)
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsAttackBelow(dam) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	local rg=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND,0,nil)
	rg:RemoveCard(tc)
	if rg:CheckWithSumEqual(Card.GetLevel,tc:GetLevel(),1,99) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local tg=rg:SelectWithSumEqual(tp,Card.GetLevel,tc:GetLevel(),1,99)
		Duel.SendtoGrave(tg,REASON_COST)
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end