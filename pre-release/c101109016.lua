-- 丘と芽吹の春化精
-- Vernalizer Fairy of Hills and Blooms
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Effect destruction protection
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x27e))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- Search 1 "Vernalizer Fairy" card
	c:RegisterEffect(Effect.CreateVernalizerSPEffect(c,id,0,CATEGORY_TOHAND+CATEGORY_SEARCH,s.thtg,s.thop))
end
s.listed_names={id}
s.listed_series={0x27e}
function s.thfilter(c)
	return c:IsSetCard(0x27e) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,g) 
		return true
	end
end