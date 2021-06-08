--運命の契約
--Contract of Destiny
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x207)
	c:SetCounterLimit(0x207,1)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.counter)
	c:RegisterEffect(e2)
	--xyz summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_names={27062594}
s.listed_series={0x7f}
s.counter_place_list={0x207}
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
function s.counter(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.cfilter,nil,tp)
	if ct>0 then
		e:GetHandler():AddCounter(0x207,1,true)
	end
end
function s.spcfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,1-tp) and rp==1-tp
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x207,1,REASON_COST) end
	c:RemoveCounter(tp,0x207,1,REASON_EFFECT)
end
function s.gyfilter(c,e,tp)
	return c:IsCode(27062594) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToGrave()
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.spfilter(c,e,tp,gc)
	return c:IsSetCard(0x7f) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
		and Duel.GetLocationCountFromEx(tp,tp,gc,c)>0 
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local gc=Duel.SelectMatchingCard(tp,s.gyfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_ONFIELD,0,1,1,nil,e,tp):GetFirst()
	if gc and Duel.SendtoGrave(gc,REASON_EFFECT)>0 and gc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,gc):GetFirst()
		if xc and Duel.SpecialSummon(xc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)>0 then
			Duel.Overlay(xc,c)
		end
	end
end