--JP Name
--R.B. The Brute Blues
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2+ Machine monsters
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_MACHINE),2)
	--Gains total original ATK of "R.B." monsters this card points to while it points to an "R.B." monster
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetLinkedGroup():IsExists(aux.FaceupFilter(Card.IsSetCard,SET_RB),1,nil) end)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--Can make a second attack during each Battle Phase while it points to a "R.B." monster
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetCondition(function(e) return e:GetHandler():GetLinkedGroup():IsExists(aux.FaceupFilter(Card.IsSetCard,SET_RB),1,nil) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Cannot be destroyed by battle or card effects while it points to a "R.B." monster
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_SINGLE)
	e3a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3a:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCondition(function(e) return e:GetHandler():GetLinkedGroup():IsExists(aux.FaceupFilter(Card.IsSetCard,SET_RB),1,nil) end)
	e3a:SetValue(1)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3b)
	--Add 1 "R.B." card from your Deck to your hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={SET_RB}
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_RB) and c:GetBaseAttack()>=0
end
function s.atkval(e,c)
	return c:GetLinkedGroup():Filter(s.atkfilter,nil):GetSum(Card.GetBaseAttack)
end
function s.thfilter(c)
	return c:IsSetCard(SET_RB) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
