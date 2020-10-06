--転生炎獣ウルヴィー
--Salamangreat Wolvie
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--A link monster using this card cannot be destroyed by battle or card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(s.lkcon)
	e1:SetOperation(s.lkop)
	c:RegisterEffect(e1)
	--Add 1 FIRE monster from GY, if this card is special summoned
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon1)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--Add 1 FIRE monster from GY, if this card is added from GY
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_HAND)
	e3:SetCondition(s.thcon2)
	e3:SetCost(s.thcost)
	c:RegisterEffect(e3)
end
	--If sent as link material
function s.lkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK
end
	--A link monster using this card cannot be destroyed by battle or card effects this turn
function s.lkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3008)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	rc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	rc:RegisterEffect(e2)
end
	--If this card was special summoned from GY
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
	--If this card was added from GY to hand
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (r&REASON_EFFECT)~=0 and c:IsPreviousLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
	--Reveal this card from hand
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
	--Check for FIRE monster that can be added
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand()
end
	--Activation legality
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
	--Add 1 FIRE monster from GY
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end