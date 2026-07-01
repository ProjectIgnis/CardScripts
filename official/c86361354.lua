--同族感電ウィルス
--Tribe-Shocking Virus
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn: You can banish 1 monster from your hand; destroy all face-up monsters on the field with the same Type as that monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.descostfilter(c)
	return c:IsMonster() and c:IsAbleToRemoveAsCost()
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,c:GetRace()),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	if chk==0 then return Duel.IsExistingMatchingCard(s.descostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.descostfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	e:SetLabel(sc:GetRace())
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local cost_skip_chk=e:GetLabel()==-100
		e:SetLabel(0)
		return cost_skip_chk
	end
	local race=e:GetLabel()
	Duel.SetTargetParam(race)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,race),0,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local race=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsRace,race),0,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end