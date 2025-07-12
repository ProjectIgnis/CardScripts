--Ｎｏ．４６ 神影龍ドラッグルーオン
--Number 46: Dragluon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 8 Dragon monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON),8,2)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,e:GetHandler()) end)
	e1:SetCost(Cost.DetachFromSelf(1))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.xyz_number=46
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.ctrlfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsFaceup() and c:IsControlerCanBeChanged()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return e:GetLabel()==2 and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.ctrlfilter(chkc) end
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.IsExistingTarget(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil)
	local b3=not Duel.HasFlagEffect(1-tp,id)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	e:SetCategory(0)
	e:SetProperty(0)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(CATEGORY_CONTROL)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
		local g=Duel.SelectTarget(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 Dragon monster from your hand
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--Target 1 Dragon monster your opponent controls; take control of that target
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) and tc:IsFaceup() then
			Duel.GetControl(tc,tp)
		end
	elseif op==3 then
		local opp=1-tp
		if Duel.HasFlagEffect(opp,id) then return end
		Duel.RegisterFlagEffect(opp,id,RESET_PHASE|PHASE_END|RESET_OPPO_TURN,0,1)
		local c=e:GetHandler()
		aux.RegisterClientHint(c,nil,tp,0,1,aux.Stringid(id,4),RESET_OPPO_TURN)
		--Dragon monsters your opponent controls cannot activate their effects until the end of your opponent's turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetTarget(function(e,c) return c:IsRace(RACE_DRAGON) end)
		e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,1)
		Duel.RegisterEffect(e1,tp)
	end
end
