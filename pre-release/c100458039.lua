--異解△領域－ヴァルヴォルス
--Xenovader△ Territory - Valvols
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate this card by banishing (face-down) 5 cards from your GY and/or the top of your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--During your Main Phase: You can add 1 of your face-down banished "Xenovader△" cards to your hand, except "Xenovader△ Territory - Valvols". You can only use this effect of "Xenovader△ Territory - Valvols" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--While you control a Level 5 or higher "Xenovader△" monster and you have no cards in your Deck, your opponent cannot activate cards or effects during your turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.actcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
s.listed_series={SET_XENOVADER}
s.listed_names={id}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetDecktopGroup(tp,5)
	local dc=dg:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)
	local gyct=Duel.GetMatchingGroupCount(Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,nil,POS_FACEDOWN)
	if chk==0 then return dc==5 or gyct+dc>=5 end
	local rg=Group.CreateGroup()
	if dc<5 or (gyct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		rg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_GRAVE,0,math.max(5-dc,1),5,nil,POS_FACEDOWN)
		Duel.HintSelection(rg)
	end
	if #rg<5 then
		rg=rg+Duel.GetDecktopGroup(tp,5-#rg)
	end
	Duel.DisableShuffleCheck()
	Duel.Remove(rg,POS_FACEDOWN,REASON_COST)
end
function s.thfilter(c)
	return c:IsFacedown() and c:IsSetCard(SET_XENOVADER) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.actfilter(c)
	return c:IsLevelAbove(5) and c:IsSetCard(SET_XENOVADER) and c:IsFaceup()
end
function s.actcon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0
		and Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_MZONE,0,1,nil)
end