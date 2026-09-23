--環境適応力
--Field Power Bonus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--If a monster(s) is Normal or Special Summoned and there is another monster(s) on the field with the same Type: That Summoned monster(s) gains 1000 ATK/DEF
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1a:SetCode(EVENT_SUMMON_SUCCESS)
	e1a:SetRange(LOCATION_FZONE)
	e1a:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e1a:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(Card.IsFaceup,1,nil)
	end)
	e1a:SetTarget(s.atktg)
	e1a:SetOperation(s.atkop)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--If this card is destroyed: Negate the effects of all face-up monsters currently on the field, also their ATK/DEF become their original ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--Once per turn, during the Standby Phase, if this card is in your GY and there is no card in either Field Zone: You can place this card face-up on your field
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==0
	end)
	e3:SetTarget(s.pltg)
	e3:SetOperation(s.plop)
	c:RegisterEffect(e3)
end
function s.typecheckfilter(c)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,c:GetRace()),0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.typecheckfilter,1,nil) end
	local sg=eg:Filter(s.typecheckfilter,nil)
	for sc in sg:Iter() do
		sc:CreateEffectRelation(e)
	end
	e:GetChainData().summon_group=sg
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,sg,#sg,tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,sg,#sg,tp,1000)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=e:GetChainData().summon_group:Match(aux.FaceupFilter(Card.IsRelateToEffect,e),nil)
	for tc in sg:Iter() do
		--That Summoned monster(s) gains 1000 ATK/DEF
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	for tc in g:Iter() do
		--Negate the effects of all face-up monsters currently on the field
		if tc:IsNegatableMonster() then
			tc:NegateEffects(c)
		end
		--Their ATK/DEF become their original ATK/DEF
		if tc:GetAttack()~=tc:GetBaseAttack() then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		if tc:GetDefense()~=tc:GetBaseDefense() then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(tc:GetBaseDefense())
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckUniqueOnField(tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end