--幻影騎士団ブレイクソード (Anime)
--The Phantom Knights of Break Sword (Anime)
--rescripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Xyz Summon
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,2)
	c:EnableReviveLimit()
	--registration before leaving
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetTarget(s.sumtg)
	e1:SetOperation(s.sumop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetOverlayGroup()
	if #g==0 then return end
	g:KeepAlive()
	e:SetLabelObject(g)
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():GetLabelObject()
	local g1,g2
	if g then
		g1=g:Filter(Card.IsMonster,nil)
		g2=g:Filter(s.spfilter,nil,e,tp)
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if chk==0 then return g and g1 and g2 and #g1==#g2 and ft>=#g2 end
	local loc=0
	if g2:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then loc=LOCATION_GRAVE end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,#g2,tp,loc)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	g=g:Filter(s.spfilter,nil,e,tp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if ft<#g then return end
	for tc in aux.Next(g) do
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		--change Level
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end