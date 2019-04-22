--Resubversion
function c210001101.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c210001101.target)
	e1:SetOperation(c210001101.operation)
	c:RegisterEffect(e1)
end
function c210001101.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0xfed) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp)
end
function c210001101.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c210001101.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(c210001101.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SelectTarget(tp,c210001101.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
end
function c210001101.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e1,true)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x1fe0000)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(210001101,RESET_EVENT+0x15e0000,0,1)
		local e3=Effect.CreateEffect(c)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCategory(CATEGORY_DAMAGE)
		e3:SetCode(EVENT_TO_HAND)
		e3:SetCountLimit(1)
		e3:SetLabelObject(tc)
		e3:SetCondition(c210001101.retcon)
		e3:SetOperation(c210001101.retop)
		Duel.RegisterEffect(e3,tp)
		Duel.SpecialSummonComplete()
	end
end
function c210001101.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or tc:GetFlagEffect(210001101)==0 then
		e:Reset()
		return false
	else
		return eg:IsContains(tc)
	end
end
function c210001101.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Damage(1-tp,500,REASON_EFFECT)
	tc:ResetFlagEffect(210001101)
	e:Reset()
end
--[[
	Target 1 Level 4 or lower "Subverted" monster in your GY;
	Special Summon it in face-up defense position, but its effects are negated.
	If that monster is returned to the hand, inflict 500 damage to your opponent.
--]]