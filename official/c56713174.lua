--雷電龍－サンダー・ドラゴン
--Thunder Dragondark
--scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Thunder Dragondark" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.thtg(s.dragondarkfilter))
	e1:SetOperation(s.thop(s.dragondarkfilter))
	c:RegisterEffect(e1)
	--Add 1 "Thunder Dragon" card from your Deck to your hand, except "Thunder Dragondark"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg(s.thundrafilter))
	e2:SetOperation(s.thop(s.thundrafilter))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(function(e) return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_THUNDER_DRAGON}
s.listed_names={id}
function s.dragondarkfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.thundrafilter(c)
	return c:IsSetCard(SET_THUNDER_DRAGON) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(filter)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.IsExistingMatchingCard(filter,tp,LOCATION_DECK,0,1,nil) end
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.thop(filter)
	return function(e,tp,eg,ep,ev,re,r,rp)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,filter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
