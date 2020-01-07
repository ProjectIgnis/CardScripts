--The Legendary Gambler
--scripted by: UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	--e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCode(EVENT_CHAINING)
	c:RegisterEffect(e1)
	--dice
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE_NEGATE)
	e2:SetRange(LOCATION_SZONE)
	--e2:SetCondition(s.condition)
	--e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
--[[function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	local ex=Duel.GetOperationInfo(ev,CATEGORY_DICE)
	return ex and re:GetHandler():GetControler(1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end]]--
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_CARD,0,id)
		local cd=Duel.GetDiceResult()
		if cd~=0 then
			local dc=Duel.TossDice(tp,1)
			--local cd=Duel.TossDice(1-tp,1)
			if dc>=cd then
				Duel.NegateEffect(ev)
			end
		end
	end
end
--[[function c39454112.diceop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(39454112,0)) then
		Duel.Hint(HINT_CARD,0,39454112)
		local dc={Duel.GetDiceResult()}
		local ac=1
		if ev>1 then
			local t={}
			for i=1,ev do t[i]=i end
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39454112,1))
			ac=Duel.AnnounceNumber(tp,table.unpack(t))
		end
		if dc[ac]==1 or dc[ac]==3 or dc[ac]==5 then dc[ac]=6
		else dc[ac]=1 end
		Duel.SetDiceResult(table.unpack(dc))
	end
end]]--
