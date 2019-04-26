--Variety Comes Out (Anime)
local s,id=GetID()
function s.initial_effect(c)
   --Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,e,tp,g,maxc)
	local tmax=maxc
	if c:GetSequence()<5 then tmax=tmax-1 end
	if tmax<=0 then return end
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToExtraAsCost()
		and g:CheckWithSumEqual(Card.GetLevel,c:GetLevel(),1,maxc)
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local maxc=ft+1
	if maxc>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then maxc=1 end
	if chk==0 then
		local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,e,tp,spg,maxc)
	end
	local spg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp,spg,maxc)
	local lv=cg:GetFirst():GetLevel()
	Duel.SendtoDeck(cg,nil,0,REASON_COST)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=spg:SelectWithSumEqual(tp,Card.GetLevel,lv,1,maxc)
	Duel.SetTargetCard(sg)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	local ct=#g
	if ct==0 or (ct>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		or ct>Duel.GetLocationCount(tp,LOCATION_MZONE) then return end
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
