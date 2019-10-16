--Brotherhood of the Fire Fist - Elephant
--Scripted by Hel
local s,id=GetID()
function s.initial_effect(c)
local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--shuffle add
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.addtg)
	e3:SetOperation(s.addop)
	c:RegisterEffect(e3)
end
s.listed_names={id}
s.listed_series={0x7c,0x79}
function s.cfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP)) and c:IsSetCard(0x7c) and c:IsAbleToGraveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local nc=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_SZONE,0,1,nil)
	if chk==0 then 
		if Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) then return true else return nc end
	end
	if nc and not (Duel.IsPlayerAffectedByEffect(tp,CARD_FIRE_FIST_EAGLE) and Duel.SelectYesNo(tp,aux.Stringid(CARD_FIRE_FIST_EAGLE,0))) then 
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
			Duel.SendtoGrave(g,REASON_COST)
	end
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x79) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.shfilter(c)
	return c:IsAbleToDeck() and c:IsSetCard(0x7c) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end
function s.addfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x79) and c:IsAbleToHand() and c:IsLevelAbove(5)
end
function s.addtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.shfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.shfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,s.shfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.addop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)~=0 then
		local g=Duel.GetMatchingGroup(s.addfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.BreakEffect()
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local gt=Duel.SelectMatchingCard(tp,s.addfilter,tp,LOCATION_DECK,0,1,1,nil)
			if #gt>0 then
				Duel.SendtoHand(gt,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,gt)
			end
		end
	end
end

