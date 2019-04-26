--Black Illusion Necromancy
function c210354100.initial_effect(c)
	--Activate card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Activate effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77770001,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c210354100.target)
	e2:SetOperation(c210354100.operation)
	c:RegisterEffect(e2)
	--Banish from grave
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetTarget(c210354100.reptg)
	e3:SetValue(c210354100.repval)
	e3:SetOperation(c210354100.repop)
	c:RegisterEffect(e3)
end
function c210354100.tgfilter(c,e)
	return (c:IsSetCard(0x110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466)
		and c:GetEquipCount()~=0 and c:GetEquipGroup():IsExists(c210354100.desfilter,1,nil)
end
function c210354100.desfilter(c)
	return c:IsLocation(LOCATION_SZONE) and c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER
end
function c210354100.eqfilter(c,tp)
	return (c:IsLocation(LOCATION_MZONE) or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToChangeControler()
end
function c210354100.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c210354100.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210354100.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and (Duel.IsPlayerCanDraw(tp,1) or Duel.IsExistingMatchingCard(c210354100.eqfilter,1-tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c,tp)) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,c210354100.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,0,1,nil)
end
function c210354100.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc:GetEquipGroup():IsExists(c210354100.desfilter,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sc=tc:GetEquipGroup():FilterSelect(tp,c210354100.desfilter,1,1,nil)
		if Duel.Destroy(sc,REASON_EFFECT) and (Duel.IsPlayerCanDraw(tp,1)
			or Duel.IsExistingMatchingCard(c210354100.eqfilter,1-tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c,tp)) then
			Duel.BreakEffect()
			local op=0
			if Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(c210354100.eqfilter,1-tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,c,tp) then
				op=Duel.SelectOption(tp,aux.Stringid(210354100,2),aux.Stringid(210354100,3))
			elseif not Duel.IsPlayerCanDraw(tp,1) then
				op=1
			end
			if op==0 then
				Duel.Draw(tp,1,REASON_EFFECT)
			else
				local te=tc:GetCardEffect(89785779)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local g=Duel.SelectMatchingCard(tp,c210354100.eqfilter,1-tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tc1,tp)
				local sg=g:GetFirst()
				te:GetOperation()(tc,te:GetLabelObject(),tp,sg)
			end
		end
	end
end
function c210354100.repfilter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x110) and c:IsType(TYPE_FUSION)) or c:IsCode(64631466)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) 
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT+REASON_BATTLE)
end
function c210354100.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c210354100.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c210354100.repval(e,c)
	return c210354100.repfilter(c,e:GetHandlerPlayer())
end
function c210354100.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
