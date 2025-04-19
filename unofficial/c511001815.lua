--ゲート・ガーディアンのぎ式
--Gate Guardian Ritual
local s,id=GetID()
function s.initial_effect(c)
	--Ritual Summon "Gate Guardian" from your hand or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.fit_monster={25833572} --"Gate Guardian"
s.listed_names=CARDS_SANGA_KAZEJIN_SUIJIN
function s.ritfilter(c,e,tp,m)
	local cd=c:GetCode()
	if cd~=25833572 or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false) then return false end
	if m:IsContains(c) then
		m:RemoveCard(c)
		result=m:IsExists(Card.IsCode,1,nil,CARD_SUIJIN) and m:IsExists(Card.IsCode,1,nil,CARD_KAZEJIN) 
			and m:IsExists(Card.IsCode,1,nil,CARD_SANGA_OF_THE_THUNDER)
		m:AddCard(c)
	else
		result=m:IsExists(Card.IsCode,1,nil,CARD_SUIJIN) and m:IsExists(Card.IsCode,1,nil,CARD_KAZEJIN) 
			and m:IsExists(Card.IsCode,1,nil,CARD_SANGA_OF_THE_THUNDER)
	end
	return result
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		return Duel.IsExistingMatchingCard(s.ritfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp,mg)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local mg=Duel.GetRitualMaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,s.ritfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,mg)
	if #tg>0 then
		local tc=tg:GetFirst()
		mg:RemoveCard(tc)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		local mat1=mg:FilterSelect(tp,Card.IsCode,1,1,nil,CARD_SUIJIN)
		local mat2=mg:FilterSelect(tp,Card.IsCode,1,1,nil,CARD_KAZEJIN)
		local mat3=mg:FilterSelect(tp,Card.IsCode,1,1,nil,CARD_SANGA_OF_THE_THUNDER)
		mat1:Merge(mat2)
		mat1:Merge(mat3)
		tc:SetMaterial(mat1)
		Duel.ReleaseRitualMaterial(mat1)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end