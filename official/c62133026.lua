--花と野原の春化精
--Vernusylph of the Flowering Fields
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Effect targetting protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_VERNUSYLPH))
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Add 1 "Vernalizer Fairy" card from the GY to the hand
	c:RegisterEffect(Effect.CreateVernalizerSPEffect(c,id,0,CATEGORY_TOHAND,s.thtg,s.thop))
end
s.listed_names={id}
s.listed_series={SET_VERNUSYLPH}
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g) 
		return true
	end
end