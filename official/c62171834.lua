--夢幻の夢魔鏡
--Dream Mirror Phantasms
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--When activated, add 1 "Dream Mirror" monster from deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Your monsters gain 500 ATK/DEF while "Dream Mirror of Joy" is on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.condition(CARD_DREAM_MIRROR_JOY))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Your opponent's monsters lose 500 ATK/DEF while "Dream Mirror of Terror" is on the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetCondition(s.condition(CARD_DREAM_MIRROR_TERROR))
	e4:SetValue(-500)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
s.listed_series={SET_DREAM_MIRROR}
s.listed_names={CARD_DREAM_MIRROR_JOY,CARD_DREAM_MIRROR_TERROR}
function s.filter(c)
	return c:IsSetCard(SET_DREAM_MIRROR) and c:IsMonster() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.condition(cid)
	return function(e,c)
				return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,cid),0,LOCATION_FZONE,LOCATION_FZONE,1,nil)
			end
end