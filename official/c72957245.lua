--魔救の息吹
--Adamancipator Signs
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 rock monster from GY in defense position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Part of "Adamacia" archetype
s.listed_series={0x140}
	--Check for rock monster
function s.filter(c,e,tp)
	return c:IsRace(RACE_ROCK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
	--Check for level 4 or lower rock monster
function s.tdfilter(c)
	return c:IsRace(RACE_ROCK) and c:IsLevelBelow(4)
end
	--Special summon target in defense position, then if it was an "Adamacia" monster, rig deck
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		local dc=Duel.GetOperatedGroup():GetFirst()
		if dc:IsSetCard(0x140) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
			local tc=g:GetFirst()
			if tc then
				Duel.BreakEffect()
				Duel.ShuffleDeck(tp)
				Duel.MoveSequence(tc,0)
				Duel.ConfirmDecktop(tp,1)
			end
		end
	end
end
