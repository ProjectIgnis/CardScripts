--Ｎｏ．４６ 神影龍ドラッグルーオン
--Number 46: Dragluon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 8 Dragon-Type monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),8,2)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler()) end)
	e1:SetCost(Cost.Detach(1))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.xyz_number=46
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControlerCanBeChanged()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctfilter(chkc) end
	if chk==0 then return true end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingTarget(s.ctfilter,tp,0,LOCATION_MZONE,1,nil)
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{true,aux.Stringid(id,3)})
	e:SetLabel(op)
	e:SetProperty(0)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectTarget(tp,s.ctfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 Dragon-Type monster from your hand
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Target 1 Dragon-Type monster your opponent controls; take control of that target
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			Duel.GetControl(tc,tp)
		end
		e:SetProperty(0)
	elseif op==3 then
		local c=e:GetHandler()
		--Dragon-Type monsters your opponent controls cannot activate their effects until the end of your opponent's turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(function(e,c) return c:IsRace(RACE_DRAGON) end)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e1,tp)
		aux.RegisterClientHint(c,0,tp,0,1,aux.Stringid(id,4))
	end
end
