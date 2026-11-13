--果て無き闇
--Endless Darkness
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Monsters you control with 4000 or more original ATK cannot be destroyed by card effects
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c)
		return c:GetBaseAttack()>=4000
	end)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	--Your opponent cannot target them with card effects
	local e1b=e1a:Clone()
	e1b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1b:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1b:SetValue(aux.tgoval)
	c:RegisterEffect(e1b)
	--During your Main Phase: You can add 1 card that mentions "Endless Darkness" from your Deck to your hand, except "Endless Darkness", then banish 1 card from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.endlessthtg)
	e2:SetOperation(s.endlessthop)
	c:RegisterEffect(e2)
	--If this card in its owner's possession is destroyed by an opponent's card: You can add 1 Level 10 monster with 0 or 4000 ATK from your Deck to your hand.
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.lv10thcon)
	e3:SetTarget(s.lv10thtg)
	e3:SetOperation(s.lv10thop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_ENDLESS_DARKNESS}
function s.endlessthfilter(c)
	return c:ListsCode(CARD_ENDLESS_DARKNESS) and not c:IsCode(CARD_ENDLESS_DARKNESS) and c:IsAbleToHand()
end
function s.endlessthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanRemove(tp)
		and Duel.IsExistingMatchingCard(s.endlessthfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.endlessthop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.endlessthfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
		if #rg>0 then
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.lv10thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and rp==1-tp
end
function s.lv10thfilter(c)
	return c:IsLevel(10) and c:IsAttack(0,4000) and c:IsAbleToHand()
end
function s.lv10thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.lv10thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.lv10thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.lv10thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end