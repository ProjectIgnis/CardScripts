--魂喰魔獣 バズー
--Bazoo the Soul Eater Beast
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--Any Xyz Material detached from a monster is banished instead of being sent to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_OVERLAY) and not c:IsReason(REASON_LOST_TARGET) end)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	--Detach 1 material from this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(Card.IsMonsterCard,1,nil) end)
	e2:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk) if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end end)
	e2:SetOperation(s.detachop)
	c:RegisterEffect(e2)
	--Attach up to 3 cards in the GY(s) to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DETACH_MATERIAL)
	e3:SetCondition(function(e) return e:GetHandler():GetOverlayCount()==0 end)
	e3:SetTarget(s.attachtg)
	e3:SetOperation(s.attachop)
	c:RegisterEffect(e3)
end
function s.detachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanBeXyzMaterial,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,c,tp,REASON_EFFECT) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,Card.IsCanBeXyzMaterial,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil,c,tp,REASON_EFFECT)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,tp,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Filter(Card.IsCanBeXyzMaterial,nil,c,tp,REASON_EFFECT):Remove(Card.IsImmuneToEffect,nil,e)
	if #tg>0 then
		Duel.Overlay(c,tg)
	end
end