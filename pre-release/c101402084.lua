--JP Name
--Kumenyo, the Nine-Hued Deer
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 4 LIGHT and/or DARK monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK),4,2,nil,nil,Xyz.InfiniteMats)
	--During the Main Phase (Quick Effect): You can detach 1 material from this card; attach 1 card from your hand, GY, or banishment to this card, except the detached material. You can only use this effect of "Kumenyo, the Nine-Hued Deer" once per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsMainPhase()
	end)
	e1:SetCost(Cost.DetachFromSelf(1,1,function(e,og)
		og:GetFirst():CreateEffectRelation(e)
	end))
	e1:SetTarget(s.attachtg)
	e1:SetOperation(s.attachop)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e1)
	--Gains the following effects, based on the number of different Monster Types attached to it
	--● 2+: Cannot be destroyed by card effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e)
		return e:GetHandler():GetOverlayGroup():GetBinClassCount(Card.GetRace)>=2
	end)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--● 3+: Draw 2 cards instead of 1 for your normal draw during your Draw Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_DRAW_COUNT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(function(e)
		return e:GetHandler():GetOverlayGroup():GetBinClassCount(Card.GetRace)>=3
	end)
	e3:SetValue(2)
	c:RegisterEffect(e3)
end
function s.attachtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		return c:IsXyzMonster() and Duel.IsExistingMatchingCard(Card.IsCanBeXyzMaterial,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,c,tp,REASON_EFFECT)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local detached_material=e:GetChainData().cost_detached_materials:GetFirst()
	local except=detached_material:IsRelateToEffect(e) and detached_material or nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsCanBeXyzMaterial),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,except,c,tp,REASON_EFFECT):GetFirst()
	if sc then
		if sc:IsLocation(LOCATION_HAND) then
			Duel.ConfirmCards(1-tp,sc)
		else
			Duel.HintSelection(sc)
		end
		Duel.Overlay(c,sc)
	end
end