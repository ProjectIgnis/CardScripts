--神鳥の排撃
--Simorgh Repulsion
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Discard 1 Winged Beast monster; return all cards in your opponent's Spell & Trap Zones to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(Cost.Discard(function(c) return c:IsRace(RACE_WINGEDBEAST) end))
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--You can banish this card from your GY; reveal 1 Winged Beast monster in your hand, and if you do, reduce the Levels of monsters in your hand with that name by 1 for the rest of this turn (even after they are Summoned)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LVCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_STZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_STZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,0,LOCATION_STZONE,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.lvfilter(c)
	return c:IsRace(RACE_WINGEDBEAST) and c:IsLevelAbove(2) and not c:IsPublic()
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,nil,1,tp,LOCATION_HAND)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local sc=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.ConfirmCards(1-tp,sc)
	Duel.ShuffleHand(tp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_HAND,0,nil,sc:GetCode())
	for hc in g:Iter() do
		--Reduce the Levels of monsters in your hand with that name by 1 for the rest of this turn (even after they are Summoned)
		hc:UpdateLevel(-1,RESET_EVENT|(RESETS_STANDARD_PHASE_END&~RESET_TOFIELD),c)
	end
end