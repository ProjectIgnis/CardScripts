-- 火麺特忍ニクマシゴックブート
--Meat Spice the Special Noodle Ninja
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- "Masked Fiery Noodle Jonin Kaedama Gockboot" + "Taste Inspector"
	Fusion.AddProcMix(c,true,true,160003033,CARD_TASTE_INSPECTOR)
	-- Damage and draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsStatus(STATUS_SPSUMMON_TURN) end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.setfilter(c)
	return c:IsCode(160003046,160007051) and c:IsSSetable()
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local sg=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_GRAVE,0,nil)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 and ft>0 and #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local tg=aux.SelectUnselectGroup(sg,1,tp,1,ft,function(sg)return #sg==sg:GetClassCount(Card.GetCode)end,1,tp)
		if #tg>0 then
			Duel.BreakEffect()
			Duel.SSet(tp,tg)
		end
	end
end