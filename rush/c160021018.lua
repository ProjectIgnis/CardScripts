--Ｐ・Ｍ ソニックホース
--Plasmatic Model Sonic Horse
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add card to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160021021,160021057}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
end
function s.thfilter(c)
	return c:IsCode(160021021,160021057) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	if Duel.SendtoGrave(c,REASON_COST)<1 then return end
	--Effect
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,aux.dncheck,1,tp)
	Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
end