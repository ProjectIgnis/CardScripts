--星なる影 ゲニウス
--Nehshaddoll Genius
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Targeted "Shaddoll" monster becomes unaffected by monster effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.immtg)
	e1:SetOperation(s.immop)
	c:RegisterEffect(e1)
	--Targeted monster cannot activate its effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
	--Lists "Shaddoll" archetype
s.listed_series={SET_SHADDOLL}
	--Check for "Shaddoll" monster
function s.immfilter(c)
	return c:IsSetCard(SET_SHADDOLL) and c:IsFaceup()
end
	--Activation legality
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.immfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.immfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.immfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
	--Make your "Shaddoll" monster becomes unaffected by monster effects
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		--Unaffected by monster effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3101)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(s.efilter)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
	--Unaffected by other monster effects
function s.efilter(e,te)
	return te:IsMonsterEffect() and te:GetOwner()~=e:GetHandler()
end
	--If sent to GY by card effect
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
	--Targeted monster cannot activate its effects
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_EFFECT) then
		--Cannot activate its effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end