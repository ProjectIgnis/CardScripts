--華蝶風彩のプロフェシーフレイル
--Prophecy Flail of the Colors of the Wind, Butterflies and Flowers
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160011024,160015012)
	--Destroy 1 monster the opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_TODECK|CATEGORY_ATKCHANGE|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil) end
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsAbleToDeck()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=g:Select(tp,1,1,nil)
		dg:AddMaximumCheck()
		Duel.HintSelection(dg,true)
		if Duel.Destroy(dg,REASON_EFFECT)>0 then
			local tdg=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_GRAVE,nil)
			if #tdg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				if Duel.SendtoDeck(tdg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(1200)
					e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
					c:RegisterEffect(e1)
					Duel.Draw(tp,1,REASON_EFFECT)
				end
			end
		end
	end
end