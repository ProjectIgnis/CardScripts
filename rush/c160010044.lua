--スプレンディッド・Ｆマスター
--Splendid Floor Master
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160303019,2)
	--Toss a coin a draw
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.toss_coin=true
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,600) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	 Duel.PayLPCost(tp,600)
	 --Effect
	local res=Duel.TossCoin(tp,1)
	if res==COIN_HEADS then
		Duel.Draw(tp,2,REASON_EFFECT)
	elseif res==COIN_TAILS then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end