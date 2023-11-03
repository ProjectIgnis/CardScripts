--急転直下
--Out of the Blue
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Self destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.desop1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.desop2)
	c:RegisterEffect(e3)
	e3:SetLabelObject(e2)
	--Return cards in the GY to the Deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TODECK)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.retcon)
	e4:SetTarget(s.rettg)
	e4:SetOperation(s.retop)
	c:RegisterEffect(e4)
end
function s.desop1(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)
		or not eg:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		e:SetLabelObject(nil)
	else e:SetLabelObject(re) end
end
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local pe=e:GetLabelObject():GetLabelObject()
	if pe and pe==re then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler()==e:GetHandler()
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,1-tp,LOCATION_GRAVE)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT,1-tp)
end