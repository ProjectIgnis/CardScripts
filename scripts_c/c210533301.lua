--Madoka Kaname
function c210533301.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE)
	c:SetCounterLimit(0x1,5)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--increase pendulum scale
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210533301,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c210533301.piscon)
	e1:SetTarget(c210533301.pist)
	e1:SetOperation(c210533301.piso)
	c:RegisterEffect(e1)
	--when a card is destroyed, place counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c210533301.asc)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(210533301,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCondition(c210533301.dscon)
	e3:SetCost(c210533301.dscos)
	e3:SetTarget(c210533301.dst)
	e3:SetOperation(c210533301.dso)
	c:RegisterEffect(e3)
end
function c210533301.pisf(c)
	return c:IsFaceup() and c:IsSetCard(0xf72)
end
function c210533301.piscon(e,tp)
	return Duel.IsExistingMatchingCard(c210533301.pisf,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
function c210533301.pist(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
function c210533301.piso(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LSCALE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(5)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_RSCALE)
	c:RegisterEffect(e2)
end
function c210533301.asc(e,tp,eg,ep,ev,re,r,rp)
	local count=0
	if not eg then return end
	for tc in aux.Next(eg) do
		if tc:IsPreviousSetCard(0xf72) and tc:GetPreviousControler()==tp and tc:GetPreviousTypeOnField()&TYPE_PENDULUM>0 
			and tc:IsPreviousLocation(LOCATION_MZONE+LOCATION_PZONE) and tc:IsReason(REASON_DESTROY) then
			count=count+1
		end
	end
	if count>0 then
		e:GetHandler():AddCounter(0x1,count,true)
	end
end
function c210533301.dsf(c)
	return c:IsCode(210533307) and c:IsFaceup()
end
function c210533301.dscon(e,tp)
	return Duel.IsExistingMatchingCard(c210533301.dsf,tp,LOCATION_MZONE,0,1,nil)
end
function c210533301.dscos(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,5,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,5,REASON_COST)
end
function c210533301.dsof(c,e,tp)
	return c:IsCode(210533308) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210533301.dst(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsExistingMatchingCard(c210533301.dsof,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
end
function c210533301.dso(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
	if Duel.GetLocationCountFromEx(tp)<=0 or not Duel.IsExistingMatchingCard(c210533301.dsof,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		or not Duel.SelectYesNo(tp,aux.Stringid(210533301,2)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,c210533301.dsof,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	Duel.BreakEffect()
	Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end