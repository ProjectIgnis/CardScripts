--Aethis, Scribe of Gusto
function c226185773.initial_effect(c)
	--add to hand or grave
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,226185773)
	e1:SetTarget(c226185773.thogtarget)
	e1:SetOperation(c226185773.thogoperation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--normal summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,226185773+100)
	e3:SetCost(c226185773.scost)
	e3:SetTarget(c226185773.starget)
	e3:SetOperation(c226185773.soperation)
	c:RegisterEffect(e3)
	--special summon a turner gusto
	local e4=Effect.CreateEffect(c)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,226185773+200)
	e4:SetCondition(c226185773.sscondition)
	e4:SetTarget(c226185773.sstarget)
	e4:SetOperation(c226185773.ssoperation)
	c:RegisterEffect(e4)
end
function c226185773.thogfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function c226185773.thogtarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185773.thogfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c226185773.thogoperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(226185773,0))
	local g=Duel.SelectMatchingCard(tp,c226185773.thogfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		if tc:IsAbleToGrave() and (not tc:IsAbleToHand() or Duel.SelectYesNo(tp,aux.Stringid(226185773,1))) then
			Duel.SendtoGrave(tc,REASON_EFFECT)
		else
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
function c226185773.csfilter(c)
	return c:IsSetCard(0x10) and c:IsAbleToDeckAsCost()
end
function c226185773.scost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185773.csfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local tg=Duel.SelectMatchingCard(tp,c226185773.csfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(tg,tp,0,REASON_COST)
end
function c226185773.sfilter(c)
	return c:IsSetCard(0x10) and c:IsType(TYPE_MONSTER) and c:IsSummonable(true,nil)
end
function c226185773.starget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c226185773.sfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function c226185773.soperation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local tg=Duel.SelectMatchingCard(tp,c226185773.sfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=tg:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
end
function c226185773.sscondition(e,tp,eg,ep,ev,re,r,rp)
	return r&(REASON_BATTLE+REASON_EFFECT)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c226185773.spfilter(c,e,tp)
	return c:IsSetCard(0x10) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c226185773.sstarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c226185773.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c226185773.ssoperation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,c226185773.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if tg:GetCount()>0 then
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end