--オトモダチ！
--Companions!
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 card and increase the ATK of 2 monsters with the same attribute
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,0,1,c,c) and not c:IsMaximumModeSide()
end
function s.cfilter2(c,sc)
	return c:IsFaceup() and c:IsRace(sc:GetRace()) and not c:IsMaximumModeSide()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_ATKCHANGE,nil,2,tp,400)
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetAttribute)==1
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Draw 1 card
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroupRush(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		if #g<2 then return end
		if aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_ATKDEF,s.rescon)
			if #sg==0 then return end
			Duel.HintSelection(sg,true)
			for tc in sg:Iter() do
				--Gain 400 ATK until the end of this turn
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(400)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end