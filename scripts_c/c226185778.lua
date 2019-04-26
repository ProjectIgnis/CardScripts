--Daigusto Codors
function c226185778.initial_effect(c)
	--semi-nomi
	c:EnableReviveLimit()
	--synchro procedure
	aux.AddSynchroProcedure(c,nil,1,1,aux.NonTunerEx(Card.IsSetCard,0x10),1,99)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,226185778)
	e1:SetCost(c226185778.descost)
	e1:SetTarget(c226185778.destarget)
	e1:SetOperation(c226185778.desoperation)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c226185778.spcondition)
	e2:SetTarget(c226185778.sptarget)
	e2:SetOperation(c226185778.spoperation)
	c:RegisterEffect(e2)
end
function c226185778.dcfilter(c)
	return c:IsSetCard(0x10) and c:IsAbleToDeckAsCost()
end
function c226185778.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185778.dcfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.SelectMatchingCard(tp,c226185778.dcfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,0,REASON_COST)
end
function c226185778.destarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),nil,nil)
end
function c226185778.desoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	if dg:GetCount()>0 then
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function c226185778.spcondition(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_BATTLE+REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c226185778.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c226185778.sptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c226185778.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c226185778.spoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectMatchingCard(tp,c226185778.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if sg:GetCount()>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end