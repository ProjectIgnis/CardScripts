--超征竜－ディザスター
--Disaster, Dragon Ruler of Paranormalities
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Rank 7 Xyz monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsRank,7),nil,2)
	--Attach Level 7 "Dragon Ruler" monsters to this card when it is Xyz Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsXyzSummoned() end)
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	c:RegisterEffect(e1)
	--If this card has LIGHT, DARK, EARTH, WATER, FIRE, and WIND "Dragon Ruler" monsters as material, it gains 4600 ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.attributematcon)
	e2:SetValue(4600)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--If this card has LIGHT, DARK, EARTH, WATER, FIRE, and WIND "Dragon Ruler" monsters as material, it is unaffected by other cards' effects
	local e4=e2:Clone()
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(function(e,te) return te:GetOwner()~=e:GetOwner() end)
	c:RegisterEffect(e4)
end
s.listed_series={SET_DRAGON_RULER}
function s.attachfilter(c,xc,tp)
	return c:IsSetCard(SET_DRAGON_RULER) and c:IsLevel(7) and c:IsCanBeXyzMaterial(xc,tp,REASON_EFFECT) and c:IsFaceup()
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.attachfilter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.attachfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local g=Duel.SelectTarget(tp,s.attachfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,4,nil,c,tp)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		local gyg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,gyg,#gyg,tp,0)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_MZONE|LOCATION_GRAVE)
end
function s.rmfilter(c,og)
	return c:IsMonster() and c:IsAbleToRemove() and c:IsFaceup() and og:IsExists(Card.IsAttribute,1,nil,c:GetAttribute())
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	local tg=Duel.GetTargetCards(e):Filter(s.attachfilter,nil,c,tp):Remove(Card.IsImmuneToEffect,nil,e)
	if #tg>0 then
		Duel.Overlay(c,tg)
		local og=c:GetOverlayGroup()
		if Duel.IsExistingMatchingCard(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,1,nil,og) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local rg=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE|LOCATION_GRAVE,nil,og)
			Duel.BreakEffect()
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
function s.attributematcon(e)
	local og=e:GetHandler():GetOverlayGroup():Filter(Card.IsSetCard,nil,SET_DRAGON_RULER)
	return og:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) and og:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK)
		and og:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_EARTH) and og:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
		and og:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_FIRE) and og:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND)
end