-- シトリスの蟲惑魔
-- Traptrix Pinguicula
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 2 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,2)
	-- Unaffected
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	-- Search 1 "Traptrix" monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.dxmcostgen(1,1))
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2,false,REGISTER_FLAG_DETACH_XMAT)
	-- Attach card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetTarget(s.ovtg)
	e3:SetOperation(s.ovop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCategory(CATEGORY_LEAVE_GRAVE)
	e4:SetCode(EVENT_TO_GRAVE)
	c:RegisterEffect(e4)
end
s.listed_series={SET_TRAPTRIX}
function s.immval(e,te)
	if te:IsActiveType(TYPE_TRAP) then return true end
	local tc=te:GetOwner()
	local c=e:GetHandler()
	return c~=tc and te:IsActivated() and te:IsActiveType(TYPE_MONSTER)
		and c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,tc:GetRace())
end
function s.thfilter(c)
	return c:IsSetCard(SET_TRAPTRIX) and c:IsMonster() and c:IsAbleToHand()
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
function s.ovfilter(c,e,xc,tp)
	return c:IsMonster() and c:IsReason(REASON_EFFECT) and c:GetOwner()==1-tp
		and not c:IsImmuneToEffect(e) and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT)
end
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.ovfilter,1,nil,e,e:GetHandler(),tp) end
	if e:GetCode()==EVENT_TO_GRAVE then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,1-tp,0)
	end
end
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsType(TYPE_XYZ) or c:IsImmuneToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=eg:FilterSelect(tp,s.ovfilter,1,1,nil,e,c,tp)
	if #g>0 then
		Duel.Overlay(c,g)
	end
end