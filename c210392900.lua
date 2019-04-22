--Amorphage Acedia
--designed by Sanct
--scripted by Larry126
function c210392900.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c210392900.matfilter,2,2)
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c210392900.repcon)
	e1:SetTarget(c210392900.reptg)
	e1:SetValue(c210392900.repval)
	c:RegisterEffect(e1)
	--to pzone
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45974017,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,210392900)
	e2:SetTarget(c210392900.pctg)
	e2:SetOperation(c210392900.pcop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30086349,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,210392900)
	e3:SetTarget(c210392900.sptg)
	e3:SetOperation(c210392900.spop)
	c:RegisterEffect(e3)  
end
function c210392900.matfilter(c,lc,sumtype,tp)
	return c:IsSetCard(0xe0) and c:IsType(TYPE_PENDULUM,lc,sumtype,tp)
end
function c210392900.repcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetLinkedGroup():IsExists(Card.IsSetCard,1,nil,0xe0)
end
function c210392900.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_PZONE)
		and c:IsSetCard(0xe0) and not c:IsReason(REASON_REPLACE)
end
function c210392900.repfilter2(c)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xe0) and not c:IsForbidden()
end
function c210392900.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c210392900.repfilter,nil,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(c210392900.repfilter2,tp,LOCATION_DECK,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		local tc=Duel.SelectMatchingCard(tp,c210392900.repfilter2,tp,LOCATION_DECK,0,1,1,nil)
		if tc then
			Duel.SendtoExtraP(tc,tp,REASON_EFFECT)
			return true
		else return false
		end
	else return false
	end
end
function c210392900.repval(e,c)
	return c210392900.repfilter(c,e:GetHandlerPlayer())
end
function c210392900.pcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xe0) and c:IsType(TYPE_PENDULUM) and not c:IsForbidden()
end
function c210392900.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
			and Duel.IsExistingMatchingCard(c210392900.pcfilter,tp,LOCATION_EXTRA,0,1,nil)
	end
end
function c210392900.pcop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local g=Duel.SelectMatchingCard(tp,c210392900.pcfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function c210392900.spfilter(c,e,tp,zone)
	return c:IsType(TYPE_PENDULUM) and c:IsSetCard(0xe0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
function c210392900.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone()
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and c210392900.spfilter(chkc,e,tp,zone) end
	if chk==0 then return zone~=0 and Duel.IsExistingTarget(c210392900.spfilter,tp,LOCATION_PZONE,0,1,nil,e,tp,zone) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,c210392900.spfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp,zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function c210392900.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and zone~=0 then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
