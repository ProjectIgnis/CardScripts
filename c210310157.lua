--Number C89: Diablosis the Mind Crusher
--AlphaKretin
function c210310157.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,8,4)
	c:EnableReviveLimit()
	--atk/def
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c210310157.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--remove field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4035,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c210310157.matcon)
	e3:SetCost(c210310157.rmcost)
	e3:SetTarget(c210310157.rmtg)
	e3:SetOperation(c210310157.rmop)
	c:RegisterEffect(e3)
	--remove deck
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4035,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c210310157.matcon)
	e4:SetCost(c210310157.dkcost)
	e4:SetTarget(c210310157.dktg)
	e4:SetOperation(c210310157.dkop)
	c:RegisterEffect(e4)
end
function c210310157.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end
function c210310157.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,95474755)
end
function c210310157.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	local r={}
	for i=1,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0) do
		r[i]=i
	end
	local num=Duel.AnnounceNumber(1,table.unpack(r))
	e:SetLabel(num)
	local g=Duel.GetDecktopGroup(tp,num)
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
function c210310157.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetLabel(),nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function c210310157.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end
function c210310157.dkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local num=c:GetOverlayCount()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,num,num,REASON_COST) end
	c:RemoveOverlayCard(tp,num,num,REASON_COST)
end
function c210310157.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local num=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED):FilterCount(Card.IsFacedown,nil)
	if chk==0 then return num>0 
	and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=num end
	local g=Duel.GetDecktopGroup(1-tp,num)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
function c210310157.dkop(e,tp,eg,ep,ev,re,r,rp)
	local num=Duel.GetFieldGroup(tp,0,LOCATION_REMOVED):FilterCount(Card.IsFacedown,nil)
	local g=Duel.GetDecktopGroup(1-tp,num)
	Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
end