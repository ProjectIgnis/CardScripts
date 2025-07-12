--ＣＸ 機装魔人エンジェネラル (Anime)
--CXyz Mechquipped Djinn Angeneral (Anime)
--Scripted by Larry126
Duel.LoadCardScript("c41309158.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 4 monsters
	Xyz.AddProcedure(c,nil,4,3)
	--Rank Up Check
	aux.EnableCheckRankUp(c,nil,nil,15914410)
	--Inflict 500 damage to your opponent for each Xyz Material detached
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==1-tp end)
	e1:SetCost(Cost.DetachFromSelf(s.damcost,s.damcost,function(e,og) e:SetLabel(#og) end))
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_RANKUP_EFFECT)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
s.listed_names={15914410}
function s.damcost(e,tp)
	return e:GetHandler():GetOverlayCount()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetLabel()*500
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
