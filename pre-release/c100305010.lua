--クリアー・ウォール
--Clear Wall
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Add 1 monster that mentions "Clear World" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_CLEAR_WORLD),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Monsters that mention "Clear World" cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(function(e,c) return c:ListsCode(CARD_CLEAR_WORLD) end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--You take no battle damage from battles involving monsters that mention "Clear World"
	local e3=e2:Clone()
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetValue(aux.ChangeBattleDamage(0,0))
	c:RegisterEffect(e3)
	--All effects of "Clear World" are applied to your opponent regardless of the Attributes they control
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CLEAR_WALL)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.clearwallcon)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_CLEAR_WORLD}
function s.thfilter(c)
	return c:ListsCode(CARD_CLEAR_WORLD) and c:IsMonster() and c:IsAbleToHand()
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
function s.clearwallconfilter(c)
	return c:IsLevelAbove(7) and c:ListsCode(CARD_CLEAR_WORLD) and c:IsFaceup()
end
function s.clearwallcon(e)
	return Duel.IsExistingMatchingCard(s.clearwallconfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end