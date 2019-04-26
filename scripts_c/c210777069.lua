--Great Swarm Hatchery
--designed byNitrogames#8002
--scripted by Naim (credits for Alphakretin, Larry126 and Andre for the help)
function c210777069.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c210777069.cost)
	e1:SetTarget(c210777069.target)
	e1:SetOperation(c210777069.activate)
	e1:SetCountLimit(1,210777069)
	c:RegisterEffect(e1)
end
function c210777069.spfilter1(c,e,tp)
	return c:IsSetCard(0xf11) and c:IsCanBeSpecialSummoned(e,186,tp,false,false)
end
function c210777069.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return  Duel.GetFlagEffect(tp,210777069)==0 
	and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler())
	and Duel.IsExistingMatchingCard(c210777069.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,60,REASON_COST+REASON_DISCARD)
	Duel.RegisterFlagEffect(tp,210777069,RESET_DISABLE,0,1)
	e:SetLabel(ct)
end
function c210777069.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210777069.spfilter1,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK)
end
function c210777069.activate(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetCondition(c210777069.spcon1)
	e1:SetOperation(c210777069.spop1)
	e1:SetLabel(e:GetLabel())
	Duel.RegisterEffect(e1,tp)
end
function c210777069.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
function c210777069.spfilter2(c,e,tp)
	return c:IsSetCard(0xf11) and c:IsCanBeSpecialSummoned(e,186,tp,false,false)
end
function c210777069.spop1(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and e:GetLabel()>0
		and Duel.IsExistingMatchingCard(c210777069.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(210777069,1)) then
			e:SetLabel(e:GetLabel()-1)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(210777069,2))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCountLimit(1)
		e1:SetTarget(c210777069.sptg2)
		e1:SetOperation(c210777069.spop2)
		Duel.RegisterEffect(e1,tp)
		if e:GetLabel()==0 then
			Duel.ResetFlagEffect(tp,210777069)
		end
	else
		e:Reset()
	end
end
function c210777069.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function c210777069.spop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 and  Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210777069.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,186,tp,tp,false,false,POS_FACEUP)
	end
	e:Reset()
end