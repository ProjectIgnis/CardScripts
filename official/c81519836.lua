-- 苗と霞の春化精
-- Vernalizer Fairy of Seedlings and Haze
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Reduce ATK of non-"Vernalizer" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(_,c) return not c:IsSetCard(0x183) end)
	e1:SetValue(-600)
	c:RegisterEffect(e1)
	-- Search 1 EARTH Fairy monster
	c:RegisterEffect(Effect.CreateVernalizerSPEffect(c,id,0,CATEGORY_TOHAND+CATEGORY_SEARCH,s.thtg,s.thop))
end
s.listed_names={id}
s.listed_series={0x183}
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_FAIRY) and not c:IsCode(id) and c:IsAbleToHand()
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