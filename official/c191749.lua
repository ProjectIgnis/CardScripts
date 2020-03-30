--ヒーローフラッシュ！！
--Hero Flash!!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x3008}
function s.cfilter(c,code)
	return c:IsCode(code) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,74825788)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,213326)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,37318031)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,63703130) end
	local tc1=Duel.GetFirstMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,nil,74825788)
	local tc2=Duel.GetFirstMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,nil,213326)
	local tc3=Duel.GetFirstMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,nil,37318031)
	local tc4=Duel.GetFirstMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,nil,63703130)
	local g=Group.FromCards(tc1,tc2,tc3,tc4)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0x3008) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.dfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsSetCard(0x3008)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local dg=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_MZONE,0,nil)
	local tc=dg:GetFirst()
	for tc in aux.Next(dg) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
