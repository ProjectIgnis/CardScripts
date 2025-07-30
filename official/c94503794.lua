--漆梏の喰獣 ケルゼブス
--Cerzebuth, Laimargia of the Ebon Irons
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2+ Level 7 monsters
	Xyz.AddProcedure(c,nil,7,2,nil,nil,Xyz.InfiniteMats)
	--Gains 700 ATK for each material attached to it
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,c) return c:GetOverlayCount()*700 end)
	c:RegisterEffect(e1)
	--Attach that activated Normal or Quick-Play Spell Card on the field to this face-up card, and if you do, this card is unaffected by that activated effect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.attachcon)
	e2:SetOperation(s.attachop)
	c:RegisterEffect(e2)
	--Set 1 Spell attached to this card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
function s.attachcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and (rc:IsNormalSpell() or rc:IsQuickPlaySpell()) and rc:IsOnField()
		and rc:IsCanBeXyzMaterial(e:GetHandler(),tp,REASON_EFFECT)
end
function s.attachop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and rc:IsRelateToEffect(re)
		and not c:IsImmuneToEffect(e) and not rc:IsImmuneToEffect(e)
		and rc:IsCanBeXyzMaterial(c,tp,REASON_EFFECT) then
		Duel.Overlay(c,rc)
		if not c:GetOverlayGroup():IsContains(rc) then return end
		rc:CancelToGrave()
		--This card is unaffected by that activated effect
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetValue(function(e,te) return te==re end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
	end
end
function s.setfilter(c)
	return c:IsSpell() and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetOverlayGroup():IsExists(s.setfilter,1,nil) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=c:GetOverlayGroup():FilterSelect(tp,s.setfilter,1,1,nil)
	if #g>0 then
		Duel.SSet(tp,g)
	end
end