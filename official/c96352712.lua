--誇大化
--Egomorph
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local dc=Duel.GetAttackTarget()
	if chk==0 then return dc~=nil end
	local ac=Duel.GetAttacker()
	local b1=ac:IsAttackPos() and ac:IsCanChangePosition()
	local b2=dc:IsAbleToHand()
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{true,aux.Stringid(id,3)})
	if op==1 then
		e:SetCategory(CATEGORY_POSITION)
		Duel.SetOperationInfo(0,CATEGORY_POSITION,ac,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,dc,1,0,0)
	elseif op==3 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,Group.FromCards(ac,dc),2,0,0)
	end
	Duel.SetTargetParam(op)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local ac=Duel.GetAttacker()
	local dc=Duel.GetAttackTarget()
	if op==1 then
		--Change the attacking monster to Defense Position
		if ac:IsAttackPos() and ac:IsRelateToBattle() then
			Duel.ChangePosition(ac,POS_FACEUP_DEFENSE)
		end
	elseif op==2 then
		--Return the attack target to the hand
		if dc and dc:IsRelateToBattle() then
			Duel.SendtoHand(dc,nil,REASON_EFFECT)
		end
	elseif op==3 then
		--Destroy both battling monsters
		local g=Group.FromCards(ac,dc):Match(Card.IsRelateToBattle,nil)
		if #g~=2 then return end
		Duel.Destroy(g,REASON_EFFECT)
	end
end