--ボルテージサモン
--Voltage Summon
--scripted by:urielkama and MLD
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Level 4 or lower monster from the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={511004125} --Kurivolt Token
function s.filter(c)
	return c:IsReleasableByEffect() and c:IsCode(511004125)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #sg>0 and Duel.GetMZoneCount(tp,sg)>=#sg
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,#sg,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local ct=Duel.Release(rg,REASON_EFFECT)
	if ct==0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and ct>1 then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if #g>=ct then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,ct,ct,nil)
			Duel.BreakEffect()
			local c=e:GetHandler()
			for tc in sg:Iter() do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e2)
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_SET_BASE_ATTACK)
				e3:SetValue(0)
				e3:SetReset(RESET_EVENT|RESETS_STANDARD)
				tc:RegisterEffect(e3)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_SET_BASE_DEFENSE)
				tc:RegisterEffect(e4)
			end
			Duel.SpecialSummonComplete()
		end
	end
end