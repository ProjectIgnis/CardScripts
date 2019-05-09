--Christmas Treekuriboh
--concept by Xeno
--scripted by Larry126
function c210334000.initial_effect(c)
	--xyz summon
	Xyz.AddProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	--untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--indes
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetCondition(c210334000.indcon)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	c:RegisterEffect(e3)
	--no battle damage
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	--special summon
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c210334000.cost)
	e5:SetTarget(c210334000.target)
	e5:SetOperation(c210334000.activate)
	c:RegisterEffect(e5)
end
function c210334000.indcon(e)
	return e:GetHandler():GetOverlayCount()>0
end
function c210334000.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
function c210334000.filter1(c,e,tp)
	return c:IsSetCard(0xa4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp)
		and Duel.IsExistingMatchingCard(c210334000.filter2,tp,LOCATION_DECK,0,1,nil,e,tp,c)
end
function c210334000.filter2(c,e,tp,tc)
	return c:IsSetCard(0xa4) and not c:IsCode(tc:GetCode())
		and c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP,1-tp)
end
function c210334000.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c210334000.filter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function c210334000.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<1 then return end
	local g=Duel.GetMatchingGroup(c210334000.filter1,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local sg1=g:Select(tp,1,1,nil)
		local sg2=Duel.SelectMatchingCard(tp,c210334000.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,sg1:GetFirst())
		sg1:Merge(sg2)
		Duel.ConfirmCards(1-tp,sg1)
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
		local tg=sg1:FilterSelect(1-tp,Card.IsCanBeSpecialSummoned,1,1,nil,e,0,1-tp,false,false,POS_FACEUP,1-tp)
		if tg:GetCount()>0 and Duel.SpecialSummon(tg,0,1-tp,1-tp,false,false,POS_FACEUP) and Duel.SelectYesNo(tp,1152) then
			sg1:Sub(tg)
			Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end