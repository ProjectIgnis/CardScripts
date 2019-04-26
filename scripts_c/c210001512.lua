--Istrakan Site - Solar Tree
function c210001512.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c210001512.actoperation)
	e1:SetCountLimit(1,210001512)
	c:RegisterEffect(e1)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c210001512.atkcondition(">"))
	e2:SetTarget(c210001512.atkfilter(ATTRIBUTE_LIGHT))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCondition(c210001512.atkcondition("<"))
	e3:SetTarget(c210001512.atkfilter(ATTRIBUTE_DARK))
	c:RegisterEffect(e3)
end
function c210001512.afilter(c)
	return c:IsSetCard(0xf71) and c:IsAbleToHand()
end
function c210001512.actoperation(e,tp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.IsExistingMatchingCard(c210001512.afilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(210001512,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,c210001512.afilter,tp,LOCATION_DECK,0,1,1,nil)
		if g and #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
function c210001512.atkcondition(str)
	return function (e)
		if str=="<" then
			return Duel.GetLP(e:GetHandlerPlayer())<Duel.GetLP(1-e:GetHandlerPlayer())
		elseif str=="=" then
			return Duel.GetLP(e:GetHandlerPlayer())==Duel.GetLP(1-e:GetHandlerPlayer())
		elseif str=="<=" then
			return Duel.GetLP(e:GetHandlerPlayer())<=Duel.GetLP(1-e:GetHandlerPlayer())
		elseif str==">" then
			return Duel.GetLP(e:GetHandlerPlayer())>Duel.GetLP(1-e:GetHandlerPlayer())
		elseif str==">=" then
			return Duel.GetLP(e:GetHandlerPlayer())>=Duel.GetLP(1-e:GetHandlerPlayer())
		else
			return true
		end
	end
end
function c210001512.atkfilter(att)
	return function(e,c)
		return c:IsSetCard(0xf69) and c:IsAttribute(att)
	end
end