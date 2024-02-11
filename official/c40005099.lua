--不知火流 転生の陣
--Shiranui Style Synthesis
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 end)
	e2:SetCost(s.effcost)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tgfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsDefense(0) and c:IsFaceup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if not chkc:IsControler(tp) then return false end
		local op=e:GetLabel()
		if op==1 then
			return chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp)
		elseif op==2 then
			return chkc:IsLocation(LOCATION_REMOVED) and s.tgfilter(chkc)
		end
	end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	local b2=Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOGRAVE)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 Zombie monster with 0 DEF from your GY
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	elseif op==2 then
		--Return 1 of your banished Zombie monsters with 0 DEF to your GY
		Duel.SendtoGrave(tc,REASON_EFFECT|REASON_RETURN)
	end
end