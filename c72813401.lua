--HSR-GOMガン
--Hi-Speedroid GOM Gun
--Scripted by Naim and Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WIND),2,2)
	c:EnableReviveLimit()
	--summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.nstg)
	e1:SetOperation(s.nsop)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.listed_series={0x2016}
function s.nsfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsSummonable(true,nil)
end
function s.nstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.nsfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
function s.nsop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local g=Duel.SelectMatchingCard(tp,s.nsfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		Duel.Summon(tp,tc,true,nil)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
function s.filter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1) and c:IsAbleToHand()
end
function s.rescon(lv)
	return function(sg,e,tp,mg)
		return sg:GetSum(Card.GetLevel)==lv and sg:GetClassCount(Card.GetCode)==2
	end
end
function s.cfilter(c,g)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(c:GetLevel()),0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local sc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,g):GetFirst()
	Duel.Remove(sc,POS_FACEUP,REASON_COST)
	e:SetLabel(sc:GetLevel())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(e:GetLabel()),1,tp,HINTMSG_SELECT)
	if #sg~=2 then return end
	Duel.ConfirmCards(1-tp,sg)
	Duel.ShuffleDeck(tp)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATOHAND)
	local cg=sg:Select(1-tp,1,1,nil)
	local tc=cg:GetFirst()
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
	sg:RemoveCard(tc)
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

