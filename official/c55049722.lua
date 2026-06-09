--Ｓ－Ｆｏｒｃｅ チェイス
--S-Force Chase
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Target face-up cards your opponent controls, up to the number of "S-Force" monsters you control with different names; return them to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--If an "S-Force" monster you control would banish a card(s) from your hand to activate its effect, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_COST_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return e:GetHandler():IsAbleToRemoveAsCost() end)
	e2:SetValue(s.repval)
	e2:SetOperation(function(base) Duel.Remove(base:GetHandler(),POS_FACEUP,REASON_COST) end)
	c:RegisterEffect(e2)
end
s.listed_series={SET_S_FORCE}
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_S_FORCE),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingTarget(aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_S_FORCE),tp,LOCATION_MZONE,0,nil):GetClassCount(Card.GetCode)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsAbleToHand),tp,0,LOCATION_ONFIELD,1,ct,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
function s.repval(base,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
			and c:IsSetCard(SET_S_FORCE) and extracon(base,e,tp,e,tp,eg,ep,ev,re,r,rp,chk)
	end
	return Chain.IsTriggeringControler(0,tp) and Chain.IsTriggeringLocation(0,LOCATION_MZONE)
		and Chain.IsTriggeringPosition(0,POS_FACEUP) and Chain.IsTriggeringSetcode(0,SET_S_FORCE)
		and extracon(base,e,tp,e,tp,eg,ep,ev,re,r,rp,chk)
end
