--セクステット・サモン
--Sextet Summon
--Scripted by Eerie Code
local s,id=GetID()
local TYPE_FULL=TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK
local TYPE_ARRAY={TYPE_FUSION,TYPE_RITUAL,TYPE_SYNCHRO,TYPE_XYZ,TYPE_PENDULUM,TYPE_LINK }
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsType(TYPE_FULL)
		and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToRemove()
end
function s.spfilter(c,e,tp,rc)
	if c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)==0 then return false end
	return c:GetOriginalRace()==rc and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.check(sg,e,tp,mg)
	if #sg<6 then return false end
	local loc=LOCATION_EXTRA
	if aux.ChkfMMZ(1)(sg,e,tp,mg) then loc=loc+LOCATION_DECK end
	for _,ty in ipairs(TYPE_ARRAY) do
		if not sg:IsExists(Card.IsType,1,nil,ty) then return false end
	end
	return sg:GetClassCount(Card.GetOriginalRace)==1
		and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp,sg:GetFirst():GetOriginalRace())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then 
		local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
		return aux.SelectUnselectGroup(g,e,tp,6,6,s.check,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,6,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	local rg=aux.SelectUnselectGroup(g,e,tp,6,6,s.check,1,tp,HINTMSG_REMOVE)
	if #rg==6 and Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)==6 then
		Duel.BreakEffect()
		local rc=rg:GetFirst():GetOriginalRace()
		local loc=LOCATION_EXTRA
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc+LOCATION_DECK end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,loc,0,1,1,nil,e,tp,rc)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
