--フラッシュ・エフェクト
--Flash Effect
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
    	return Duel.IsBattlePhase() and loc==LOCATION_MZONE and re:IsMonsterEffect() and Duel.IsChainDisablable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rc=re:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc==rc end
	if chk==0 then return rc:IsLocation(LOCATION_MZONE) and rc:IsCanBeEffectTarget(e) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,rc,1,0,800)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if rc and not rc:IsImmuneToEffect(e) and rc:IsLocation(LOCATION_MZONE) and rc:IsRelateToEffect(re) and rc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_BATTLE)
		e1:SetValue(800)
		rc:RegisterEffect(e1)
	end
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	g:ForEach(function(tc) tc:NegateEffects(c,RESET_PHASE|PHASE_BATTLE,true) end)
end