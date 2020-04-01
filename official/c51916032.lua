--人造人間－サイコ・ジャッカー
local s,id=GetID()
function s.initial_effect(c)
	--change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e1:SetValue(77585513)
	c:RegisterEffect(e1)
	--tohand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0xbc}
s.listed_names={id}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	Duel.Release(e:GetHandler(),REASON_COST)
end
function s.filter(c)
	return c:IsSetCard(0xbc) and not c:IsCode(id) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.cffilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xbc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	local cg=Duel.GetMatchingGroup(s.cffilter,tp,0,LOCATION_SZONE,nil)
	if #cg>0 then
		Duel.BreakEffect()
		Duel.ConfirmCards(tp,cg)
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		local ct=cg:FilterCount(Card.IsType,nil,TYPE_TRAP)
		if ct>ft then ct=ft end
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if ct>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,ct,nil)
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
