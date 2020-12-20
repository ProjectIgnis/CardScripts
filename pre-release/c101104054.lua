--スプリガンズ・ブーティー
--Sprigguns Booty
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Make 1 of opponent's monsters unable to activate its effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)return eg:IsExists(s.atrfilter,1,nil,tp,rp)end)
	e1:SetTarget(s.catg)
	e1:SetOperation(s.caop)
	c:RegisterEffect(e1)
	--Activate 1 "Vast Desert – Gold Golgonda" from deck or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.accost)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,tp)end)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
end
	--Specifically lists "Vast Desert – Gold Golgonda"
s.listed_names={60884672}

	--If your Xyz monster leaves the field because of card effect
function s.atrfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_XYZ) and c:GetPreviousControler()==tp and c:IsReason(REASON_EFFECT)
end
	--Activation legality
function s.catg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc:IsType(TYPE_EFFECT) end
	if chk==0 then return Duel.IsExistingTarget(aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,0,LOCATION_MZONE,1,1,nil)
end
	--Make 1 of opponent's monsters unable to activate its effects
function s.caop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		--Cannot activate its effects
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3202)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
	--Send this face-up card to GY as cost
function s.accost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
	--Check for "Vast Desert – Gold Golgonda"
function s.filter(c,tp)
	return c:IsCode(60884672) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true)
end
	--Activate 1 "Vast Desert – Gold Golgonda" from deck or GY
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	aux.PlayFieldSpell(tc,e,tp,eg,ep,ev,re,r,rp)
end