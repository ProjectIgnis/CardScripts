--ＧＰ－スタート・エンジン
--Gold Pride - Start Your Engines!
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 3 "Gold Pride" monsters, summon 1 and destroy a target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOLD_PRIDE}
function s.desfilter(c,tp,g)
	return c:IsSummonPlayer(1-tp) and g:IsContains(c)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(SET_GOLD_PRIDE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsPublic()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.desfilter(chkc,tp,eg) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp,eg)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,3,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp,eg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,3,3,nil,e,tp)
	if #g~=3 then return end
	Duel.ConfirmCards(1-tp,g)
	local sc=g:RandomSelect(1-tp,1):GetFirst()
	if sc and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.BreakEffect()
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end