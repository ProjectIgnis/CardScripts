--バスター・コネクター
--Assault Connector
--Scripted by Eerie Code
function c120401031.initial_effect(c)
	c:SetSPSummonOnce(120401031)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1)
	--set
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c120401031.settg)
	e1:SetOperation(c120401031.setop)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c120401031.spcost)
	e2:SetTarget(c120401031.sptg)
	e2:SetOperation(c120401031.spop)
	c:RegisterEffect(e2)
end
function c120401031.setfilter(c)
	return c:IsCode(80280737) and c:IsSSetable()
end
function c120401031.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401031.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function c120401031.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c120401031.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if tc then
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1)
	end
end
function c120401031.spcfilter(c,e,tp,zone)
	return c:IsSetCard(0x104f) and c.assault_mode and not c:IsPublic() and c:IsAbleToDeck()
		and Duel.IsExistingMatchingCard(c120401031.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,zone,c.assault_mode)
end
function c120401031.spfilter(c,e,tp,zone,cd)
	return c:IsCode(cd) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
function c120401031.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone()
	if chk==0 then return zone~=0 and Duel.IsExistingMatchingCard(c120401031.spcfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,c120401031.spcfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	e:SetLabelObject(g:GetFirst())
end
function c120401031.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetLabelObject(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function c120401031.spop(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabelObject()
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or not ac or not ac:IsLocation(LOCATION_HAND) then return end
	local zone=c:GetLinkedZone()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c120401031.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,zone,ac.assault_mode):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2,true)
		Duel.SpecialSummonComplete()
		Duel.SendtoDeck(ac,nil,2,REASON_EFFECT)
	end
end
