--天空城塞クーロン
--Kowloon, Citadel of the Sky
--scripted by pyrQ
local s,id=GetID()
local TOKEN_MECHBEAST=id+100
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Monsters you control that were Normal or Special Summoned from the hand gain 500 ATK/DEF
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_UPDATE_ATTACK)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetTargetRange(LOCATION_MZONE,0)
	e1a:SetTarget(function(e,c) return (c:IsNormalSummoned() or c:IsSpecialSummoned()) and c:IsSummonLocation(LOCATION_HAND) end)
	e1a:SetValue(500)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e1b)
	--During your Main Phase: You can Special Summon 1 "Mechbeast Token" (Machine/EARTH/Level 6/ATK 2000/DEF 2000) to your opponent's field, and if you do, add 1 "Blitzclique" monster from your Deck to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,{id,0})
	e2:SetTarget(s.tokentg)
	e2:SetOperation(s.tokenop)
	c:RegisterEffect(e2)
	--If a card(s) is destroyed by your "Blitzclique" card's effect, while this card is in your GY: You can add this card to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.selfthcon)
	e3:SetTarget(s.selfthtg)
	e3:SetOperation(s.selfthop)
	c:RegisterEffect(e3)
end
s.listed_names={TOKEN_MECHBEAST}
s.listed_series={SET_BLITZCLIQUE}
function s.thfilter(c)
	return c:IsSetCard(SET_BLITZCLIQUE) and c:IsMonster() and c:IsAbleToHand()
end
function s.tokentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_MECHBEAST,0,TYPES_TOKEN,2000,2000,6,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,1-tp)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.tokenop(e,tp,eg,ep,ev,re,r,rp)
	local opp=1-tp
	if Duel.GetLocationCount(opp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_MECHBEAST,0,TYPES_TOKEN,2000,2000,6,RACE_MACHINE,ATTRIBUTE_EARTH,POS_FACEUP,opp) then return end
	local token=Duel.CreateToken(tp,TOKEN_MECHBEAST)
	if Duel.SpecialSummon(token,0,tp,opp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(opp,g)
		end
	end
end
function s.selfthcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re and not eg:IsContains(e:GetHandler()) and eg:IsExists(Card.IsReason,1,nil,REASON_EFFECT)
		and re:GetHandler() and re:GetHandler():IsSetCard(SET_BLITZCLIQUE)
end
function s.selfthtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
end
function s.selfthop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end