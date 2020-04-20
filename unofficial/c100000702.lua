--ダークネス・レインクロー
function c100000702.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPSUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c100000702.condition)
	e1:SetCost(c100000702.cost)
	e1:SetTarget(c100000702.target)
	e1:SetOperation(c100000702.activate)
	c:RegisterEffect(e1)
end
function c100000702.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function c100000702.cosfilter(c,e,tp)
	return c:IsCode(100000701) and c:IsAbleToGraveAsCost()
end
function c100000702.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
	 and Duel.IsExistingMatchingCard(c100000702.cosfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	local tc=Duel.SelectMatchingCard(tp,c100000702.cosfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	tc:AddCard(e:GetHandler())
	Duel.SendtoGrave(tc,REASON_COST)
end
function c100000702.filter(c,e,tp)
	return c:IsCode(60417395) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function c100000702.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c100000702.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c100000702.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c100000702.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end