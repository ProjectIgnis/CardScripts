--ＧＭＸ－ＣＯＭＰＲＥＸ
--GMX - COMPREX
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 "GMX" monster + 2+ Dinosaur monsters
	Fusion.AddProcMixRep(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DINOSAUR),2,99,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GMX))
	--Gains these effects based on the number of Dinosaur monsters used as Fusion Material for this card
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1a:SetCondition(function(e) return e:GetHandler():IsFusionSummoned() end)
	e1a:SetOperation(s.effop)
	c:RegisterEffect(e1a)
	--Track the number of Dinosaur monsters used as Fusion Material for this card
	local e1b=Effect.CreateEffect(c)
	e1b:SetType(EFFECT_TYPE_SINGLE)
	e1b:SetCode(EFFECT_MATERIAL_CHECK)
	e1b:SetValue(function(e,c) e1a:SetLabel(c:GetMaterial():FilterCount(Card.IsRace,nil,RACE_DINOSAUR,c,SUMMON_TYPE_FUSION,e:GetHandlerPlayer())) end)
	c:RegisterEffect(e1b)
	--Once per turn, if you excavate a card(s) by a "GMX" card effect: You can destroy all other monsters on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+1595137)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GMX}
s.material_setcode={SET_GMX}
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local dino_mats_count=e:GetLabel()
	if dino_mats_count>=3 then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
		--● 3+: Your opponent cannot target this card with card effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetValue(aux.tgoval)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	if dino_mats_count>=4 then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
		--● 4+: Can make up to 3 attacks during each Battle Phase
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
	if dino_mats_count>=5 then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
		--● 5+: Each time your opponent Normal or Special Summons a monster(s), they lose 800 LP
		local e3a=Effect.CreateEffect(c)
		e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3a:SetCode(EVENT_SUMMON_SUCCESS)
		e3a:SetRange(LOCATION_MZONE)
		e3a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) end)
		e3a:SetOperation(s.lpop)
		e3a:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e3a)
		local e3b=e3a:Clone()
		e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
		c:RegisterEffect(e3b)
	end
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainSolving() then
		Duel.Hint(HINT_CARD,0,id)
		local opp=1-tp
		Duel.SetLP(opp,Duel.GetLP(opp)-800)
	else
		local c=e:GetHandler()
		--Your opponent loses 800 LP at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_MZONE)
		e1:SetOperation(function(e,tp) Duel.Hint(HINT_CARD,0,id) local opp=1-tp return Duel.SetLP(opp,Duel.GetLP(opp)-800) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r&REASON_EFFECT>0 and Chain.IsSetcode(0,SET_GMX)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and c or nil
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,exc)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
