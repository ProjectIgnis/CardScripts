-- マッハメガファルコン
-- Mach Mega Falcon
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- "Cyber Falcon" + "Cyber Falcon"
	Fusion.AddProcMix(c,true,true,30655537,30655537)
	-- Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lptg)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
end
s.listed_materials={30655537}
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Recover(p,d,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,500,REASON_EFFECT)
	end
end