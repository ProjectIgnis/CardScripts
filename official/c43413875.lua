--花札衛－芒に月－
--Flower Cardian Zebra Grass with Moon
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Must first be Special Summoned (from your hand) by Tributing 1 Level 8 "Flower Cardian" monster, except "Flower Cardian Zebra Grass with Moon"
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.selfspcon)
	e0:SetTarget(s.selfsptg)
	e0:SetOperation(s.selfspop)
	c:RegisterEffect(e0)
	--Draw 1 card, and if you do, show it, then you can Special Summon it if it is a "Flower Cardian" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(s.drsptg)
	e1:SetOperation(s.drspop)
	c:RegisterEffect(e1)
	--Draw 1 card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_FLOWER_CARDIAN}
s.listed_names={id}
function s.selfspfilter(c)
	return c:IsSetCard(SET_FLOWER_CARDIAN) and c:IsLevel(8) and not c:IsCode(id)
end
function s.selfspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.CheckReleaseGroup(tp,s.selfspfilter,1,false,1,true,c,tp,nil,false,nil)
end
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.SelectReleaseGroup(tp,s.selfspfilter,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.drsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
function s.drspop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local dc=Duel.GetOperatedGroup():GetFirst()
		Duel.ConfirmCards(1-tp,dc)
		if dc:IsSetCard(SET_FLOWER_CARDIAN) and dc:IsMonster() then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and dc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				Duel.BreakEffect()
				Duel.SpecialSummon(dc,0,tp,tp,false,false,POS_FACEUP)
			end
		else
			Duel.BreakEffect()
			Duel.SendtoGrave(dc,REASON_EFFECT)
		end
		Duel.ShuffleHand(tp)
	end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end