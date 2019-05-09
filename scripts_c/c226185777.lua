--Daigusto Raptos
function c226185777.initial_effect(c)
	--semi-nomi
	c:EnableReviveLimit()
	--synchro procedure
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsSetCard,0x10),1,99)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,226185777)
	e1:SetCost(c226185777.descost)
	e1:SetTarget(c226185777.destarget)
	e1:SetOperation(c226185777.desoperation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c226185777.spcondition)
	e2:SetTarget(c226185777.sptarget)
	e2:SetOperation(c226185777.spoperation)
	c:RegisterEffect(e2)
end
function c226185777.dcfilter(c)
	return c:IsSetCard(0x10) and c:IsAbleToDeckAsCost()
end
function c226185777.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185777.dcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c226185777.dcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,0,REASON_COST)
end
function c226185777.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function c226185777.destarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(c226185777.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.SelectTarget(tp,c226185777.dfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),nil,nil)
end
function c226185777.desoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	if dg:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function c226185777.spcondition(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_BATTLE+REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c226185777.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and not c:IsCode(226185777)
end
function c226185777.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_DECK end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
	if chk==0 then return loc>0 and Duel.IsExistingMatchingCard(c226185777.spfilter,tp,loc,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function c226185777.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local loc=0
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then loc=loc|LOCATION_DECK end
	if Duel.GetLocationCountFromEx(tp)>0 then loc=loc|LOCATION_EXTRA end
	if loc==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,c226185777.spfilter,tp,loc,0,1,1,nil,e,tp)
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
	end
end