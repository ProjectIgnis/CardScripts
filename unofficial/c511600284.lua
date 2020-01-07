--CX 機装魔人エンジェネラル (Anime)
--CXyz Mechquipped Djinn Angeneral (Anime)
--Scripted by Larry126
Duel.LoadScript("c41309158.lua")
local s,id=GetID()
function s.initial_effect(c)	
	--xyz summon
	Xyz.AddProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	--Rank Up Check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.rankupregcon)
	e1:SetOperation(s.rankupregop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
s.listed_series={0x95}
s.listed_names={15914410,100000581,111011002,511000580,511002068,511002164,93238626}
function s.rumfilter(c)
	return c:IsCode(15914410) and not c:IsPreviousLocation(LOCATION_OVERLAY)
end
function s.valcheck(e,c)
	if c:GetMaterial():IsExists(s.rumfilter,1,nil) then e:GetLabelObject():SetLabel(1) else e:GetLabelObject():SetLabel(0) end
end
function s.rankupregcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and (rc:IsSetCard(0x95)
		or rc:IsCode(100000581) or rc:IsCode(111011002) or rc:IsCode(511000580)
		or rc:IsCode(511002068) or rc:IsCode(511002164) or rc:IsCode(93238626))
end
function s.rankupregop(e,tp,eg,ep,ev,re,r,rp)
	--damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(alias,1))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	e:GetHandler():RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetOverlayCount()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	c:RemoveOverlayCard(tp,ct,ct,REASON_COST)
	e:SetLabel(ct)
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
