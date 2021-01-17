--ダークアイ・ナイトメア
--Dark-Eye Nightmare
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--destroy replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.reptg)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	local mct=2
	if Duel.IsPlayerCanDraw(tp,2) then mct=3 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,mct,nil)
	e:SetLabel(Duel.Remove(g,POS_FACEUP,REASON_COST))
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	if e:GetLabel()==3 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	else
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
		e:SetCategory(CATEGORY_DRAW)
	end
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local lbl=e:GetLabel()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=1
	if lbl==3 then d=2 end
	if Duel.Draw(p,d,REASON_EFFECT)==d and lbl~=2 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		if lbl==1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
			local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
			end
		elseif lbl==3 then
			Duel.DiscardHand(p,nil,1,1,REASON_EFFECT+REASON_DISCARD)
		end
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
