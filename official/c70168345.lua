--黒・魔・導・連・弾
--Dark Magic Twin Burst
--Scripted by ahtelel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN_GIRL,CARD_DARK_MAGICIAN}
function s.atkfilter(c)
	return (c:IsFaceup() or not c:IsOnField()) and c:IsCode(CARD_DARK_MAGICIAN_GIRL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsCode(CARD_DARK_MAGICIAN) end
	if chk==0 then return Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_MZONE,0,1,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=0
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
		local bc=g:GetFirst()
		for bc in aux.Next(g) do
			atk=atk+bc:GetAttack()
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
